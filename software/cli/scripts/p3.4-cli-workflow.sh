#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
cd "$root/software/cli"

output="$root/_build/p3.4-cli"
mkdir -p "$output"
"$root/scripts/with-switch.sh" dune exec -j 5 protemu -- sim write-echo-image \
  -output "$output/p3.4-echo.pimg"
cmp examples/p3.4-echo.pimg "$output/p3.4-echo.pimg"
"$root/scripts/with-switch.sh" dune exec -j 5 protemu -- sim script \
  examples/p3.4-workflow.sim -trace-capacity 8
"$root/scripts/with-switch.sh" dune exec -j 5 protemu -- sim script \
  examples/p3.4-transfer-timeout.sim >"$output/p3.4-transfer-timeout.output"
cmp test/p3.4-transfer-timeout.expected "$output/p3.4-transfer-timeout.output"
