#!/usr/bin/env bash
# Public named-flow/project CLI in the verified local release environment.
# Usage: bash scripts/project.sh flow list --json
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
if [[ ! -f "$root/.dev/tools/current.json" ]]; then
    echo "project: install local tools with ./scripts/bootstrap.sh --tools-only" >&2
    exit 2
fi
source "$root/scripts/env.sh"
exec dune exec --root "$root" -j10 ./asic/cli/project.exe -- "$@"
