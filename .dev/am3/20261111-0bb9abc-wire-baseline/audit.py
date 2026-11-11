"""Read-only AM3 source-preservation audit against the captured exact baseline."""
import hashlib
from pathlib import Path
import re

here = Path(__file__).resolve().parent
root = here.parents[2]
old = (here / "wire.ml").read_text()
assert hashlib.sha256((here / "wire.ml").read_bytes()).hexdigest() == "23b46d8a57f5bd7ee7e36ce15221f7bbcf1d1c297f18b256bc2e8d6c515dcb9f"
assert hashlib.sha256((here / "dune").read_bytes()).hexdigest() == "6283886dfeb36994c18e84ce87b370cc894702b05f55870131593351f6fd1d3d"

def uncomment(text):
    return re.sub(r"\(\*.*?\*\)", "", text, flags=re.S)

def normalized(text):
    return re.sub(r"\s+", "", uncomment(text))

moved = {
    "Crc": ["update", "compute"],
    "U16": ["to_bytes", "get"],
    "Request": ["payload_fields", "encode"],
    "Response": ["invalid_field", "decode_bits", "decode_enum", "decode_info",
                 "decode_status", "decode", "decode_correlated"],
}

def module(text, name):
    return re.search(rf"^module {name} = struct\n(.*?)^end", text, re.S | re.M)[1]

def function(text, name):
    return re.search(rf"^  let {name}\b.*?(?=^  (?:let |module |type )|\Z)",
                     uncomment(text), re.S | re.M)[0]

codec = (root / "host_link_protocol/codec.ml").read_text()
for owner, error in [("Request", "Encode_error"), ("Response", "Decode_error")]:
    pattern = rf"^  module {error} = struct\n.*?^  end"
    before = re.search(pattern, module(old, owner), re.S | re.M)[0]
    after = re.search(pattern, module(codec, owner), re.S | re.M)[0]
    assert normalized(before) == normalized(after), (owner, error)
    print(f"unchanged error type/derivers: {owner}.{error} -> Codec.{owner}.{error}")
for owner, names in moved.items():
    for name in names:
        before = function(module(old, owner), name)
        after = function(module(codec, owner), name)
        after = after.replace("Definitions.Crc.length", "Crc.length")
        after = after.replace("Definitions.U16.max", "U16.max")
        assert normalized(before) == normalized(after), (owner, name)
        print(f"unchanged implementation: {owner}.{name} -> Codec.{owner}.{name}")

definitions = uncomment(old)
for owner, names in moved.items():
    body = module(definitions, owner)
    original = body
    for name in names:
        body = body.replace(function(original, name), "")
    for error in ["Encode_error", "Decode_error"]:
        body = re.sub(rf"^  module {error} = struct\n.*?^  end\n", "", body,
                      flags=re.S | re.M)
    definitions = definitions.replace(original, body)
actual = (root / "host_link_protocol/definitions.ml").read_text()
assert normalized(definitions) == normalized(actual), "protocol definitions changed"
print("All retained protocol definitions/types/layouts/constants: unchanged")
print("Baseline exact-copy hashes: PASS")
