#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../../.." && pwd)
output="$repo_root/asic_support/tinytapeout/src/p0_observable.v"

cd "$repo_root"
"$repo_root/scripts/with-switch.sh" dune exec -j 5 asic_support/verif/observable/emit/generate.exe -- -output "$output" -module-name p0_observable
