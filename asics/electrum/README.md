# Electrum chip

This is the only product chip registered in the root Silver project. Its
[`rtl/`](rtl/) wrapper combines the serial loader, emulator core, and program
memory; [`flows/`](flows/) holds `flops` and `stock_sram`, two ways to implement
that same chip. Neither flow is a hardware variant.

Shared Tiny Tapeout support and the standalone memory and observable test
wrappers live under [`asic/`](../../asic/). Reusable RTL lives under
[`ip/`](../../ip/).
