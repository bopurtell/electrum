"""Audit authored Dune dependency closure without running build actions."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


def parse(text):
    tokens = iter(re.findall(r'"(?:[^"\\]|\\.)*"|;[^\n]*|\(|\)|[^\s();]+', text))
    stack = [[]]
    for token in tokens:
        if token.startswith(";"):
            continue
        if token == "(":
            stack.append([])
        elif token == ")":
            value = stack.pop()
            stack[-1].append(value)
        else:
            stack[-1].append(token)
    assert len(stack) == 1
    return stack[0]


graph = {}
locations = {}
for root in ("ip", "software", "verif", "asic", "spec", "firmware"):
    for path in (ROOT / root).rglob("dune"):
        for stanza in parse(path.read_text()):
            if not stanza or stanza[0] not in ("library", "executable"):
                continue
            fields = {field[0]: field[1:] for field in stanza[1:] if isinstance(field, list) and field}
            name = fields["name"][0]
            graph[name] = fields.get("libraries", [])
            assert all(isinstance(dep, str) for dep in graph[name]), name
            locations[name] = str(path.relative_to(ROOT))


def closure(name, found=None):
    found = set() if found is None else found
    for dep in graph.get(name, []):
        if dep not in found:
            found.add(dep)
            closure(dep, found)
    return found


active = {
    name: sorted(closure(name))
    for name, location in locations.items()
    if (location.startswith(("software/host/", "software/simulator/", "software/cli/", "verif/", "firmware/", "spec/")) or "/verif/" in location or "/protocol/" in location)
    and "/archived/" not in location
}
for name, deps in active.items():
    assert "hardcaml_protemu" not in deps, (name, "active facade dependency")
for name in ("protemu_f_model", "protemu_firmware_examples", "protemu_isa", "protemu_host", "host_link_protocol", "protemu_host_link_wire"):
    assert "hardcaml" not in closure(name), (name, "lost pure boundary")
assert "hardcaml_protemu" in graph["protemu_host_link_tests"]
assert graph["protemu_firmware_examples"] == ["core", "protemu_isa"]
assert "protemu_firmware_examples" in graph["protemu_f_model"]
print(json.dumps({"active_closure_count": len(active), "pure_model": sorted(closure("protemu_f_model")), "pure_firmware": graph["protemu_firmware_examples"], "frozen_facade_dependency": graph["protemu_host_link_tests"], "active_closures": active}, indent=2, sort_keys=True))
