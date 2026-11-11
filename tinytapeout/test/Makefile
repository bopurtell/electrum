IVERILOG ?= iverilog
VVP ?= vvp
BUILD_DIR ?= ../build/rtl-test
# Staged projects carry tb.v; in the checkout use the chip-owned authored bench.
TESTBENCH ?= $(firstword $(wildcard tb.v ../../chip_top/verif/observable/emitted/tb.v))
SOURCES = ../src/p0_observable.v ../src/project.v $(TESTBENCH)
NETLIST ?= gate_level_netlist.v

.PHONY: rtl gate clean

rtl:
	mkdir -p $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -Wno-timescale -s tb -o $(BUILD_DIR)/p0_wrapper $(SOURCES)
	$(VVP) $(BUILD_DIR)/p0_wrapper

gate:
	test -n "$(PDK_ROOT)"
	test -f "$(NETLIST)"
	mkdir -p $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -Wno-timescale -DGL_TEST -DFUNCTIONAL -DSIM \
		-s tb -o $(BUILD_DIR)/p0_wrapper_gate \
		$(PDK_ROOT)/ihp-sg13cmos5l/libs.ref/sg13cmos5l_io/verilog/sg13cmos5l_io.v \
		$(PDK_ROOT)/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/verilog/sg13cmos5l_stdcell.v \
		$(NETLIST) $(TESTBENCH)
	$(VVP) $(BUILD_DIR)/p0_wrapper_gate

clean:
	rm -f $(BUILD_DIR)/p0_wrapper $(BUILD_DIR)/p0_wrapper_gate
