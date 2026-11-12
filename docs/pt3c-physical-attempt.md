# PT.3c — first implemented loader candidate, 2026-11-12

**Later follow-up:** [normal adoption closeout](adoption-release.md) records the
successful separate Magic control/recheck, one opt-in timing-repair candidate
(slow slack −3.0998 ns), and installed Workbench timing reinspection. The original
run described below remains failed with its original findings and hashes.

## Status: functional replay passes; physical acceptance remains open

One fresh actual-loader Exact Hardening run produced routed artifacts. The provider
record remains **failed**: nine Magic findings were not dispositioned, and the slow
corner fails 48 MHz setup. Independent replay of that exact final netlist passes
all 18 system scenarios. Neither the functional pass nor LibreLane's `Flow complete`
message changes the physical failure. No second physical attempt was launched.

## Declaration and preparation

Loader-only Exact Hardening is now supported; memory-only Exact Hardening remains
rejected. The candidate uses the stock 256×16 `program` SRAM at **(40,480) µm, R0,
halo2**, in the TT T6x4 die `[0,0,1289.28,710.64]`. Its expanded footprint is
`[38,478,278.8,600.78]`. This upper-left candidate follows target pin geometry and
leaves space below the macro signal pins. Its x coordinate aligns supported power
access; example placement/timing was not treated as Protemu acceptance.

The provider owns generated PDN settings. Exact Synthesis/Hardening implementation
RTL, behavioral RTL and SDC were verified byte-equal, with deterministic repeated
emission. Existing hardware, single-cycle memory behavior and 48 MHz constraints
were preserved. No pipeline, false path or multicycle exception was introduced.

The 0–1 ns input and 0–2 ns output envelope remains **provisional** for asynchronous
interfaces. Loader clock is sampled data, not a generated clock. Current typed
timing APIs cannot faithfully represent every existing clear/inversion/vector
synchronizer and macro-bearing execution; no artificial registrations were added.

Pre-launch `@pt3a`, current `@pt3b` (nine positive/nine negative), and prepared
48 MHz functional replay passed. Serial bench host timing now scales with its
selected system period; default 10 ns behavior remains unchanged. Macro monitors
sample the actual macro clock, including the final CTS leaf.

## Exact retained run

Paths below are relative to this checkout:

```text
BASE = _flow_results/pt3c/physical-20261112T033732Z
ATTEMPT = BASE/execution-01
RUN = ATTEMPT/runs/20261112T033931965658Z_0d5ed7ff
FLOW = RUN/project/runs/asic

run_id: 0d5ed7ff0dfb4e44bcb6459bbb251fca
bundle: a022ff28a1733f39aa07fa278fd59832601efed79118ba5e06bdf9b0b468abe1
provider: b0b3384acbe22c8a30264cbdf0c19008c58bf3c5, private receipt/hash-bound
PDK: 2bbec755dc67ca3db0261c3d6163e15735d66710
TT: d66cf179e7bc4d296362ab7e2e3b344dc3c4f665
```

The supported macro route is coarse `run --stage full`; segmented stop-at-timing
does not support this SRAM. The attempt took about 23m45s. `BASE/closeout.json`
inventories reports/artifacts/resources/cleanup; `ATTEMPT/outcome.json` and
`RUN/run.json` retain the failed outcome.

Final netlist:

```text
FLOW/final/nl/tt_um_leemperor_hardcaml_protemu_loader.nl.v
SHA256 61bd658ea1794aff066a2a4b6a364bee5ec8793cd145b10f9fb170f930528f8d
```

## Timing result and diagnosis

| Corner | Worst setup slack | Setup violations | Worst hold slack | Hold violations |
| --- | ---: | ---: | ---: | ---: |
| Fast | +10.6746 ns | 0 | +0.0705 ns | 0 |
| Slow | **−4.0586 ns** | **503** | +0.5291 ns | 0 |
| Typical | +5.2672 ns | 0 | +0.2202 ns | 0 |

Slow TNS: −1025.2167 ns. Raw authority: `FLOW/final/metrics.json` and
`FLOW/56-openroad-stapostpnr/`, especially slow `max.rpt` and `violator_list.rpt`.

All 503 violating paths in the inspected list launch at SRAM `A_DOUT[8]`. The worst
endpoint `_18105_/Q` maps to `loader$frame_tx$reg_response_store[143]`. The cone
crosses live instruction/base-word selection, register-index/read selection,
mechanism/FIFO decisions, execution/access control and response publication.
Failures also reach execution registers/descriptors and all SRAM address/control
feedback signals. A response-only pipeline would not fix the full set.

Worst-path increments: SRAM clock-to-output 5.205 ns, logic 9.869 ns, buffers
8.460 ns, hold cell 0.641 ns, reported interconnect 0.197 ns. Wire load still
affects cell delay/buffering. The mapped path traverses a broad region; shared
early decode/distribution is a better first target than arbitrary macro relocation.
No false-path sensitizability proof was established.

