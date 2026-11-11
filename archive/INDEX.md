# Historical material — relocation index

2026-11-11 final-layout migration. This index is outside the historical trees.
The original records retain their bytes, metadata text, old paths and identities.
Nothing was unpacked/repacked, regenerated, or rewritten to describe today's layout.
`archive/dune` makes every child directory data-only.

| Old path/prefix | New path/prefix | Files |
| --- | --- | ---: |
| `loader_core.v` | `archive/legacy/rtl/loader_core.v` | 1 |
| `flow_results/` | `archive/legacy/flow_results/` | 34 |
| `tinytapeout/reports/` | `archive/legacy/tinytapeout/reports/` | 7 |

The per-file table below records **before SHA-256 = after SHA-256**: both were
measured, not inferred from a successful rename. All 42 file modes were `0664`
before and after. The source/destination prefixes above plus each relative name
give the exact old/new path map. The five `.tar.gz` files were moved as opaque
bytes. Local full before/after receipts and the narrowly scoped rename helper
are in `.dev/final-layout-c/`; this index is the durable preservation record.

No legacy ignored runtime state was present at migration: root `.venv` and
`.venv-precheck`, or `tinytapeout/{pdk,tt,build,runs,artifacts,tt_submission}`.
Nothing was moved or provisioned there. New execution output defaults to
`_flow_results/{adopted,flow-*,archives}`; new tool/runtime state is `_flow_tools/`.

## Root RTL snapshot

| Old relative name | Bytes | Before SHA-256 = after SHA-256 |
| --- | ---: | --- |
| `loader_core.v` | 895852 | `dfb870cf40267029fb3bc3ddd78b4f9ec31a625c5602716aed3c2d894005c035` |

## Flow records (relative to old/new flow-results prefix)

