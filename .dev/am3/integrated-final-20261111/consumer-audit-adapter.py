"""Use the existing read-only consumer audit against the fresh captured bundle.

The Dune sandbox's temporary loader_bundle is no longer retained after forced RTL.
Only its evidence location changes; all source/closure/golden assertions are intact.
"""
from pathlib import Path

out = Path(__file__).resolve().parent
original = out.parent / 'consumer-audit.py'
source = original.read_text()
before = 'bundle = ROOT / "_build/default/tinytapeout/src/loader_bundle"'
after = 'bundle = ROOT / ".dev/am3/integrated-final-20261111/bundles/loader"'
assert source.count(before) == 1
exec(compile(source.replace(before, after), str(original), 'exec'),
     {'__file__': str(original), '__name__': '__main__'})