These are internal synchronous paths, not external-delay failures. Relaxing I/O
delays would not fix them. Mapping used `AREA 0`; post-GRT timing repair was
disabled. Electrical/long-wire repair inserted 1,234 buffers under the provider's
200 µm policy. Intermediate reports are typical-only; positive slack there does
not establish slow-corner optimization coverage.

**Next timing investigation:** confirm optimization-corner coverage and evaluate
supported post-GRT timing repair with unchanged hardware, target, electrical limits
and SDC. Then consider cycle-equivalent decode/control simplification if needed.
Extra pipeline stages require a separate architectural decision.

## Physical checks and Magic triage

Routing DRC, real-GDS KLayout DRC, antenna, and reported LVS differences/errors are
zero. LVS remains abstract macro-boundary/CDL scope. Slew/capacitance pass all three
corners. PDN geometry records all three supply contacts. These results do not
override unresolved Magic/setup findings.

Magic reports **2 M2.f and 7 M3.f** markers beside stock wide-OBS edges. The existing
classifier fails before generating diagnostic controls:

```text
Magic marker is not a unique stock obstruction influence-band artifact
```

The first rejected M2 marker overlaps the obstruction by only 0.975 µm, below its
>10 µm criterion. Three M3 markers end exactly on the macro's X boundary, outside
the strict-interior predicate. These geometries produce zero qualifying matches,
not multiple macros. Marker/net attribution used byte-identical Magic/final DEF.

Markers correlate with routed signal metal within the 0.6 µm wide-metal influence
band. Two M3 markers overlap Metal4 power-neck regions in XY, but no Via3 was
found at those crossings; XY overlap alone is not a short. The standalone stock
baseline's 106 M2.d pin-area findings do not match these nine.

**Next Magic investigation:** add boundary/projection fixtures, then run controls
on disposable copies of this same routed DEF: stock LEF must reproduce all nine;
removing only exact wide M2 OBS must leave seven M3; removing only wide M3 must
leave two M2; removing both must leave zero. Preserve pins, other obstructions,
routes and bridges. This case is plausible but **not dispositioned**. Loosening
inequalities or citing KLayout=0 is insufficient evidence to change acceptance.

## Final-netlist functional replay

Public postcheck correctly refused the failed run, exit2:
`postcheck requires a completed full flow`. Its receipt remains separate:

```text
_flow_results/pt3c/public-postcheck-attempt-0d5ed7ff/receipt.json
```

Independent artifact replay verifies bundle→staged-input→run→final-netlist
associations, unique macro/public-port binding, provider/model inventories and
source stability. It checks the derived standard-cell functional view against
original vendor sources, covering all **41 used cell types**. Unchanged SRAM
wrapper/core and stock UDP models complete the closure.

At the prepared 48 MHz simulation period, the same final-netlist executable:

- Passes all 18 Exact scenarios, six refusals, four witnessed cancellations,
  **4,783 reads and 51 writes**.
- Rejects deliberate expected readback mismatch (`1234` versus `1235`) with exit1
  and no positive completion marker.

Receipts:

```text
_flow_results/pt3c/routed-replay-0d5ed7ff-04/result.json
_flow_results/pt3c/routed-replay-0d5ed7ff-04/replay/receipt.json
```

They retain `original_run_status=failed`, `physical_signoff=failed`, and
`public_postcheck_acceptance=false`. This is zero-delay digital functionality,
not SDF, timed-SRAM, metastability or 48 MHz physical qualification.

## Tooling and execution limits

- `asic/verif/physical/pt3c_execution.py`: inspect/freeze, explicit preflight/full
  execution, persistent supervisor, monitor/cancel and owned cleanup. No arguments
  prints help; full execution requires explicit selection/resource allocation.
- `asic/verif/implemented/check_implemented.py`: prepare self-contained bench,
  audit successful public postcheck, and replay.
- `asic/verif/implemented/replay_routed.py`: separate failed-run artifact replay,
  never fabricated public acceptance.
- `asic/verif/implemented/check_prephysical.py`: 48 MHz prephysical smoke.

Execution-wrapper fixtures: 18 pass; implemented-replay fixtures: 26 pass.
Physical allocation was tool6, Docker CPU6, STA1, with no concurrent builds; this
is not a six-OS-task guarantee. Builds used `-j1`. Across 738 physical samples,
available RAM stayed above 25.53 GiB and disk near 500 GiB. The captured accessible
kernel interval had no matching new hardware/OOM/I/O error messages; historical
host faults are not claimed resolved. Owned processes/containers exited and the
shared lock is released. No Git attribution mutations occurred.
