#!/usr/bin/env python3
"""Normal Electrum Workbench integration. Run through scripts/workbench.sh.

configure builds the project gateway and registered chip CLIs and publishes owned companions.
daemon runs in the foreground; client only connects to an explicitly running daemon.
No command provisions an EDA toolchain or starts a physical flow.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from workbench_toolchain import validate as validate_toolchain

ROOT = Path(__file__).resolve().parents[1]
STORE = ROOT / '.dev/workbench'
TARGET = 'asic_support/cli/project.exe'
CHIP_CATALOG = 'hardcaml-asic-targets.json'


def chip_catalog():
    # Read the source catalog, not the compiled gateway: a newly registered
    # owner must be included even before its executable exists.
    def unique_fields(pairs):
        fields = dict(pairs)
        if len(fields) != len(pairs):
            raise ValueError('duplicate JSON field')
        return fields

    try:
        data = regular(ROOT / CHIP_CATALOG)
        if data is None:
            raise ValueError('missing file')
        catalog = json.loads(data, object_pairs_hook=unique_fields)
        if (not isinstance(catalog, dict)
                or set(catalog) != {'schema_version', 'default_target', 'targets'}
                or type(catalog['schema_version']) is not int or catalog['schema_version'] != 1
                or not isinstance(catalog['targets'], list)):
            raise ValueError('expected a version 1 chip catalog')
        targets = {}
        for entry in catalog['targets']:
            if not isinstance(entry, dict) or set(entry) != {'id', 'executable'}:
                raise ValueError('expected a chip ID and executable')
            chip, target = entry['id'], entry['executable']
            if not isinstance(chip, str) or not re.fullmatch(r'[a-z][a-z0-9_-]*', chip) or chip in targets:
                raise ValueError(f'invalid or duplicate chip ID: {chip!r}')
            if (not isinstance(target, str) or not target.endswith('.exe')
                    or any(part in ('', '.', '..', '_build') for part in target.split('/'))
                    or any(ord(c) < 32 or ord(c) == 127 or c == '\\' for c in target)):
                raise ValueError(f'expected a project-relative Dune executable for chip {chip!r}')
            targets[chip] = target
        default = catalog['default_target']
        if not isinstance(default, str) or default not in targets:
            raise ValueError('default_target must name a registered chip')
        return default, targets
    except (OSError, ValueError) as error:
        raise ValueError(f'{CHIP_CATALOG}: {error}') from error


def build():
    _, owners = chip_catalog()
    targets = dict.fromkeys([TARGET, *owners.values()])
    subprocess.run(['dune', 'build', '-j10', *('./' + target for target in targets)],
                   cwd=ROOT, check=True)


def executable_ready(path):
    return path.is_file() and os.access(path, os.X_OK)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def regular(path):
    if path.is_symlink() or path.parent.resolve() != path.parent:
        raise ValueError('symlinked configuration: ' + str(path))
    return path.read_bytes() if path.exists() else None


def sexp(value):
    if isinstance(value, list):
        return '(' + ' '.join(sexp(v) for v in value) + ')'
    return json.dumps(str(value))


def record(fields):
    return (sexp([[key, value] for key, value in fields]) + '\n').encode()


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    regular(path)
    pending = path.with_name(path.name + '.pending')
    with pending.open('xb') as stream:
        stream.write(data)
    os.replace(pending, path)


def selected():
    receipt = Path(os.environ['ELECTRUM_TOOLS_RECEIPT'])
    value = json.loads(receipt.read_text())
    prefix = Path(value['prefix'])
    if value['checks_passed'] is not True or str(prefix) != os.environ['ELECTRUM_TOOLS_PREFIX']:
        raise ValueError('source scripts/env.sh first')
    return value, prefix


def stopped():
    # Never restart an existing owner, including a daemon launched outside this wrapper.
    for entry in Path('/proc').iterdir():
        if not entry.name.isdecimal():
            continue
        try:
            argv = (entry / 'cmdline').read_bytes().split(b'\0')
            if b'--state-dir' not in argv:
                continue
            cwd = (entry / 'cwd').resolve(strict=True)
            if cwd == ROOT or os.fsencode(str(STORE / 'state')) in argv:
                raise ValueError('Workbench daemon already owns this checkout: PID ' + entry.name)
        except FileNotFoundError:
            continue


def configure(args):
    stopped()
    value, prefix = selected()
    ownership = STORE / 'configuration.json'
    prior = json.loads(regular(ownership)) if ownership.exists() else {'sha256': {}}
    source_only = getattr(args, 'source_only', False)
    if source_only:
        tools = ROOT / '_flow_tools'
    elif args.toolchain:
        tools = args.toolchain.resolve()
    else:
        tools = Path(prior.get('toolchain', ROOT / '_flow_tools'))
    physical = (validate_toolchain(tools, ROOT, prefix / 'bin/hardcaml-asic-flow')
                if not source_only and (args.toolchain or prior.get('physical_toolchain')) else None)
    build()
    python = physical['python']['path'] if physical else str(tools / 'venv/bin/python')
    configs = {
        'asic': record([('schema_version', 1),
            ('project_executable', str(ROOT / '_build/default' / TARGET)),
            ('provider_executable', str(prefix / 'bin/hardcaml-asic-flow')),
            ('results_root', str(ROOT / '_flow_results/workbench/asic')),
            ('toolchain', str(tools)), ('python', [python]),
            ('support_tools', [str(tools / 'tt')]), ('pdk_root', [str(tools / 'pdk')]),
            ('stage_timeout_seconds', [3600])]),
        'preparation': record([('schema_version', 1), ('build_target', TARGET),
            ('results_root', str(ROOT / '_flow_results/workbench/preparation')),
            ('timeout_seconds', 600)])}
    if getattr(args, 'simulation', False):
        configs['simulation'] = simulation_configuration()
    elif args.simulation_config:
        data = regular(args.simulation_config.resolve(strict=True))
        # The actual provider and suites are owned by the caller, not synthesized here.
        configs['simulation'] = data
    # Preserve an already owned simulation handoff during an ASIC-only update.
    if 'simulation' in prior['sha256'] and 'simulation' not in configs:
        path = ROOT / '.workbench/hardcaml-workbench-simulation.sexp'
        data = regular(path)
        if data is None or sha(data) != prior['sha256']['simulation']:
            raise ValueError('unknown simulation companion edit; refusing adoption')
        configs['simulation'] = data
    for kind, data in configs.items():
        filename = 'hardcaml-workbench-' + kind + '.sexp'
        path = ROOT / '.workbench' / filename
        old = regular(path)
        # Also respect Workbench's root-level companion compatibility location.
        legacy = regular(ROOT / filename)
        if legacy is not None and legacy != data:
            raise ValueError('existing root companion differs; inspect it explicitly: ' + filename)
        if old is not None and old != data and sha(old) != prior['sha256'].get(kind):
            raise ValueError('unknown user companion edit; refusing overwrite: ' + str(path))
    stopped()
    # Retain exact old owned bytes before publishing an explicitly requested update.
    for kind, data in configs.items():
        path = ROOT / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp')
        old = regular(path)
        if old is not None and old != data:
            backup = STORE / 'history' / (kind + '-' + sha(old) + '.sexp')
            if not backup.exists():
                write(backup, old)
        write(path, data)
    state = dict(schema_version=1, project_root=str(ROOT), prefix=str(prefix),
                  build_target=TARGET,
                  receipt=os.environ['ELECTRUM_TOOLS_RECEIPT'],
                  toolchain=str(tools),
                  physical_toolchain=physical,
                 sha256={kind: sha(data) for kind, data in configs.items()},
                 simulation_configured='simulation' in configs)
    write(ownership, (json.dumps(state, indent=2) + '\n').encode())
    print(json.dumps(state, indent=2))


def simulation_configuration():
    # Ready means actual serial and event replay qualification passed, not discovery alone.
    # This function performs only file/hash checks and never builds or simulates.
    sys.path.insert(0, str(ROOT / 'scripts/simulation'))
    import prepare as simulation_setup
    selection, value = simulation_setup.verify_current()
    generation = Path(selection['manifest']).parent
    return record([('schema_version', 1), ('provider_executable', str(Path(sys.executable).resolve())),
        ('provider_args', [str(generation / 'pt3b_provider.py'), '--manifest', selection['manifest']]),
        ('discovery_timeout_seconds', 30), ('run_timeout_seconds', 3600)])


def readiness(prefix, configuration):
    output = ROOT / '_build/default'
    executable = output / TARGET
    provider = prefix / 'bin/hardcaml-asic-flow'
    chips = dict(path=str(ROOT / CHIP_CATALOG))
    try:
        default, owners = chip_catalog()
        targets = [dict(id=chip, build_target=target, executable=str(output / target),
                        ready=executable_ready(output / target))
                   for chip, target in owners.items()]
        chips.update(default_target=default, targets=targets, ready=all(t['ready'] for t in targets))
    except ValueError as error:
        chips.update(ready=False, diagnostic=str(error))
    paths = {kind: ROOT / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp')
             for kind in ('asic', 'preparation')}
    owned = configuration.get('sha256', {}) if configuration else {}
    companions_match = all(regular(path) is not None and sha(regular(path)) == owned.get(kind)
                           for kind, path in paths.items())
    selection_matches = bool(configuration and configuration.get('prefix') == str(prefix))
    target_matches = bool(configuration and configuration.get('build_target') == TARGET)
    configure_required = not (selection_matches and target_matches)
    ready = (executable_ready(executable) and executable_ready(provider)
             and chips['ready'] and companions_match and not configure_required)
    toolchain = Path(configuration.get('toolchain', ROOT / '_flow_tools')) if configuration else ROOT / '_flow_tools'
    collateral = dict(python=(toolchain / 'venv/bin/python').is_file(),
                      support_tools=(toolchain / 'tt').is_dir(), pdk=(toolchain / 'pdk').is_dir())
    physical = dict(ready=False, status='missing_collateral' if not all(collateral.values()) else 'not_validated',
        requires_explicit_preflight=True, collateral_present=collateral, toolchain=str(toolchain),
        readiness_scope='metadata_only_no_EDA')
    if not configure_required and configuration.get('physical_toolchain'):
        try:
            validated = validate_toolchain(toolchain, ROOT, provider)
            physical.update(ready=ready, status='metadata_validated', metadata=validated)
            physical['collateral_present']['python'] = True
        except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
            physical.update(status='metadata_validation_failed', diagnostic=str(error))
    simulation = dict(configured=bool(configuration and configuration.get('simulation_configured')), ready=False)
    if simulation['configured'] and not configure_required:
        try:
            simulation_configuration()
            simulation.update(ready=True, status='qualified_current_source')
        except (OSError, ValueError, KeyError, RuntimeError) as error:
            simulation.update(status='refresh_required', diagnostic=str(error),
                refresh_command='bash scripts/workbench.sh prepare-simulation --pdk-root ' + str(toolchain / 'pdk'))
    if configure_required:
        physical.update(ready=False, status='configure_required')
        simulation.update(ready=False, status='configure_required')
    return dict(ready=ready, configure_required=configure_required,
         status='configure_required' if configure_required else ('ready' if ready else 'not_ready'),
        scope='source_operations_ready_physical_metadata_separate',
        source_operations=dict(ready=ready, requires_pdk=False, project_executable=str(executable),
             provider_executable=str(provider), companions_match=companions_match, selection_matches=selection_matches,
             target_matches=target_matches,
             chip_catalog=chips,
             operations=['chip list', 'flow list', 'flow describe', 'flow plan', 'flow emit', 'prepare', 'preparation-inspect'],
            compiled_source_consistency='not_attested; explicitly build after source edits'),
        preparation=dict(configuration_path=str(paths['preparation']),
            project_root=str(ROOT), results_root=str(ROOT / '_flow_results/workbench/preparation')),
        physical=physical, simulation=simulation)


def inspect_preparation(prefix, attempt):
    attempt = attempt.resolve(strict=True)
    store = (ROOT / '_flow_results/workbench/preparation').resolve()
    if not attempt.is_relative_to(store) or not attempt.is_dir():
        raise ValueError('preparation attempt must belong to this Electrum results store')
    return subprocess.run([str(prefix / 'bin/hardcaml-asic-flow'), 'preparation-inspect', str(attempt), '--json'],
                          cwd=ROOT, check=True).returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    config = commands.add_parser('configure')
    toolchain = config.add_mutually_exclusive_group()
    toolchain.add_argument('--toolchain-root', '--toolchain', dest='toolchain', type=Path,
                           help='explicit existing pinned toolchain root; validate metadata without EDA/provisioning')
    toolchain.add_argument('--source-only', action='store_true',
                           help='use local defaults without revalidating a prior external physical toolchain')
    config.add_argument('--simulation-config', type=Path)
    config.add_argument('--simulation', action='store_true',
                        help='publish the real qualified installed serial/event provider (never prepares implicitly)')
    simulation = commands.add_parser('prepare-simulation',
        help='explicit -j2 source build and real serial/event qualification; requires a granted resource slot')
    simulation.add_argument('--pdk-root', type=Path, required=True)
    for name in ('status', 'build', 'daemon', 'client'):
        commands.add_parser(name)
    inspection = commands.add_parser('preparation-inspect', help='read an exact retained Electrum source-preparation attempt')
    inspection.add_argument('attempt', type=Path)
    resource = commands.add_parser('resource-prepare', help='explicit source-only preparation; no physical collateral required')
    resource.add_argument('--chip', help='registered chip ID (default: catalog default)')
    resource.add_argument('--flow', help='chip-local flow ID (default: chip flow default)')
    args = parser.parse_args()
    if args.command == 'configure' and args.simulation and args.simulation_config:
        parser.error('--simulation and --simulation-config are mutually exclusive')
    value, prefix = selected()
    if args.command == 'preparation-inspect':
        return inspect_preparation(prefix, args.attempt)
    if args.command == 'resource-prepare':
        argv = [str(ROOT / '_build/default' / TARGET), 'prepare', '--project-root', str(ROOT),
                '--results-root', str(ROOT / '_flow_results/workbench/preparation'), '--json']
        for flag, value in (('--chip', args.chip), ('--flow', args.flow)):
            if value is not None:
                argv.extend((flag, value))
        return subprocess.run(argv, cwd=ROOT, check=True).returncode
    if args.command == 'prepare-simulation':
        stopped()
        script = ROOT / 'scripts/simulation/prepare.py'
        return subprocess.run([sys.executable, '-B', str(script), '--pdk-root', str(args.pdk_root)],
                              cwd=ROOT, check=True).returncode
    if args.command == 'status':
        configuration = json.loads((STORE / 'configuration.json').read_text()) if (STORE / 'configuration.json').exists() else None
        print(json.dumps(dict(selection=json.loads((ROOT / '.dev/tools/current.json').read_text()),
            configuration=configuration, readiness=readiness(prefix, configuration),
            project_executable=str(ROOT / '_build/default' / TARGET)), indent=2))
        return
    STORE.mkdir(parents=True, exist_ok=True)
    with (STORE / 'session.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if args.command == 'configure':
            configure(args)
        elif args.command == 'build':
            build()
        else:
            config = json.loads((STORE / 'configuration.json').read_text())
            if config['prefix'] != str(prefix):
                raise ValueError('tools selection changed; explicitly configure again')
            if config.get('build_target') != TARGET:
                raise ValueError('ASIC gateway path changed; explicitly configure again')
            for kind, expected in config['sha256'].items():
                if sha(regular(ROOT / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp'))) != expected:
                    raise ValueError('companion changed: ' + kind)
            if args.command == 'daemon':
                stopped()
                for name in ('state', 'discovery'):
                    (STORE / name).mkdir(mode=0o700, exist_ok=True)
                argv = [str(prefix / 'bin/hardcaml-workbench-daemon'), '--port', '0',
                        '--state-dir', str(STORE / 'state'), '--discovery-dir', str(STORE / 'discovery')]
            else:
                # Parse only the loopback endpoint from the daemon's discovery record.
                data = regular(STORE / 'discovery/daemon.sexp').decode()
                match = re.search(r'\(endpoint\s+"?(http://127\.0\.0\.1:[0-9]+)"?\)', data)
                if not match:
                    raise ValueError('no running daemon endpoint; run daemon explicitly')
                argv = [str(prefix / 'bin/hardcaml-workbench'), '--connect', match[1],
                        '--project-root', str(ROOT), '--environment', 'inherited']
            # The daemon owns its own lifetime lock. No automatic startup/restart.
            os.chdir(ROOT)
            os.execv(argv[0], argv)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        sys.exit('workbench: ' + str(error))
