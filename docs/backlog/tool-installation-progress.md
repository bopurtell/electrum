# Tool installation progress

Status: Implemented — verified 2026-11-13

Implemented in `scripts/install-tools.py` and `scripts/install_progress.py`.
See [installation usage](../adoption-release.md#installation-progress).
Verification: 28 focused installer/progress tests, activation regression tests,
`dune runtest -j2 scripts`, and `dune build -j10 @all` passed. A real pinned
ASIC/Workbench installation completed in generation
`16bdaa24d96249c78b507fe467787361`, including resumes after command-runner timeouts.
The real run exercised the old-pin fallback; upstream delegation is additionally
covered by fake-command contract tests. Tests cover partial-line output,
failures, SIGINT/SIGTERM, nested cleanup, and capture/publication resume paths.

## Problem

`scripts/install-tools.py` prints each command, then redirects its stdout and
stderr to `.dev/tools/generations/<id>/build.log`. Long builds and tests appear
inactive. The user wants visible progress, whether readable stage summaries or
live raw output, without needing to discover and follow the log manually.

## Ownership and scope

Electrum owns source capture, revision selection, the Dune build/test/install
sequence, log handling, receipts, and activation. This installer invokes Dune
directly against captured ASIC and Workbench sources; it is not a thin wrapper
around an ASIC installer. This item covers the local OCaml tools installation.

Related upstream item:
[ASIC long-running operation progress](../../../hardcaml_asic/docs/backlog/operation-progress.md).
ASIC owns progress emitted within its individual tests and tool operations.

## Proposed work

- Print named stages for capture, build, test, install, inventory, and selection,
  identifying ASIC versus Workbench and showing elapsed time and outcome.
- Print the generation and log path before lengthy work starts.
- Stream subprocess output to the terminal while retaining the complete build
  log; use Dune's `--display short` for readable output and offer `--verbose` for
  full commands/output.
- Make silent long-running stages visibly active with elapsed-time updates,
  without inventing percentage completion.
- On failure, identify the stage, command, exit status, and retained log.
- Keep redirected/CI output readable and keep `--activation` stdout exclusively
  shell-evaluable output; progress must not contaminate that interface.

## Acceptance

- A fresh install and a resumed install expose their current stage and log path.
- A slow subprocess produces visible output before it exits; quiet work still
  reports activity. Both stdout and stderr are retained in the log.
- Success, failure, and interruption report accurate outcomes without selecting
  an incomplete installation or losing existing receipt/resume behavior.
- Default and verbose output work in terminals and redirected logs, and
  `source scripts/env.sh` continues to work without progress text in activation
  output.
