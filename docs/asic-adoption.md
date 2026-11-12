# ASIC bundle adoption — PT.3a

PT.3a public-API and explicit Flops/Exact adoption is verified, and
[PT.3b real-system vendor-functional regression](pt3b-verification.md) passes. See
[PT.3a evidence and remaining gates](pt3a-adoption.md). Earlier P0 physical evidence
below remains historical; it does not qualify the new macro-backed system.

[`asic/project/chip_project.ml`](../asic/project/chip_project.ml) declares the
selectable `observable`, `memory` and `loader` Tiny Tapeout designs and their
explicit source inventory. [`asic/cli/asic_bundle.ml`](../asic/cli/asic_bundle.ml)
is the stable emission CLI. ASIC-dependent constructors/resource bindings live
in [`asic/rtl/`](../asic/rtl/), compiled as `protemu_asic_rtl`; the preserved
`protemu_chip_project` library depends on it and canonical owner libraries.

The observable design retains the pin map of
`asic/tinytapeout/src/project.v`, two-edge reset release and immediate pad release
on reset/disable. That committed wrapper, hand-maintained
`asic/tinytapeout/info.yaml` and `asic/tinytapeout/src/config.json` remain inputs
of the legacy P0 path. The adopted path consumes generated bundle equivalents.

## Dependency and emission

[`asic/tinytapeout/asic-dependencies.lock`](../asic/tinytapeout/asic-dependencies.lock)
records ASIC revision `b0b3384acbe22c8a30264cbdf0c19008c58bf3c5` and matching
collateral revisions. Emission uses `Project.emit_bundle`, with source inputs
attached through `Project.create`. Memory and loader support explicit `program`
instance policies for Flops and Exact SRAM, without fallback.

Use the recorded library revision in an isolated prefix, as described in the
[`hardcaml_asic` consumer guide](../../hardcaml_asic/docs/guides/consumer-installation.md).
The ordinary shared switch was observed to contain an older ASIC API; the verified
local installation is selected explicitly with `scripts/with-private-asic.sh`.
Its generated prefix and receipt live under `.dev/pt3a-provider/`. This wrapper
verifies installed hashes and does not perform installation. `scripts/bootstrap.sh`
prepares the general environment;
`asic/tinytapeout/toolchain.lock` records flow-tool provisioning. The emitted
manifest captures requested revisions, and adopted preflight checks the matching
consumer locks. Review lock changes explicitly when upgrading.

From the repository root, run these sequentially under the shared build lock:

```sh
flock ../.protemu-build.lock bash scripts/with-private-asic.sh dune build -j1 asic/cli/asic_bundle.exe
flock ../.protemu-build.lock bash scripts/with-private-asic.sh dune exec -j1 asic/cli/asic_bundle.exe -- \
  observable "$PWD/_flow_results/observable-bundle" "$PWD"
flock ../.protemu-build.lock bash scripts/with-private-asic.sh dune exec -j1 asic/cli/asic_bundle.exe -- \
  memory "$PWD/_flow_results/memory-bundle" "$PWD" --selection flops
flock ../.protemu-build.lock bash scripts/with-private-asic.sh dune exec -j1 asic/cli/asic_bundle.exe -- \
  loader "$PWD/_flow_results/loader-exact-bundle" "$PWD" --selection exact
```

Each output directory must be new or empty. The current inventory captures
**55 canonical inputs per package**: ASIC CLI/project/RTL, owner-library build
files/source, shared ISA/protocol, package metadata and dependency locks. It
contains no software compatibility hardware facade or reference model.
`Project.emit_bundle` receives the repository source root, and the manifest copies and
hashes these files along with recording source revision, generated files, target,
flow settings and separate synthesis/simulation source sets. Source-path/hash
changes legitimately change bundle identity without changing emitted hardware.

Use `src/<top>.v` for synthesis and `simulation/<top>.v` for simulation, never both
together. The generated `info.yaml`, `src/config.json` and `constraints/top.sdc`
are the adopted flow inputs. Project names, emitted module names and package ABI
are preserved independently of source-directory spelling.

