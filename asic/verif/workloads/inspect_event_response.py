#!/usr/bin/env python3
"""Public read-only consumer commands; no builds, tools or evidence publication.

inspect RESULT --json
compare --left RESULT --right RESULT --json

Exit 0: verified completed inspection / comparable pair.
Exit 1: readable incomplete result / confounded-or-unavailable pair (JSON retained).
Exit 2: invalid query/evidence. These are Protemu contracts, not ASIC Workload_result.
"""

import argparse
import json
from pathlib import Path
import sys

import event_evidence


def main(argv=None, *, stdout=None, stderr=None):
    stdout, stderr = stdout or sys.stdout, stderr or sys.stderr
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    inspect = commands.add_parser("inspect")
    inspect.add_argument("result", type=Path)
    inspect.add_argument("--json", action="store_true")
    compare = commands.add_parser("compare")
    compare.add_argument("--left", required=True, type=Path)
    compare.add_argument("--right", required=True, type=Path)
    compare.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)
    try:
        if args.command == "inspect":
            value = {"schema": "protemu.event-response-inspection", "version": 1,
                     "result_path": str(args.result.absolute()), **event_evidence.inspect(args.result)}
            code = 0 if value["measurements"] is not None else 1
            summary = f"{value['result']['status']}: {value['result']['system_boundary']}"
        else:
            value = event_evidence.compare(args.left, args.right)
            code = 0 if value["status"] == "comparable" else 1
            summary = value["status"] + ": " + "; ".join(value["reasons"])
        if args.json:
            print(json.dumps(value, indent=2, allow_nan=False), file=stdout)
        else:
            print(summary, file=stdout)
            if args.command == "compare" and code == 0:
                print("right-minus-left response ticks: " +
                      str(value["right_minus_left_response_ticks"]), file=stdout)
        return code
    except (ValueError, OSError, KeyError, TypeError, IndexError, StopIteration) as error:
        diagnostic = f"{type(error).__name__}: {error}"
        if args.json:
            print(json.dumps({"schema": "protemu.event-response-query-error", "version": 1,
                              "status": "invalid", "diagnostic": diagnostic}), file=stdout)
        else:
            print(diagnostic, file=stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