| Relative name | Bytes | Before SHA-256 = after SHA-256 |
| --- | ---: | --- |
| `20260918-230920-05f65042/README.md` | 4378 | `6398e42c5fb8eeb7ed18a7f93263475784d12eed838177108b03d66bb9610590` |
| `20260918-230920-05f65042/archive.json` | 9636 | `cb1c9594adec6a7aa92513617cddb0c0f239cda02e15c90fcafaed016ee99c6f` |
| `20260918-230920-05f65042/manifest.json` | 12855 | `8cc2c3971db7b7417ff9d351e58e49ab95902a81055a7098949ece644503ebcf` |
| `20260918-230920-05f65042/postcheck.json` | 4395 | `51329ad1ba837984f2fbb6ba1a4662aee239fed80e4eba7afd99360206e6b394` |
| `20260918-230920-05f65042/preflight.json` | 2979 | `54d45af92c2748f110df5b344c04454aa90b7b9620cc8c3d5fdf0b0bec41052f` |
| `20260918-230920-05f65042/reports.tar.gz` | 731278 | `c54463bb32879920f1ca8f81c32ab6ce29f84147c0f0dccaef0ff9e75753ad56` |
| `20260918-230920-05f65042/results.json` | 13149 | `63d469f60b11db2b391b977a32240987f108ca4b68f368c648de3906bcf047eb` |
| `20260918-230920-05f65042/run.json` | 4295 | `511acf8951098053e0d2e3179da36ee6b894d42c5812e7793606b62972dd5529` |
| `20260920-071538-a538212c/README.md` | 7584 | `c937dad03786ec89515d09be18f70016011f964a87ee4c97a65c5aa48ec369a8` |
| `20260920-071538-a538212c/archive.json` | 2354 | `8b387bf01ac757af9dbc510e14dc1c2c7d2b945626f57ad2190bc6624008adb7` |
| `20260920-071538-a538212c/input-bundle.sha256` | 86 | `9381de08608151f2a670236490c7c146db8568bc509e8997d6668414923f63e4` |
| `20260920-071538-a538212c/input-bundle.tar.gz` | 36318 | `e9221b06d1af65a7826ad6c65d37d1e6467e52edb50c825c2ea5bdcf1aca9fd0` |
| `20260920-071538-a538212c/manifest.json` | 16933 | `3b72dfe6ac6179ca0081266acebba1b7c9a8093c3461b19d250db2ea6eaff398` |
| `20260920-071538-a538212c/preflight.json` | 2979 | `53b4984a30620f72aa75a38bc74b24eb14272ee712e622f55c84a891c3fbc124` |
| `20260920-071538-a538212c/reports.tar.gz` | 831488 | `eae8e52ae1cbc70eaf46d76fdcdba9f007db50d065dcdce3c58111411c7b46bc` |
| `20260920-071538-a538212c/results.json` | 7947 | `8ec6833b9feffdf18b28850fc5a848df835e5560d3526a18d045b5bb08ccfc34` |
| `20260920-071538-a538212c/run.json` | 4349 | `7cfcc77d8787467f17ed58f27468fd61d33e866f8487a378dbdef7687ee7e9e6` |
| `20260920-081325-ccecd9ed/README.md` | 9278 | `ff71b4ff4ea20bb1f8864473b50a935ada44d401a8ad363e942f9ddd74e31829` |
| `20260920-081325-ccecd9ed/adoption-check.log` | 41458 | `1936fa110bbc70e8b045be67b0eee6df946da33b36fba13b54331867d64ea5b0` |
| `20260920-081325-ccecd9ed/archive.json` | 9650 | `160d40af8b215934346a4eed38724f35840d968430bb438b87f5814ceaffeb25` |
| `20260920-081325-ccecd9ed/build.log` | 224 | `85236213685a5f4dc270336f42b98fdb222aa14c4c18e3c1a69008542a823f3e` |
| `20260920-081325-ccecd9ed/emit-preflight.log` | 3854 | `9796bed55ac32ca2852a5e1ccdbff13e9e5314fe117c8bf58e49aac78efebbae` |
| `20260920-081325-ccecd9ed/input-bundle.tar.gz` | 13546 | `a159f110b25f88d649a317425ac8d5a736bb6ef80c56ad530fab793cb7bb5da3` |
| `20260920-081325-ccecd9ed/manifest.json` | 15945 | `adc6edfd3ba8b34edd799b0c31f76bb5f477f128447ebc2ab255be7abe7ab922` |
| `20260920-081325-ccecd9ed/postcheck-driver.log` | 5989 | `5d84023fdfe07e533cfdd42716f46fba539efbf895039b73ee30874a400c5e35` |
| `20260920-081325-ccecd9ed/postcheck.json` | 4549 | `db8f57e584f987b318228e2547b4cc46c814f8effe94fa23b10842091d08fb83` |
| `20260920-081325-ccecd9ed/preflight.json` | 2979 | `53b4984a30620f72aa75a38bc74b24eb14272ee712e622f55c84a891c3fbc124` |
| `20260920-081325-ccecd9ed/reports.tar.gz` | 731630 | `6f8ba879a1c1db10c0bef7ed6ff3faea202b488ddc3058c6835890dcc5019d51` |
| `20260920-081325-ccecd9ed/restore-preflight.log` | 2979 | `53b4984a30620f72aa75a38bc74b24eb14272ee712e622f55c84a891c3fbc124` |
| `20260920-081325-ccecd9ed/restore-validation.log` | 205 | `31d4214eb7cb6180b093bcc3dc7742973a758ce3c6a2585cea5b6c80126f72e3` |
| `20260920-081325-ccecd9ed/restored-preflight.json` | 2979 | `53b4984a30620f72aa75a38bc74b24eb14272ee712e622f55c84a891c3fbc124` |
| `20260920-081325-ccecd9ed/results.json` | 13303 | `674d5bd61b7dd03c010c7051a7e592d65c7948322b07e401db30c61af77e9b2f` |
| `20260920-081325-ccecd9ed/run-driver.log` | 1504 | `7f05bf79e1a204c1cff398f8bb7784a5d1168189fc0381db6d1ee4271b4b15fa` |
| `20260920-081325-ccecd9ed/run.json` | 4309 | `4f6058f4be09961558c7d124ecf7476277daf8db760f46d3aedac9f1d859b6a3` |

## Target reports (relative to old/new reports prefix)

| Relative name | Bytes | Before SHA-256 = after SHA-256 |
| --- | ---: | --- |
| `2026-09-14-p0-tool-path.md` | 3652 | `ead2fdc458a6d6b2468269b04f26a773144b7beb8228a735e2e942441ff8cb98` |
| `2026-09-19-p0.5a-legacy-physical.md` | 6423 | `bfe372731624302b257c3fd64a9c41df66cff95f4b5f668547883bd5d98b7a66` |
| `2026-09-19-p0.5b-adopted-physical.md` | 7236 | `a3fdeccc1c395380f68d5cd0e51267e0988eddf5776b4c2e9fc3e010b0357d9d` |
| `2026-09-19-p0.6-adopted-bundle-check.md` | 7987 | `6a87d0d414f52f02c337999d01767d312f4b19a194f16b7bce93ad9d0601255f` |
| `2026-09-20-p0.5c-clean-staging-physical.md` | 3230 | `73f576bd4f5b05f7ad275a3588131d5853e8cb42274d7f87e615aff68acb5e85` |
| `2026-09-20-p0.7-memory-synthesis.md` | 9663 | `a33a5fd566332595b4924eb9524eb12fa359b87c8d702e1677b89d904002cb4f` |
| `README.md` | 3020 | `44b559e4b1e700f2fe86ceb7392c4c125b60fef5b6e4ceced5b8f1f88ac0ae93` |
