# Final hardware-first layout and build ownership

2026-11-11. **Implemented and independently reviewed; owner review pending.** The owner selected singular
`asic/` and permitted an archive for historical material. This follow-up completes
the root cleanup after [ownership migration](ownership_layout.md) and AM3, and
replaces the global flat hardware assembly with enforceable IP library boundaries.
It does not group ports/change hardware, upgrade ASIC APIs or adopt SRAM.

## Fixed destination contract

| Source | Destination |
| --- | --- |
| `chip_top/` | `asic/` |
| `rtl/protemu_top.ml` | `ip/protemu_system/rtl/protemu_top.ml` |
| `lib/` hardware assembly | Owner-local wrapped libraries; no installed flat API; private frozen-oracle adapter only |
| `host/host_api.ml` | `software/host/` |
| `host/simulator_backend.ml` | `software/simulator/` |
| `bin/{protemu,sim_cli}.ml` | `software/cli/` |
| `bin/asic_bundle.ml` | `asic/cli/` |
| `bin/generate.ml` | `asic/verif/observable/emit/` |
| `bin/generate_p2.ml` | `ip/mechanisms/verif/emit/` |
| `bin/generate_core.ml` | `verif/system/emit/` (existing multi-boundary selector preserved) |
| `isa/` | `spec/isa/` |
| `host_link_protocol/` | `ip/host_link/protocol/` |
| `host_link_wire/` | `software/compatibility/host_link_wire/` |
| `f_model/` | `verif/reference/model/`, retaining its independent library |
| Selected-ISA `f_model/example_programs.ml` | `firmware/examples/`, with an explicit library/type-compatible model reexport |
| `examples/` | `software/cli/examples/`, workflow bytes preserved by correct working directory |
| Root model/software/tool tests | Their owning library's local `test/` |
| `test/backend_conformance/` | `verif/backends/conformance/` and local tests |
| `tinytapeout/` active target integration | `asic/tinytapeout/` |
| Root `flow.sh` | `asic/flow.sh` |
| Root `bootstrap.sh`, `env.sh` | `scripts/bootstrap.sh`, `scripts/env.sh` |
| `scripts/p3.4-cli-workflow.sh` | `software/cli/scripts/` |
| Root `loader_core.v` | `archive/legacy/rtl/loader_core.v` |
| Existing `flow_results/` and dated TT reports | `archive/legacy/`, preserving complete historical relative subtrees/bytes |

New generated execution outputs use `_flow_results/`; provisioned tools/runtime use
`_flow_tools/`. Existing installed or ignored runtime state is not implicitly moved
or provisioned. `.dev/` remains local installation and migration bookkeeping.
Historical archives are not unpacked/repacked or rewritten to use current paths.

## Enforced library graph

Wrapped owner libraries: `protemu_mechanisms`, `protemu_mechanisms_staging`,
`protemu_controller`, `protemu_core`, `protemu_core_legacy`, `protemu_host_link`,
`protemu_system`, and pure `protemu_asic_bringup`. ASIC-dependent RTL/project libraries
remain separate. Core depends on controller/mechanisms/ISA; host link on core/
controller/ISA/protocol; system on core/host link/controller/ISA; ASIC on the system
and resource tools. There is no reverse dependency on the compatibility facade.

No global `include_subdirs unqualified` or copy-all assembly. Following the owner's
explicit follow-up, the public flat `Hardcaml_protemu` API was removed. Only the
frozen oracle sees a private non-installed26-alias adapter at
`ip/host_link/verif/archived/support/`. Installed/new consumers select the actual
owner sublibraries. Test-library wrapping is not mechanically changed: existing
unwrapped harnesses/sweeps and frozen tests retain their explicitly audited contracts.

Root `test/` compatibility aliases are retired by updating executable replay paths.
Non-frozen path-only diagnostic expectations may change with an explicit inventory;
functional assertions, scenarios, seeds, program bytes and frozen oracles must not.
Old compositions that still run remain active owner-local compatibility, not inert
archive material. Reference-model `Firmware_*` modules are not automatically device
firmware: operation-sequence builders and independent peers remain model verification.

## Implementation and verification

Three implementation owners: (A) hardware libraries/system/compatibility facade,
(B) software/model/protocol/tests/firmware and active verification imports,
(C) ASIC/target/CLI/script/inventory/archive integration. Coordinator owns docs,
resource coordination and independent review. No Git add/commit/push/index/config
mutation. All builds serial under `../.protemu-build.lock`, switch5.2.0+ox, `-j5`,
within global20. No physical P&R, tool provisioning or API upgrade.

