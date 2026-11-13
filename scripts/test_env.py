"""Pure interactive-shell activation tests; no opam/build/install is invoked."""
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent


class Activation(unittest.TestCase):
    def fixture(self, root):
        scripts = root / 'scripts'
        scripts.mkdir()
        (scripts / 'env.sh').write_bytes((HERE / 'env.sh').read_bytes())
        old = root / '.dev/tools/generations/old/prefix'
        selected = root / '.dev/tools/generations/new/prefix'
        unrelated = root / 'unrelated bin'
        for directory, code in ((old / 'bin', 17), (selected / 'bin', 0), (unrelated, 23)):
            directory.mkdir(parents=True)
            for tool in ('hardcaml-asic-flow', 'hardcaml-workbench', 'hardcaml-workbench-daemon', 'dune'):
                path = directory / tool
                path.write_text('#!/bin/sh\nexit ' + str(code) + '\n')
                path.chmod(0o755)
        (root / '.dev/tools/current.json').write_text('{}')
        (scripts / 'install-tools.py').write_text(
            'import os,sys\nfrom pathlib import Path\n'
            f'root=Path({str(root)!r})\n'
            'if os.environ.get("UNIT_ACTIVATION_OK") != "1" or not (root/".dev/tools/current.json").exists(): sys.exit(2)\n'
            f'print("export ELECTRUM_TOOLS_PREFIX=" + {shlex.quote(str(selected))!r})\n'
            f'print("export ELECTRUM_TOOLS_RECEIPT=" + {shlex.quote(str(selected.parent / "receipt.json"))!r})\n'
            f'print("export OCAMLPATH=" + {shlex.quote(str(selected / "lib") + ":/switch/lib")!r})\n'
            f'print("export PATH=" + {shlex.quote(str(selected / "bin"))!r} + ":\\\"$PATH\\\"")\n')
        path = ':' + str(old / 'bin') + '::' + str(unrelated) + ':/usr/local/bin:/usr/bin:/bin:'
        env = dict(os.environ, PATH=path, ELECTRUM_TOOLS_PREFIX=str(old), ELECTRUM_TOOLS_RECEIPT='/stale/receipt',
                   ELECTRUM_ASIC_PREFIX=str(root / '.dev/pt3a-provider/prefix'),
                   OCAMLPATH=str(old / 'lib') + ':/unrelated/lib',
                   CAML_LD_LIBRARY_PATH=str(old / 'lib/stublibs') + ':/unrelated/stublibs')
        env.pop('UNIT_ACTIVATION_OK', None)
        return old, selected, unrelated, env

    def run_shell(self, root, env, body):
        code = ('set +e; opam() { builtin printf "UNIT_OPAM_QUERY\\n" >&2; return 0; }; '
                'unrelated_function() { return 47; }; ' + body)
        result = subprocess.run(['bash', '--noprofile', '--norc', '-i', '-c', code], cwd=root,
                                env=env, text=True, capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(result.stdout.splitlines()[-1]), result.stderr

    def test_failed_activation_cleans_old_generation_and_blocks_shared_fallback(self):
        with tempfile.TemporaryDirectory(prefix='electrum env ') as tmp:
            root = Path(tmp)
            old, selected, unrelated, env = self.fixture(root)
            body = (f'source {shlex.quote(str(root / "scripts/env.sh"))}; export SOURCE_RC=$?; '
                'hardcaml-asic-flow; export CLI_RC=$?; dune; export DUNE_RC=$?; '
                'unrelated_function; export UNRELATED_RC=$?; '
                f'{shlex.quote(sys.executable)} -c ' + shlex.quote(
                    'import json,os; print(json.dumps({k:os.environ.get(k) for k in '
                    '("PATH","SOURCE_RC","CLI_RC","DUNE_RC","UNRELATED_RC","ELECTRUM_TOOLS_PREFIX",'
                    '"ELECTRUM_TOOLS_RECEIPT","ELECTRUM_ASIC_PREFIX","OCAMLPATH","CAML_LD_LIBRARY_PATH")}))'))
            value, stderr = self.run_shell(root, env, body)
            self.assertEqual(value['SOURCE_RC'], '2')
            self.assertEqual((value['CLI_RC'], value['DUNE_RC']), ('2', '2'))
            self.assertEqual(value['UNRELATED_RC'], '47')
            self.assertEqual(value['PATH'], '::' + str(unrelated) + ':/usr/local/bin:/usr/bin:/bin:')
            self.assertIsNone(value['ELECTRUM_TOOLS_PREFIX'])
            self.assertIsNone(value['ELECTRUM_TOOLS_RECEIPT'])
            self.assertIsNone(value['ELECTRUM_ASIC_PREFIX'])
            self.assertEqual(value['OCAMLPATH'], '/unrelated/lib')
            self.assertEqual(value['CAML_LD_LIBRARY_PATH'], '/unrelated/stublibs')
            self.assertNotIn('UNIT_OPAM_QUERY', stderr, 'failure must precede opam activation')

    def test_success_after_failure_removes_guards_and_is_repeatable(self):
        with tempfile.TemporaryDirectory(prefix='electrum env ') as tmp:
            root = Path(tmp)
            old, selected, unrelated, env = self.fixture(root)
            activate = 'source ' + shlex.quote(str(root / 'scripts/env.sh'))
            body = (activate + '; export FIRST_RC=$?; export UNIT_ACTIVATION_OK=1; ' + activate + '; export SECOND_RC=$?; '
                    + activate + '; export THIRD_RC=$?; hardcaml-asic-flow; export CLI_RC=$?; '
                    f'{shlex.quote(sys.executable)} -c ' + shlex.quote(
                    'import json,os; print(json.dumps({k:os.environ.get(k) for k in '
                    '("PATH","FIRST_RC","SECOND_RC","THIRD_RC","CLI_RC","ELECTRUM_TOOLS_PREFIX",'
                    '"ELECTRUM_TOOLS_ACTIVATION_FAILED")}))'))
            value, stderr = self.run_shell(root, env, body)
            self.assertEqual((value['FIRST_RC'], value['SECOND_RC'], value['THIRD_RC'], value['CLI_RC']), ('2', '0', '0', '0'))
            self.assertEqual(value['ELECTRUM_TOOLS_PREFIX'], str(selected))
            self.assertIsNone(value['ELECTRUM_TOOLS_ACTIVATION_FAILED'])
            self.assertEqual(value['PATH'].split(':').count(str(selected / 'bin')), 1)
            self.assertNotIn(str(old / 'bin'), value['PATH'].split(':'))

    def test_missing_selection_cannot_reuse_an_inherited_generation(self):
        with tempfile.TemporaryDirectory(prefix='electrum env ') as tmp:
            root = Path(tmp)
            old, selected, unrelated, env = self.fixture(root)
            (root / '.dev/tools/current.json').unlink()
            body = ('source ' + shlex.quote(str(root / 'scripts/env.sh')) + '; export SOURCE_RC=$?; '
                    'hardcaml-asic-flow; export CLI_RC=$?; '
                    f'{shlex.quote(sys.executable)} -c ' + shlex.quote(
                        'import json,os; print(json.dumps({k:os.environ.get(k) for k in '
                        '("SOURCE_RC","CLI_RC","ELECTRUM_TOOLS_PREFIX","PATH")}))'))
            value, stderr = self.run_shell(root, env, body)
            self.assertEqual((value['SOURCE_RC'], value['CLI_RC']), ('2', '2'))
            self.assertIsNone(value['ELECTRUM_TOOLS_PREFIX'])
            self.assertNotIn(str(old / 'bin'), value['PATH'].split(':'))

    def test_failed_project_dune_guard_preserves_unrelated_directory_tools(self):
        with tempfile.TemporaryDirectory(prefix='electrum env ') as tmp:
            root = Path(tmp)
            old, selected, unrelated, env = self.fixture(root)
            outside = root / 'outside'
            # Use the parent's directory, genuinely outside the failed project.
            body = ('source ' + shlex.quote(str(root / 'scripts/env.sh')) + '; '
                    'builtin cd ..; dune; export DUNE_RC=$?; '
                    f'{shlex.quote(sys.executable)} -c ' + shlex.quote('import json,os; print(json.dumps(dict(dune=os.environ["DUNE_RC"])))'))
            value, stderr = self.run_shell(root, env, body)
            self.assertEqual(value['dune'], '23')


if __name__ == '__main__':
    unittest.main()
