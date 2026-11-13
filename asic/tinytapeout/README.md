# Tiny Tapeout target integration

This directory owns target collateral and physical-flow helpers. Authored ASIC
RTL, the typed project declaration, and package verification live in sibling
`asic/rtl/`, `asic/project/`, and `asic/verif/`; reusable hardware belongs to its
IP owner. The bundle CLI is [`asic/cli/asic_bundle.ml`](../cli/asic_bundle.ml).

The repository-root spelling of the flow command is **`./asic/flow.sh`**. Its one
orchestration implementation is [`scripts/adopted-flow.sh`](scripts/adopted-flow.sh).
Run commands below from the repository root unless a historical block says
otherwise:

```sh
./scripts/bootstrap.sh --check
./scripts/bootstrap.sh
source scripts/env.sh
./asic/flow.sh --help
```

Bare `./asic/flow.sh` runs the whole physical sequence and can take hours. The
bootstrap prepares tools; normal flow invocation consumes them. See
**[the flow guide](../../docs/flow.md)** for stages, overrides, resuming, artifacts
and qualification status, and [the environment guide](../../docs/environment.md)
for setup.

**Qualification:** September 2026 P0.5b/P0.5c records establish historical
observable-top physical results. The 2026-11-11 layout migration checked the
orchestration with stubs and preserved emitted RTL/bundles; it ran no fresh P&R,
precheck or physical qualification. Those historical results do not establish
physical closure of the current loader production top.

## Ownership and ASIC integration

The [accepted ASIC architecture](../../../hardcaml_asic/docs/architecture.md)
supplies elaboration, resource selection, target resolution and build/flow
artifacts. Electrum owns its design constructors, wrapper/reset/disable behavior,
TT/CMOS5L target request, clocks/I/O assumptions, pin meanings and resource policy.
The adapter derives metadata, source lists, constraints and configuration from
one immutable build and rejects conflicting protected overrides.

[`asic/project/chip_project.ml`](../project/chip_project.ml) declares
`observable`, `memory` and `loader`; [`asic/rtl/`](../rtl/) supplies their
ASIC-dependent package compositions. `electrum_chip_project` depends on the
separate `electrum_asic_rtl` library and canonical IP libraries. See
[ASIC adoption](../../docs/asic-adoption.md) and the
[construction plan](../../docs/construction-plan.md).

Program memory remains explicitly selected Flops with the existing contract.
The old ASIC `Bundle.render ~simulation_build` API is retained. SRAM adoption and
an ASIC API upgrade are separate work, not consequences of this layout.

## Target and pinned upstream inputs

