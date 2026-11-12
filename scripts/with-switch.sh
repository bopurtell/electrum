#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# Ordinary project commands use the validated local compiler/library selection.
# Explicit historical switch-only commands can still use opam exec directly.
source "$root/scripts/env.sh"
exec "$@"
