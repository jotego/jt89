# Design
set ::env(DESIGN_NAME) "jt89"

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/hdl/*.v]

set ::env(CLOCK_PERIOD) "10.000"
set ::env(CLOCK_PORT) "clk"

set ::env(SYNTH_MAX_FANOUT) 5
set ::env(FP_CORE_UTIL) 45
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
