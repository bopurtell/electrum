"""Read-only AM3 consumer equivalence, frozen-byte and baseline hash receipt."""
import hashlib
import json
import pathlib
import re
import subprocess
import sys
import tarfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
BASE = "0bb9abc742b3eefbcaa83c39189b08d4f99cea8a"


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def digest(data):
    return hashlib.sha256(data).hexdigest()


paths = git("ls-tree", "-r", "--name-only", BASE).decode().splitlines()
frozen = [p for p in paths if p.startswith("ip/host_link/verif/archived/hl4a/")]
hardware = [
    f"ip/host_link/rtl/{name}.ml"
    for name in ("wire_crc", "wire_layout", "frame_rx", "frame_tx", "command_dispatch")
]
software = [
    p for p in paths
    if p.startswith("ip/host_link/verif/") and p.endswith(".ml")
    and p not in frozen
    and b"Protemu_host_link_wire.Wire" in git("show", f"{BASE}:{p}")
]
hashes = {}
goldens = {}
for p in paths:
    if p in frozen or p.startswith("test/host_link_wire/") or (
        p.startswith("ip/host_link/verif/") and
        ("test" in pathlib.Path(p).name or p.endswith((".expected", ".golden")))
    ):
        old = git("show", f"{BASE}:{p}")
        hashes[p] = digest(old)
        expects = re.findall(rb'\[%expect(?:_exact)?\s+\{\|.*?\|\}\]', old, re.S)
        goldens[p] = digest(b"\0".join(expects))
        if p in frozen:
            assert (ROOT / p).read_bytes() == old, p
        if p.startswith("ip/host_link/verif/"):
            current_expects = re.findall(
                rb'\[%expect(?:_exact)?\s+\{\|.*?\|\}\]',
                (ROOT / p).read_bytes(), re.S,
            )
            assert current_expects == expects, (p, "expectation bytes")

# Establish the original pre-ownership-migration tests/goldens independently of
# the AM3 git baseline, without modifying or extracting the historical archive.
ownership = ROOT / ".dev/ownership-migration/20261111-b3a4cb6-baseline"
ownership_hashes = {}
snapshot = json.loads((ownership / "source-snapshot.json").read_text())
with tarfile.open(ownership / "source-snapshot.tar.gz") as archive:
    members = {m.name.removeprefix("./"): m for m in archive.getmembers()}
    for entry in snapshot:
        old_path = entry["path"]
        if old_path.startswith(("test/host_link/", "test/host_link_wire/")):
            original = archive.extractfile(members[old_path]).read()
            assert digest(original) == entry["sha256"], old_path
            new_path = old_path.replace("test/host_link/", "ip/host_link/verif/", 1)
            baseline = git("show", f"{BASE}:{new_path}")
            # Ownership migration changed source headers/paths; expectation forms
            # are the golden oracle and must retain their exact original bytes.
            expectations = rb'\[%expect(?:_exact)?\s+\{\|.*?\|\}\]'
            assert re.findall(expectations, baseline, re.S) == re.findall(
                expectations, original, re.S
            ), (old_path, "ownership golden changed")
            ownership_hashes[old_path] = digest(original)

software_pattern = (
    r"Wire\.(Request\.(?:Encode_error|payload_fields|encode)"
    r"|Response\.(?:Decode_error|invalid_field|decode\w*)"
    r"|Crc\.(?:compute|update)|U16\.(?:get|to_bytes))"
)
for p in hardware + software:
    old = git("show", f"{BASE}:{p}").decode()
    expected = old.replace("Protemu_host_link_wire.Wire", "Host_link_protocol")
    if p in software:
        expected = re.sub(software_pattern, r"Wire.Codec.\1", expected)
    current = (ROOT / p).read_text()
    # Only path substitutions and formatter whitespace are allowed, including in
    # comments: this retains all scenario literals, expectations, seeds and timing.
    assert re.sub(r"\s+", "", current) == re.sub(r"\s+", "", expected), p
    if p in hardware:
        assert "Codec" not in current, p

for p in paths:
    if p.startswith("ip/host_link/verif/") and p.endswith(".ml"):
        if p not in software and p not in frozen:
            assert (ROOT / p).read_bytes() == git("show", f"{BASE}:{p}"), p

bundle = ROOT / "_build/default/tinytapeout/src/loader_bundle"
manifest = json.loads((bundle / "manifest.json").read_text())
source_paths = {entry["path"] for entry in manifest["source_inputs"]}
canonical_inputs = {
    f"host_link_protocol/{name}"
    for name in ("dune", "definitions.ml", "codec.ml", "host_link_protocol.ml",
                 "host_link_protocol.mli")
}
assert canonical_inputs <= source_paths
assert not any(p.startswith("host_link_wire/") for p in source_paths)
for entry in manifest["source_inputs"]:
    p = entry["path"]
    assert (bundle / "inputs" / p).read_bytes() == (ROOT / p).read_bytes(), p
    assert digest((ROOT / p).read_bytes()) == entry["sha256"], p
installed = (ROOT / "_build/default/hardcaml_protemu.dune-package").read_text()
hardware_package = re.split(r"\(name hardcaml_protemu\)\s+\(kind normal\)", installed)[1]
hardware_package = hardware_package.split("(library", 1)[0]
assert "hardcaml_protemu.host_link_protocol" in hardware_package
assert "hardcaml_protemu.host_link_wire" not in hardware_package

receipt = {
    "baseline": BASE,
    "baseline_sha256": hashes,
    "baseline_expectation_sha256": goldens,
    "original_ownership_sha256": ownership_hashes,
    "canonical_hardware_consumers": hardware,
    "canonical_software_consumers": software,
    "frozen_files_byte_identical": len(frozen),
    "loader_bundle_source_inputs_byte_identical": len(source_paths),
    "canonical_bundle_inputs": sorted(canonical_inputs),
    "result": "PASS: only canonical path substitutions and formatting; no scenario changes",
}
if "--summary" in sys.argv:
    for key in ("baseline_sha256", "baseline_expectation_sha256", "original_ownership_sha256"):
        entries = receipt[key]
        receipt[key] = {
            "files": len(entries),
            "map_sha256": digest(json.dumps(entries, sort_keys=True).encode()),
        }
print(json.dumps(receipt, indent=2))