The competition-linked
[CMOS5L template](https://github.com/TinyTapeout/ttihp-verilog-template/tree/cmos5l)
and [competition rules](https://blog.janestreet.com/protocol-emulator-asic-competition/)
select `6x4`. A possible future `8x4` allocation requires an explicit reviewed
target update.

These upstream selections were inspected/pinned on 2026-09-14; exact values
remain in [`toolchain.lock`](toolchain.lock):

| Item | Recorded selection |
| --- | --- |
| Template | `TinyTapeout/ttihp-verilog-template`, `cmos5l`, `b86a2a781484bcab7ba522dc5de540086695a430` |
| GDS/precheck/gate-level action | `TinyTapeout/tt-gds-action`, `ihp-cmos5l`, `3412659307918422f3f0727917cf9b499aaca588` |
| PDK | `ihp-sg13cmos5l`, IHP-Open-PDK `2bbec755dc67ca3db0261c3d6163e15735d66710` |
| Support tools | `da63c9927411e3aca350977d653d24bbf5bca972` |
| LibreLane | `3.1.0.dev3` |
| Historical upstream execution environment | Ubuntu 24.04, Python 3.11 |

Sources: [template workflow](https://github.com/TinyTapeout/ttihp-verilog-template/blob/cmos5l/.github/workflows/gds.yaml)
and [build action](https://github.com/TinyTapeout/tt-gds-action/blob/ihp-cmos5l/action.yml).
`ihp-sg13g2` is a different target. The selected support-tools revision contains the
`6x4` entry and `tt_block_6x4_pgvdd.def`; helpers validate revision, tile data and
DEF hash rather than silently choosing newer collateral.

## Build-to-physical boundary

```text
Canonical Hardcaml owners + asic/project declaration
  -> Dune builds asic/cli/asic_bundle.exe
  -> hardcaml_asic emits immutable RTL, constraints, metadata and manifest
  -> adopted runner stages the bundle for the pinned target tools
  -> LibreLane/Yosys/OpenROAD perform mapped synthesis and physical implementation
  -> postchecks, collected execution records, reports and archive
```

The PDK supplies cell models, timing libraries, geometry and physical rules.
Hardcaml/HDL simulation and generic synthesis establish different properties from
placement/routing, timing and physical signoff. The exact checks enabled depend
on the recorded process/flow configuration; inspect those records rather than
assuming every possible DRC/LVS tool ran.

### Host prerequisites

Bootstrap detects prerequisites and prints guidance; an administrator installs
host packages and configures runtime/group access. A typical Ubuntu starting
point is:

```sh
sudo apt install git make gawk python3 python3-venv \
                 docker.io libcairo2 iverilog verilator yosys
sudo usermod -aG docker "$USER"   # then log out and back in
```

OCaml/Dune/Hardcaml use switch `5.2.0+ox`. Python packages use
`_flow_tools/venv`; precheck uses `_flow_tools/precheck-venv` because its
KLayout/gdstk pins conflict with the main requirements. The bootstrap validates
external support-tools checkouts without modifying them.

[`scripts/precheck.sh`](scripts/precheck.sh) uses the upstream Nix-pinned native
tools and verifies their versions. Nix is a precheck prerequisite; host-installed
OpenROAD/OpenSTA/KLayout/Magic are not substitutes for pinned flow tools. For the
selected process, upstream precheck runs KLayout checks; supplying Magic in the
shell does not mean a Magic check ran. [`scripts/nix-pin.sh`](scripts/nix-pin.sh)
sets `NIX_PATH` from upstream's own pin. On systems restricting Nix daemon use,
configure the appropriate group membership and log in again.

## Directory and runtime ownership

```text
asic/
  cli/asic_bundle.ml       bundle command
  project/                 typed declaration and explicit canonical source inventory
  rtl/                     ASIC package/resource bindings; pure bringup child library
  verif/                   authored package peers, P0 tests and P0 emitter
  flow.sh                  public flow entry point
  tinytapeout/
    info.yaml              legacy hand-maintained metadata
    src/                   committed P0 RTL/wrapper/config and generation rules
    test/                  compatibility HDL targets and staged-project Makefile
    docs/info.md           legacy Tiny Tapeout user documentation
    scripts/               adopted orchestration and legacy physical helpers
    toolchain.lock         selected upstream tool/PDK/collateral revisions
    asic-dependencies.lock recorded ASIC library/collateral revisions
_flow_tools/               ignored venv, precheck-venv, pdk, tt, toolchain-env.sh
_flow_results/             ignored adopted/, flow-*/, archives/; legacy staging
archive/legacy/            preserved historical flow results, reports and root RTL
```

Keep authored hardware with its canonical owner. Authored HDL benches are not
duplicated here: Dune consumes `asic/verif/`, IP-local verification and
`verif/system/emitted/`. The committed P0 RTL is checked for deterministic
regeneration. Generated adopted bundle metadata/configuration is not a second
project authority. Existing ignored runtime state is never implicitly relocated.

### Support tools and legacy staging

Bootstrap prefers an explicit `TT_SUPPORT_TOOLS_DIR`, then the sibling checkout
`../tt-support-tools-cmos5l` relative to the repository root, otherwise manages
`_flow_tools/tt`. The adopted runner also supports `ELECTRUM_TT` and the other
overrides documented in [flow.md](../../docs/flow.md#environment).

Explicitly prepare the legacy staged project with:

```sh
TT_SUPPORT_TOOLS_DIR=/absolute/path/to/tt-support-tools-cmos5l \
  ./scripts/bootstrap.sh --legacy-project
```

It is staged under `_flow_results/legacy/p0-staged`, with a validated `tt` link.
The adopted path instead uses its emitted bundle and a per-attempt run directory.
GitHub discovers workflows at root `.github/workflows/`; upstream composite
actions expect a template-shaped project. A nested workflow or shell working
directory alone does not satisfy that shape. Submission export remains explicit.

## Wrapper and constraints

The [template interface](https://github.com/TinyTapeout/ttihp-verilog-template/blob/cmos5l/src/project.v)
contains `ui_in[7:0]`, `uo_out[7:0]`, `uio_in[7:0]`, `uio_out[7:0]`,
`uio_oe[7:0]`, `clk`, `rst_n` and `ena`; output enables are active high.
Current package pin meanings and the 48 MHz clock/I/O assumptions are declared in
`asic/project/chip_project.ml`, not inferred from the legacy metadata. Review
board timing, asynchronous paths, synchronizer/reset behavior and physical
constraints separately. Core clock alone does not establish a protocol rate.

## Historical measurements and current path mappings

The following command block is **historical**, from the former `tinytapeout/`
working directory and root `.venv`/target-local PDK layout. It is retained as the
context of the 2026-09-17 area estimate, not a current quickstart:

```sh
# Generic: relative cell and flop counts, no PDK needed.
../.venv/bin/yowasp-yosys -p "read_verilog src/p0_observable.v; synth -flatten -top p0_observable; stat"

# Liberty-mapped: approximate CMOS5L cell area, needs the staged PDK.
lib=pdk/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/lib/sg13cmos5l_stdcell_typ_1p20V_25C.lib
../.venv/bin/yowasp-yosys -p "read_verilog src/p0_observable.v; synth -flatten -top p0_observable; \
  dfflibmap -liberty $lib; abc -liberty $lib; opt_clean; stat -liberty $lib"
```

That recorded liberty-mapped estimate was 170 cells/about 2,952 µm² for
`p0_observable`, not a new result. Today's root-relative mappings are
`_flow_tools/venv/bin/yowasp-yosys`, `_flow_tools/pdk/...`, and
`asic/tinytapeout/src/p0_observable.v`. Neither generic nor Liberty-only estimates
are full physical/timing qualification.

## Work tracking and evidence

Use [the phase plan](../../docs/phase_plan.md#3-p0--make-the-tool-path-real) for
work tracking and [ASIC adoption](../../docs/asic-adoption.md) for bundle checks.
The preserved [experiment-record format](../../archive/legacy/tinytapeout/reports/README.md)
explains build identity versus execution evidence. Historical records are in
[`archive/legacy/tinytapeout/reports/`](../../archive/legacy/tinytapeout/reports/),
with physical artifacts in
[`archive/legacy/flow_results/`](../../archive/legacy/flow_results/).
The [external relocation index](../../archive/INDEX.md) records unchanged hashes;
old commands inside those records intentionally retain their historical paths.

Current checks from the repository root:

```sh
./asic/tinytapeout/scripts/check-flow.sh  # stub orchestration, no physical tools
flock ../.electrum-build.lock ./scripts/with-switch.sh dune build -j5 asic/cli/asic_bundle.exe
python3 asic/tinytapeout/scripts/check-adopted-bundle.py --metadata-only
```

The full bundle checker additionally runs HDL simulation/lint/generic synthesis
and requires the pinned Docker image; it does not run P&R. Legacy
`dune exec -j5 electrum -- check` invokes
`asic/tinytapeout/scripts/check-p0.sh` and also stages legacy inputs. Neither a
stub orchestration pass nor emitted-RTL checks replace a fresh physical run.
