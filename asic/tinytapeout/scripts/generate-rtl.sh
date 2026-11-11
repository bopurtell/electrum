#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../../.." && pwd)
output="$repo_root/asic/tinytapeout/src/p0_observable.v"

cd "$repo_root"
"$repo_root/scripts/with-switch.sh" dune exec -j 5 asic/verif/observable/emit/generate.exe -- -output "$output" -module-name p0_observable
