create_clock -period 20 -name clk [get_ports clk]

create_clock -period 20 -name clk_v_in
create_clock -period 20 -name clk_v_out


set_input_delay -clock clk_v_in -max 2 [get_ports din]
set_input_delay -clock clk_v_in -min 1 [get_ports din]

set_output_delay -clock clk_v_out -max 2 [get_ports sound[*]]
set_output_delay -clock clk_v_out -min 1 [get_ports sound[*]]