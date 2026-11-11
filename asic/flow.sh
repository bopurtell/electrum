#!/usr/bin/env bash
#
# The one command for the ASIC implementation flow.
#
#   ./asic/flow.sh                 the whole adopted flow, in a fresh output directory
#   ./asic/flow.sh STEP [STEP ...] only those steps, in the order given
#   ./asic/flow.sh --help          steps, environment overrides, and how to resume
#
# The no-argument form deliberately starts a physical run: it emits the bundle,
# hardens it with LibreLane, and runs the postchecks. That takes hours. Name the
# steps when you want only part of it.
#
# This flow consumes an environment; it never provisions one. ./scripts/bootstrap.sh
# prepares the pinned OCaml and flow tools, and `source scripts/env.sh` activates them
# for commands you type by hand. Neither is required by the flow itself: every
# step locates its own tools, and dune runs through the pinned switch.
#
# The orchestration lives in asic/tinytapeout/scripts/adopted-flow.sh, beside the
# Python runner and reporter it drives. This file is the public name for it and
# supplies the full-run default; there is no second implementation.
#
# docs/flow.md is the source of truth for this flow: stages, overrides,
# resuming, artifacts, and what has been verified about it.

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
runner="$repo_root/asic/tinytapeout/scripts/adopted-flow.sh"

# Bare ./asic/flow.sh is the full sequence. The runner keeps its own no-argument
# behavior (help), so the default is spelled out here rather than shared.
if [[ $# -eq 0 ]]; then set -- --full; fi

exec "$runner" "$@"
