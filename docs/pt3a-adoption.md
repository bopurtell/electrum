# PT.3a — public ASIC adoption and explicit program-memory variants

The [normal adoption workflow](adoption-release.md) now replaces the historical
PT.3a-only wrapper for everyday use. This record and its private-prefix identities
remain the original bounded acceptance evidence.

## Accepted bounded scope

Implemented against Electrum base `c680ed3` and deliberately selected ASIC revision
`b0b3384acbe22c8a30264cbdf0c19008c58bf3c5`. Adoption uses public
`Project.create ~source_inputs`, `Project.emit_bundle`, `Timing.create`,
`Elaboration.Context`, `Elaborated_project` and resource snapshot APIs.

The production memory and loader projects each register exactly one `program`
resource: 256×16 synchronous 1RW, read latency one, disabled output held, write
output unspecified. Existing RAM/controller construction, reset and pad wiring are
preserved. Both variants use an explicit instance rule with no fallback:

- `--selection flops`: explicit flop implementation; legacy positional forms
  remain Flops/Hardening.
- `--selection exact`: stock `RM_IHPSG13_1P_256x16_c2_bm_bist`, default Synthesis.
- `--operation synthesis|hardening` is explicit when supplied. PT.3a initially
  rejected Exact Hardening; the [PT.3c loader candidate](pt3c-physical-attempt.md)
  now enables it for loader only. Physical acceptance is still open.
- Observable remains resource-free and rejects Exact.

Synthesis here means the emitted bundle's requested operation. No synthesis tool or
physical EDA was executed for PT.3a.

## Dependency activation

The shared opam installation exposed an older ASIC API despite its path pin.
Installed the current recorded ASIC into the Electrum-owned private prefix
`.dev/pt3a-provider/prefix` after successful ASIC `@all`, cache-aware `runtest`, and
`@install` checks at `-j1`. The latest ASIC commit was verified test-only relative
to the previously qualified runtime. The shared switch installation was unchanged.

Use `bash scripts/with-private-asic.sh COMMAND ...`. It checks installed hashes,
selects the private library/binary paths, sets native thread limits and a one-job
Dune guard, and uses `.dev/pt3a-provider/consumer-build`. It fails if private state
is missing or altered; it does not install silently. The prefix and evidence are
local generated state, not source-distributed artifacts. On another machine,
install the recorded dependency and establish a matching receipt/environment
using the [ASIC consumer installation guide](../../hardcaml_asic/docs/guides/consumer-installation.md).

`.dev/pt3a-provider/receipt.json` records revision, exact source archive/inventory,
installed hashes, commands and environment. Resolution checks confirm private
`hardcaml_asic`, flow-domain and execution libraries. Provider version output is
unstamped; the external receipt supplies the exact attribution.

## Verification

Sequential commands from this checkout, each under `flock ../.electrum-build.lock`:

```sh
bash scripts/with-private-asic.sh dune build -j1 @pt3a
bash scripts/with-private-asic.sh dune runtest -j1 ip/program_memory_controller/verif/backend_integration
bash scripts/with-private-asic.sh dune runtest -j1
bash scripts/with-private-asic.sh python3 -B asic/tinytapeout/scripts/check-adopted-bundle.py --metadata-only --kind loader --selection exact
```

All passed. Focused CLI/project/RTL lint and diff checks also passed. Coverage:

- Production helper and actual memory/loader resource records, explicit policy,
  full contract, source roles and no fallback.
- Exact implementation's 11 typed collateral entries, public snapshot round-trip
  and RTL linkage to instance `hc_resource_7_program`.
- Behavioral simulation remains behavioral even with Exact selection. Synthesis
  stub and functional/timed vendor-model references are distinct.
- Independent repeated emissions match every file byte; hashes, copied source
  inputs, provenance, receipts and manifest identities agree.
- Legacy defaults equal explicit Flops. Observable has no resource; malformed
  CLI, nonempty output, policy mistakes and unsupported combinations reject.
- Existing controller/backend tests and ordinary repository regressions pass.

Retained full bundles: `.dev/pt3a-verification/focused-03-bundles/receipt.json`.
The four bundle identities at verification were:

| Design | Selection / operation | Identity |
| --- | --- | --- |
| memory | Flops / Hardening | `29cfd568950c8b81bef74fa002e0687277ef1637b7e720812b875684cfd792d7` |
| memory | Exact / Synthesis | `4609752fe28945e5fc81e008958686ccb4e1c05dff78cf475301151974323049` |
| loader | Flops / Hardening | `ab4660c9d680775e3c5dfe1d8bd3e2683c72038b24185faa0b58570b7a2745f5` |
| loader | Exact / Synthesis | `7246e1dad80b6c78c715149e29f1697493ed85b70925f688d97bb8e58e0d0b5a` |

These describe the captured modified source tree, not a clean commit. Later source
changes legitimately produce different identities. Initial failing test-harness
attempts remain preserved alongside successful receipts.

Outer builds used one job. Sampled available RAM stayed around 26 GiB or higher;
largest reported child peak RSS was about 2.36 GiB. No timeouts or killed commands.
During final consumer verification kernel-log access was denied, so absence of new
hardware faults could not independently be established. No physical EDA was run.

## Follow-up status

**PT.3b is now complete in emitted-RTL functional scope.** The
[vendor-functional system verification record](pt3b-verification.md) covers actual
macro execution, load/readback/fetch, cancellation, image lifecycle and legal
unspecified-output variation. The remaining next step is PT.3c.

The original PT.3b requirements were:

PT.3b exercises the real loader/core/program-store path using the applicable
macro functional models: loading/readback/fetch, stalls, reset/disable, image
validity, execution-time host-access rejection and unspecified-output independence.
Metadata references do not establish that the vendor model was executed.

PT.3c remains actual implemented-design/final-netlist replay with recorded timing
and check outcomes. PT.3a does not establish physical SRAM retention, placement,
timing closure, final-netlist behavior or final configuration selection.
