
create_generated_clock -name core_clk         [get_pins  clk_rst_inst/mmcme2_base_inst/CLKOUT0];
create_generated_clock -name fast_clk         [get_pins  clk_rst_inst/mmcme2_base_inst/CLKOUT1];

