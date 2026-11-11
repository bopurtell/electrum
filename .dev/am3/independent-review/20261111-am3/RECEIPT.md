# Independent AM3 review — 2026-11-11

## Decision and scope

**Bounded AM3 clearance: no implementation/correctness blocker found.** Reviewer
implemented none of AM3 and changed no authored source. Coordinator documentation
is being reworked and is not judged as a completed status record by this receipt.
This clearance concerns pure protocol/Codec extraction, source compatibility,
mechanical consumer migration, and preservation at the recorded output boundaries.
It does not accept later AM/VO work or imply removal of the frozen archive.

Reviewed canonical `host_link_protocol/{definitions.ml,codec.ml,
host_link_protocol.ml,host_link_protocol.mli,dune}`, shim `host_link_wire/{wire.ml,
dune}`, active hardware/agent/endpoint consumers, both pure suites, source lists,
saved original Wire, extraction/pure-verification handoffs, supplemental differential
harness, installed-consumer fixture, and the integrated-final receipt/raw evidence.

## Independent source findings

Original Wire snapshot is identical to Git revision
`0bb9abc742b3eefbcaa83c39189b08d4f99cea8a:host_link_wire/wire.ml`, SHA-256:

`23b46d8a57f5bd7ee7e36ce15221f7bbcf1d1c297f18b256bc2e8d6c515dcb9f`.

`review.py` independently recomputes extraction and evidence comparisons. Its
normalization retains every byte of string literals and removes only comments and
outside-string whitespace. Results in `extraction.json`:

- All retained definitions, constructors, records, derived functions, constants,
  enum ordering, payload layouts, shape types/table and correlations match the
  original after removal of the moved software declarations.
- All **13 moved helper/function bodies** and both error declarations/derivers
  match the original, allowing only necessary `Definitions.Crc.length` and
  `Definitions.U16.max` qualifications. Those qualified values are unchanged.
- CRC implementation remains software-only and separate from the hardware CRC.
  U16 helper semantics remain unchecked and little-endian; no new narrowing,
  overflow policy or memory-size restriction was inserted.
- Shim has no function/type implementation. It includes the canonical root and
  merges the four software modules back into the old Crc/U16/Request/Response
  locations. There is one production implementation of each definition/helper.

### Validation/order review

Direct inspection and body identity confirm:

1. Encoding checks tag first, then payload fields in the original wire order;
   first-field error, bounds and field labels are unchanged.
2. Response decoding checks minimum frame size, magic, version, declared payload
   upper bound, exact byte count, CRC, defined result, legal command/result shape,
   shape length, then payload fields in the original order.
3. INFO checks wire major, minor, then capabilities; unfamiliar ISA/layout descriptor
   data remains readable. STATUS checks flags, fault kind, then phase; bit-list
   order and reserved-value rejection are unchanged.
4. Correlation is checked only after successful decoding. Malformed-frame errors
   do not become correlation errors. Well-formed refusals remain response values;
   zero echo, unknown commands, STOP pending and VERIFY mismatch shape distinctions
   retain their original semantics.

Moving the pure response-shape table before the decoder error module adds no state
or observable initialization effect.

## Public API and dependency boundaries

- Canonical Dune name: `host_link_protocol`; installed/public package:
  `hardcaml_protemu.host_link_protocol`; consumer root: `Host_link_protocol`.
  The explicit root implementation/interface introduces no doubled
  `Host_link_protocol.Host_link_protocol` namespace.
- Root exports vocabulary/layouts/types, CRC parameters, U16 bound, and legal
  response shapes. `Codec` exports byte functions and errors, using the same
  Definitions types; it does not declare a second protocol type family.
- Root `.mli` preserves the shared Definitions aliases/type equalities. All four
  installed canonical source/interface files match authored bytes. Reviewed the
  retained and freshly rerun external consumer, including bidirectional canonical/
  legacy request, response, payload, correlation, shape and error assignments.
- Canonical and shim Dune dependencies are `core` and, for the shim, canonical.
  The installed dependency evidence contains no hardware, ISA, ASIC, emulator,
  simulator or agent dependency. Core/PPX transitive runtimes are not a new hardware
  dependency or a new verification framework.
- All five hardware consumers use root definitions only and have no Codec call.
  Active software/verification callers explicitly use Codec paths. Independent
  normalization proves only canonical path substitutions/formatting in the
  migrated consumers; scenario literals, seeds, timing and expectations remain.
- Remaining old namespace/dependency references are confined to the shim's Dune
  declaration, frozen archive testbench/Dune, and explicit pure compatibility
  test/Dune. See `remaining-legacy-references.json`.

## Tests and supplemental pure evidence