The declaration fixes TT `6x4` / CMOS5L, the 48 MHz primary clock, current pins,
minimum/maximum I/O delays and explicit instance Flops policy by default. Exact
defaults to Synthesis; explicit loader Exact Hardening uses the
[PT.3c physical candidate](pt3c-physical-attempt.md), whose acceptance remains open.
Protected clock, source-list
and target settings reject conflicting raw overrides. The provisional P0 I/O
assumptions are 0 ns minimum input delay, 1 ns maximum input arrival and 2 ns
maximum output loading delay. Review board/host timing before claiming physical
closure; the layout migration did not requalify those assumptions.

## Checks

Metadata/declaration-only checking from the repository root:

```sh
flock ../.protemu-build.lock bash scripts/with-private-asic.sh dune build -j1 @pt3a
flock ../.protemu-build.lock bash scripts/with-private-asic.sh python3 -B \
  asic/tinytapeout/scripts/check-adopted-bundle.py --kind loader --selection exact --metadata-only
```

These checks emit twice, compare complete file-tree bytes and identities, verify source copies
and hashes, metadata/configuration/SDC and conflict rejection for
`CLOCK_PERIOD`, `VERILOG_FILES` and `DIE_AREA`.

For Flops, omit `--metadata-only` to additionally run applicable wrapper/serial-peer traces,
Verilator lint and generic Yosys synthesis in the pinned LibreLane Docker image.
The full check requires an accessible Docker daemon and cached image
`ghcr.io/librelane/librelane:3.1.0.dev3`; it never pulls the image itself. It needs
neither runtime access to an ASIC source checkout nor host HDL executables. This
is emitted-RTL checking, **not P&R or physical qualification**.

Memory mode also verifies the exact RAM identity, 256x16 shape, explicit Flops/Exact
selection and behavioral/implementation roles. Flops checks absence of initialization in
implementation RTL. Loader mode retains that contract and tests the independent
serial peer against the package RTL roles. The production wrapper check is
narrower than the full consumer contract; see
[P3.1b verification](p3.1b-verification.md) and the protocol/timing/recovery
authority in [P3.5](p3.5-hardware-loader.md).

The [P0.7 mapped-synthesis record](../archive/legacy/tinytapeout/reports/2026-09-20-p0.7-memory-synthesis.md)
predates the loader, integrated core and mechanisms. It is historical evidence,
not current production-top area or routed timing. No P3.5 physical qualification
is implied by the package/RTL checks.

## Running the flow

[`./asic/flow.sh`](../asic/flow.sh) consumes the adopted bundle. Setup is
`./scripts/bootstrap.sh` and per-shell `source scripts/env.sh`. Tool/runtime state
is `_flow_tools/{venv,precheck-venv,pdk,tt,toolchain-env.sh}`; execution outputs
default to `_flow_results/{adopted,flow-*,archives}`. Stages, overrides, resuming,
failure behavior and archiving are specified in **[flow.md](flow.md)**.

`adopted-flow.sh` does not automatically invoke the adoption checker. Bundle
contract checks and physical execution evidence are separate obligations.

## Historical physical evidence and current qualification

The first adopted physical run is preserved at
[P0.5b](../archive/legacy/flow_results/20260918-230920-05f65042/README.md).
The qualifying clean-staging observable reproduction is
[P0.5c](../archive/legacy/flow_results/20260920-081325-ccecd9ed/README.md): its
recorded committed source, isolated locked-library prefix, complete preserved
input bundle, full hardening, TT precheck and observable gate simulation passed.
See its [dated experiment record](../archive/legacy/tinytapeout/reports/2026-09-20-p0.5c-clean-staging-physical.md).

These September 2026 results are the last recorded full physical qualification.
The 2026-11-11 layout work preserved all historical archive bytes and metadata;
the [external relocation index](../archive/INDEX.md) maps their old paths/hashes.
Historical `bin/asic_bundle.ml` now maps to `asic/cli/asic_bundle.ml` plus the
extracted `asic/project/` declaration; old `tinytapeout/` maps to
`asic/tinytapeout/`. Commands inside dated records intentionally remain unchanged.

The layout migration validated orchestration with **17 stub checks** and checked
nonphysical build/RTL/bundle preservation, including six unchanged emitted bundle
roles and current canonical source hashes. It did not provision the relocated
tool environment or rerun P&R/precheck/physical signoff. Those historical
observable results therefore do not establish physical closure of today's loader
production top or requalify the relocated runtime defaults.