Use AM3's final17 RTL/six bundle roles and statistics as the hardware baseline,
with new source/hash/path maps captured before moving. Verify all481 registrations,
all frozen files, functional goldens and emitted outputs; explicit source inventories
and sandbox inputs; installed canonical/compatibility type identity; root/nested CLI
discovery; stub-only flow orchestration; archive hashes including binary tarballs;
and absence of stale active path references. New source/bundle identities are expected
and reported separately from hardware changes. Preserve baseline formatting/lint
limitations and historical evidence gaps.

## Execution record

- All destination moves above are implemented. Retired root directories are absent,
  including `lib`, `bin`, `test`, `host`, `f_model`, `isa`, `rtl`, `chip_top`,
  `host_link_protocol`, `host_link_wire`, `examples`, `tinytapeout` and `flow_results`.
  Empty directories were removed only after checking they contained no user files.
- Eight wrapped hardware-owner libraries enforce the acyclic dependency direction.
  ASIC RTL and project libraries are separate. Active software/verification uses
  canonical owners; no installed project library depends on the private oracle adapter.
- A fresh isolated installation exposes13 named sublibraries. All eight canonical
  hardware consumers compile/link through both Findlib and a separate installed-only
  Dune project. Negative probes reject `Hardcaml_protemu` and `(libraries
  hardcaml_protemu)`; no root CMI/archive installs. The opam/Findlib package remains
  a namespace container, not a flat-module compatibility promise.
- All26 hardware bodies preserve construction/logic except explicit owner aliases.
  All17 freshly generated RTL outputs and six bundle roles are byte-identical to
  AM3. Pins, constraints, resource selection and semantic package configuration
  match. Each bundle has55 verified canonical source inputs and no facade input.
- All481 registrations remain. Eight frozen files, six CLI example files, seven
  CLI goldens, the UART trace and authored firmware-example source retain their
  bytes. Six non-frozen diagnostic expectations changed only canonical path text;
  the explicit whitelist is in the verification receipt.
- All42 historical files match original committed hashes, lengths and modes,
  including five opaque tarballs. New `archive/INDEX.md` records mappings/hashes;
  old captured JSON/commands/absolute paths were not rewritten. The archive is
  excluded from Dune traversal. No old ignored runtime state required migration.
- Current commands/defaults are `asic/flow.sh`, `scripts/bootstrap.sh`,
  `scripts/env.sh`, `_flow_tools/` and `_flow_results/`. Stub-only flow checks17/17
  pass, including caller-relative overrides. Root/nested/direct-executable CLI
  discovery and shell activation/repetition/path-with-spaces controls pass.
- Integrated `@install @lint`, forced `@verification` (ordinary regression plus
  all three emitted loader tiers), `@verification-long` and
  `@verification-four-state` pass. The forced integrated run took508.77 seconds.
  All Dune invocations were sequential, shared-lock protected, `-j5`.
- Independent source/evidence review found no correctness blocker. Eighteen new
  formatting findings were corrected; all scoped formatting checks pass. Fresh
  installation/lint, affected suites and six-role/source-inventory comparisons pass
  after corrections. The same23 baseline formatter failures remain; no new ones.
- The final public-API removal changed only adapter/build ownership; all26 RTL and
  eight frozen files remain unchanged. Forced HL4a, endpoint, dispatch, core-engine
  and simulator suites pass afterward. Independent closeout confirms the installed
  negative probes, archives, registration counts and formatting closure.

### Evidence locations

| Persistent directory | Contents |
| --- | --- |
| `.dev/final-layout/hardware/` | Owner APIs/dependency graph,17 RTL/six-role comparisons, integrated commands and formatting classification |
| `.dev/final-layout/hardware/private-oracle/` | Current installed canonical consumers and negative flat-API probes |
| `.dev/final-layout-b/` | Software/model/protocol/test relocation,481 registrations, functional goldens and six-path diagnostic whitelist |
| `.dev/final-layout-c/` | ASIC/tool path map,55-input inventories, archive proof and shell/stub-flow checks |
| `.dev/final-layout-c/format-review/` | Final scoped formatting and refreshed six bundle roles |
| `.dev/final-layout-review/20261111/` | Independent review and final private-oracle/formatting closeout addendum |

Earlier public-facade proof records are historical; `hardware/CURRENT.md` and
`private-oracle/` describe the final non-installed compatibility boundary. The Git
index remains unchanged. No Git staging/commit/push/configuration mutation, physical
implementation, tool provisioning or sibling source change occurred.

### Remaining boundaries

The older supplemental simulation-role `INITIALDLY` lint failures and historical
formal/physical evidence gaps are not resolved by directory/library migration.
AM5 port grouping and responsibility review remain separate. The ASIC dependency
still uses the existing `simulation_build` API and explicit Flops policy; PT.3's
current-API/SRAM adoption has not been performed. Active legacy compositions and
the frozen oracle remain tested, while inert reports/snapshots are archived.