Independently verified **481 total registrations**, including **32 pure tests**:
the original 26, five new canonical boundary tests, and one compatibility test.
Reversing API substitutions recovers the complete original 26-test source modulo
outside-string formatting/comments; independent vectors and string bytes match.
All eight frozen archive files, including Dune and its formatting exclusion, match
the AM3 Git baseline. See `consumers-tests.json`.

Reviewed the supplemental `verify-pure.py` harness and its handoff, rather than
repeating its builds. It compares the SHA-verified saved implementation with the
canonical implementation, not the new shim with itself. Inputs use separately
written literal framing/bit-serial CRC. Its category accounting totals **2,242,474**
comparisons across requests, command/result/length combinations, correlations,
masks/enums, versions, byte mutations and length errors. The **30** negative
compilation probes cover 13 byte functions plus two error modules in each of the
public root and actual internal Definitions module, with a positive compile first
and expected diagnostic classes checked.

These supplemental runs are recorded pure-verification results, not independently
rerun results or an exhaustive proof over arbitrary byte strings. Original fixed
expected vectors and independent emitted HDL peer remain separate oracles.

## Integrated evidence and provenance validation

`evidence-validation.json` records independent checks against raw retained files:

- **340 current non-documentation source hashes** still match the exact source
  tree used for integrated-final verification. Intentional coordinator docs are
  excluded. The 56-source pre-AM3 correspondence map matches Git bytes at 0bb9abc.
- **17 fresh standalone RTL outputs**, **six bundle RTL roles**, metadata/resources,
  pins/config/constraints and all current copied source/file hashes verify against
  the established ownership-baseline chain.
- All six actual fresh generic-synthesis complete design-statistics objects equal
  saved baseline under identical Yosys creator identity. Simulation/synthesis cell
  totals: observable 62/62; memory 9211/13550; loader 22536/26814. All deltas zero.
- Loader inventory is **47 inputs**, replacing the two shim inputs with the full
  five canonical source/interface/Dune inputs. Observable/memory inventories remain
  11/12. Canonical source tree dependencies are present in TT Dune rules; production
  bundle checker requires the canonical closure and excludes the shim from loader
  inputs. Historical copied inputs/status/provenance were not rewritten to pretend
  old sources used the canonical API.
- Recorded install/lint, forced ordinary regression and completed forced RTL retry
  exit zero. The completed RTL log contains all **three** independent loader PASS
  records. Interrupted/failed helper attempts remain explicitly distinguished.
- Git HEAD, index and config match the integrated run's starting identities. No
  staging/history/configuration or installed-dependency mutation was performed by
  this review. No sibling files were edited.

No builds, EDA, physical flow, provisioning, formatter or differential/compile-probe
rerun was needed. Only read-only Python/file/Git comparisons ran:

```text
python3 -B .dev/am3/independent-review/20261111-am3/review.py
```

## Compatibility policy recommendations for coordinator documentation

1. Document canonical import/package names above and use `Host_link_protocol` for
   definitions and `Host_link_protocol.Codec` for software operations. Do not call
   generated `Host_link_protocol__*` modules supported consumer APIs.
2. Explicitly describe the old `hardcaml_protemu.host_link_wire` /
   `Protemu_host_link_wire.Wire` API as a **temporary source-compatibility facade**.
   It preserves old paths, helper availability, type/error identity and behavior;
   it is not a promise that previously compiled OCaml clients can be linked without
   rebuilding against changed library interfaces.
3. New/live code should not acquire shim dependencies. Keep the shim while frozen
   HL4a and transitional external consumers need it. Removal needs an explicit
   consumer/deprecation decision and owner-approved archive retirement/migration;
   AM3 clearance does not itself authorize either removal.
4. Root/Codec separation is ownership, not a wire-version change. Current principal
   operations are typed request encoding and response decoding/correlation, not a
   new request decoder/response encoder or transport/retry scheduler. Preserved
   public low-level helpers retain their preconditions; callers should not infer
   full malformed-frame validation from direct `decode_info`, `decode_status` or
   unchecked U16 helper calls.
5. Retain independent fixed vectors and independent HDL peer ownership. Differential
   preservation, source identity and generic synthesis are not new protocol
   correctness, formal-equivalence or physical-signoff claims.

## Remaining limitations

Global `@fmt` retains **23 baseline formatter failures**, with identical formatter
edits; 22 files are byte-identical and the remaining dispatcher only changes its
canonical module alias. There is no introduced formatting failure. The two older
supplemental Simulation-role `INITIALDLY` lint failures were not rerun or claimed
fixed. Existing historical formal/physical evidence gaps, later AM5/AM6/VO scope,
and newer ASIC API/SRAM adoption remain separate from this bounded AM3 clearance.
