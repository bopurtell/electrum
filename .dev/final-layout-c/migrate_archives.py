"""One-shot, byte-preserving historical relocation; no Git or archive decoding."""
import hashlib
import json
from pathlib import Path
import stat

ROOT = Path(__file__).resolve().parents[2]
RECEIPT = Path(__file__).with_name("archive-receipt.json")
MOVES = [
    ("loader_core.v", "archive/legacy/rtl/loader_core.v"),
    ("flow_results", "archive/legacy/flow_results"),
    ("tinytapeout/reports", "archive/legacy/tinytapeout/reports"),
]


def inventory(path):
    paths = sorted(path.rglob("*")) if path.is_dir() else [path]
    result = {}
    for item in paths:
        if item.is_symlink():
            raise RuntimeError(f"unexpected historical symlink: {item}")
        if item.is_file():
            data = item.read_bytes()
            key = str(item.relative_to(path)) if path.is_dir() else "."
            result[key] = {"sha256": hashlib.sha256(data).hexdigest(),
                           "bytes": len(data), "mode": oct(stat.S_IMODE(item.stat().st_mode))}
    return result


def main():
    if RECEIPT.exists():
        receipt = json.loads(RECEIPT.read_text())
        for move in receipt["moves"]:
            assert inventory(ROOT / move["new"]) == move["before"]
        print("Historical archive bytes and modes still match the receipt")
        return
    for old, new in MOVES:
        assert (ROOT / old).exists(), old
        assert not (ROOT / new).exists(), new
    runtime = []
    for name in (".venv", ".venv-precheck", "tinytapeout/pdk", "tinytapeout/tt",
                 "tinytapeout/build", "tinytapeout/runs", "tinytapeout/artifacts",
                 "tinytapeout/tt_submission", "_flow_tools", "_flow_results"):
        path = ROOT / name
        runtime.append({"path": name, "exists": path.exists(),
                        "held_in_place": path.exists(),
                        "nonempty": any(path.iterdir()) if path.is_dir() else path.exists()})
    receipt = {"moves": [{"old": old, "new": new, "before": inventory(ROOT / old)}
                          for old, new in MOVES], "runtime": runtime}
    RECEIPT.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    for move in receipt["moves"]:
        dest = ROOT / move["new"]
        dest.parent.mkdir(parents=True, exist_ok=True)
        (ROOT / move["old"]).rename(dest)
        move["after"] = inventory(dest)
        assert move["before"] == move["after"], move["old"]
    receipt["verified"] = True
    RECEIPT.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    for move in receipt["moves"]:
        print(f'{move["old"]} -> {move["new"]}: {len(move["before"])} files; bytes/modes identical')
    print("Runtime state:", json.dumps(runtime))


if __name__ == "__main__":
    main()
