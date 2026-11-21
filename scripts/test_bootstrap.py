"""Bootstrap chooses the local provider and delegates managed Python provisioning."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class Bootstrap(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        scripts = self.root / 'scripts'
        scripts.mkdir()
        self.bootstrap = scripts / 'bootstrap.sh'
        shutil.copyfile(Path(__file__).with_name('bootstrap.sh'), self.bootstrap)
        self.env = dict(os.environ, LOG=str(self.root / 'log'))
        self.stub(scripts / 'ocaml-deps.sh', 'printf "deps %s\\n" "$*" >> "$LOG"')
        (scripts / 'install-tools.py').write_text(
            'import os,sys\n'
            'with open(os.environ["LOG"], "a") as f: print("install", *sys.argv[1:], file=f)\n'
            'sys.exit(int(os.environ.get("INSTALL_STATUS", 0)))\n')
        self.prefix = self.root / 'prefix'
        (self.prefix / 'bin').mkdir(parents=True)
        (scripts / 'env.sh').write_text('export ELECTRUM_TOOLS_PREFIX=' + str(self.prefix))
        self.stub(self.prefix / 'bin/hardcaml-asic-flow',
                  'python3 -c \'import json,sys; print(json.dumps(sys.argv[1:]))\' "$@" >> "$LOG"')

    def stub(self, path, body):
        path.write_text('#!/usr/bin/env bash\n' + body + '\n')
        path.chmod(0o755)

    def invoke(self, *argv, **env):
        result = subprocess.run(['bash', self.bootstrap, *argv],
                                env={**self.env, **env}, capture_output=True, text=True)
        return result, (self.root / 'log').read_text().splitlines()

    def test_normal_bootstrap_uses_provider_defaults_without_host_python_override(self):
        result, calls = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[:2], ['deps --tool-deps', 'install --ensure'])
        self.assertEqual(json.loads(calls[2]), ['provision', '--toolchain', str(self.root / '_flow_tools')])

    def test_check_does_not_install(self):
        result, calls = self.invoke('--check', '--no-container')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[1], 'install --check-current')
        self.assertEqual(json.loads(calls[2])[-2:], ['--check', '--no-container'])

    def test_failed_install_never_provisions(self):
        result, calls = self.invoke(INSTALL_STATUS='2')
        self.assertEqual(result.returncode, 2)
        self.assertEqual(calls, ['deps --tool-deps', 'install --ensure'])


if __name__ == '__main__':
    unittest.main()
