# Current hardware installation boundary: canonical owners only

This section supersedes the earlier public-facade installation/98-coercion
receipts. Those files and local installation snapshots are retained as historical
migration evidence; they do not describe the current installed API. In particular,
the old `verify.py identity` and `verify.py sources` modes belong to that superseded
phase. Current checks are implemented by `private_oracle.py`.

## Implemented boundary

- Removed `software/compatibility/hardware/` completely.
- Moved the 26-alias source adapter to
  `ip/host_link/verif/archived/support/hardcaml_protemu.ml`.
- Its local Dune library is internally named `hardcaml_protemu` solely because the
  frozen HL4a oracle names it. There is no `public_name`, install stanza, duplicate
  RTL compilation or active design/software consumer.
- Canonical hardware APIs remain `Protemu_mechanisms`,
  `Protemu_mechanisms_staging`, `Protemu_controller`, `Protemu_core`,
  `Protemu_core_legacy`, `Protemu_host_link`, `Protemu_system` and
  `Protemu_asic_bringup`, with their existing `hardcaml_protemu.*` public libraries.
- Root opam package and findlib namespace container `hardcaml_protemu` remain to
  contain the sublibraries; they expose no root OCaml module or Dune main library.

## Final proof

Evidence is under `private-oracle/`:

- `source-proof.json`: all eight frozen files (including parent format ignore)
  and all 26 RTL files remain byte-identical to their pre-removal hashes. Flat
  references are confined to the frozen oracle and its private support directory.
- `installed-proof.json`: fresh prefix, custom isolated findlib configuration,
  and eight successfully compiled/linked canonical owner consumers. Only the
  fresh installed project package plus sanitized external dependencies are on
  the search path; the workspace build tree and old installation receipts are
  excluded. All 13 installed project libraries are named sublibraries; none
  depends on the private root adapter. No flat module/archive artifacts install.
- `reject-flat-module.log` and `reject-flat-root-package-module.log`: both
  compilation probes fail with `Unbound module "Hardcaml_protemu"`, even with all
  canonical libraries available or the root findlib namespace selected.
- `dune-installed-proof.json`: separate installed-only Dune project builds all
  eight canonical consumers. A separate project using `(libraries
  hardcaml_protemu)` fails with `Library "hardcaml_protemu" not found.`
- `commands.jsonl`: exact commands, isolated working directories, exit codes and
  timings, retaining failed setup attempts as well as successful final checks.

Final source checks passed:

```
dune build @install @lint @ip/host_link/verif/archived/support/fmt -j5
dune build --force -j5 \
  @ip/host_link/verif/archived/hl4a/runtest \
  @ip/host_link/verif/endpoint/runtest \
  @ip/host_link/verif/command_dispatch/runtest \
  @ip/emulator_core/verif/core_engine/runtest \
  @software/simulator/test/runtest
```

These ran serially under the shared flock in switch `5.2.0+ox`; the final forced
suite run took 10.159 seconds. The new private adapter also passes scoped format.
The standard build installation has no `hardcaml_protemu.cmi` remaining.

No frozen source/Dune, RTL body, coordinator documentation or historical artifact
was edited. No Git mutation, provisioning or physical implementation was performed.
