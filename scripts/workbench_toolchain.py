"""Read-only validation of an explicitly selected existing physical toolchain.

Checks pinned collateral and installed Python/provider metadata. Runs no EDA,
container, provisioning, package installation or shared-switch operation.
"""
import hashlib
import ast
import json
import os
from pathlib import Path
import subprocess


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root, project_root, provider):
    root = Path(root).resolve(strict=True)
    lock = project_root / 'asic/tinytapeout/toolchain.lock'
    pins = dict(line.split('=', 1) for line in lock.read_text().splitlines()
                if line and not line.startswith('#'))
    result = dict(root=str(root), validation='pinned_metadata_only_no_EDA', eda_run=False,
                  lock=str(lock), lock_sha256=digest(lock), repositories={})
    git_env = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
    git_env['GIT_OPTIONAL_LOCKS'] = '0'
    for name, key in (('pdk', 'pdk_revision'), ('tt', 'support_tools_revision')):
        path = root / name
        revision = subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'],
                                           text=True, timeout=10, env=git_env).strip()
        status = subprocess.check_output(['git', '-C', str(path), 'status', '--porcelain', '--untracked-files=no'],
                                         text=True, timeout=10, env=git_env)
        if revision != pins[key] or status:
            raise ValueError('physical collateral must be clean at pinned revision: ' + str(path))
        result['repositories'][name] = dict(path=str(path), revision=revision, tracked_status=status)
    floorplan = root / 'tt' / pins['floorplan_def']
    if digest(floorplan) != pins['floorplan_def_sha256']:
        raise ValueError('pinned floorplan bytes differ')
    # Retain the venv alias: resolving the executable symlink would lose its venv.
    python = root / '.venv/bin/python'
    probe = "import sys,json,importlib.metadata as m; d=m.distribution('librelane'); print(json.dumps(dict(python_minor=f'{sys.version_info.major}.{sys.version_info.minor}',python_version=sys.version,venv_prefix=sys.prefix,librelane_version=d.version,classic_path=str(d.locate_file('librelane/flows/classic.py')))))"
    metadata = json.loads(subprocess.check_output([str(python), '-c', probe], text=True, timeout=10))
    if (metadata['python_minor'] != pins['runtime_host_python_version'] or
            metadata['librelane_version'] != pins['librelane_version'] or
            Path(metadata['venv_prefix']).resolve() != root / '.venv'):
        raise ValueError('selected Python/LibreLane metadata differs from pinned toolchain')
    metadata.update(path=str(python), executable_sha256=digest(python),
                    classic_sha256=digest(Path(metadata['classic_path'])))
    defaults = [keyword.value.value for node in ast.walk(ast.parse(Path(metadata['classic_path']).read_text()))
                if isinstance(node, ast.Call) and node.args and isinstance(node.args[0], ast.Constant)
                and node.args[0].value == 'RUN_POST_GRT_RESIZER_TIMING'
                for keyword in node.keywords if keyword.arg == 'default' and isinstance(keyword.value, ast.Constant)]
    if len(defaults) != 1 or defaults[0] is not False:
        raise ValueError('pinned backend post-GRT timing repair default is not uniquely false')
    metadata['post_grt_timing_repair_default'] = False
    result.update(python=metadata, support_tools=str(root / 'tt'), pdk_root=str(root / 'pdk'),
                  floorplan_sha256=digest(floorplan))
    identity = json.loads(subprocess.check_output([str(provider), '--version', '--json'], text=True, timeout=10))
    contract = identity['cli_contract']
    scope = contract['capabilities'].get('sram_segmented1_scope', {})
    if contract['version'] != 4 or not contract['capabilities'].get('sram_segmented1') or 'timing' not in scope.get('endpoints', []):
        raise ValueError('selected installed provider lacks stock SRAM segmented through-Timing support')
    result['provider'] = dict(executable=str(provider), sha256=digest(provider),
                              module_dir=identity['module_dir'], cli_contract=4,
                              sram_segmented1_scope=scope)
    return result
