#!/usr/bin/env bash
# Explicit, fail-closed activation of the locally checked private ASIC provider.
# Usage: bash scripts/with-private-asic.sh dune build -j1 <target>
# This wrapper does not install anything. The receipt is local generated state.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
exec python3 "$root/scripts/private-asic-env.py" "$@"
