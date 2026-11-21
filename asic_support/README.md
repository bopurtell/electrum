# ASIC support and verification

The product chip lives in [`asics/electrum/`](../asics/electrum/). This directory
holds shared Tiny Tapeout support, the Silver CLI gateway, and legacy bundle and
flow entry points.

This is checked-in source, not an installation directory. Provisioned PDKs,
Tiny Tapeout support tools, and flow virtual environments go in the ignored
`_flow_tools/` directory (or a configured external toolchain root). Flow
outputs go in `_flow_results/`.

[`verif/memory/`](verif/memory/) and [`verif/observable/`](verif/observable/) have
standalone wrappers for testing. They are not selectable chip targets in Silver.
The legacy bundle selectors still work: `loader` means the full Electrum chip;
`memory` and `observable` mean the respective verification fixtures.
