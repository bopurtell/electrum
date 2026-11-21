#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../../.." && pwd)

"$repo_root/asic_support/tinytapeout/scripts/generate-rtl.sh"
make -C "$repo_root/asic_support/tinytapeout/test" rtl
