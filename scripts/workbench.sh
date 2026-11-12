#!/usr/bin/env bash
# Explicit normal project environment and Workbench commands.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source "$root/scripts/env.sh"
exec python3 "$root/scripts/workbench.py" "$@"
