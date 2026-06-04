library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

library xpm;
  use xpm.vcomponents.all;

entity clk_rst is
  port (
    clk_i      : in    std_logic; -- System Clock, 100 MHz
    rst_i      : in    std_logic;

    core_clk_o : out   std_logic;
    core_rst_o : out   std_logic;

    fast_clk_o : out   std_logic;
    fast_rst_o : out   std_logic
  );
end entity clk_rst;

architecture synthesis of clk_rst is

  signal pll_fb       : std_logic;
  signal pll_core_clk : std_logic;
  signal pll_fast_clk : std_logic;
  signal pll_locked   : std_logic;

begin

  mmcme2_base_inst : component mmcme2_base
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLKFBOUT_MULT_F    => 10.0,   -- 1000 MHz
      CLKFBOUT_PHASE     => 0.000,
      CLKIN1_PERIOD      => 10.0,   -- INPUT @ 100 MHz
      CLKOUT0_DIVIDE_F   => 32.000, -- OUTPUT @ 31.25 MHz
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT0_PHASE      => 0.000,
      CLKOUT1_DIVIDE     => 4,      -- OUTPUT @ 250 MHz
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT1_PHASE      => 0.000,
      DIVCLK_DIVIDE      => 1,
      REF_JITTER1        => 0.010,
      STARTUP_WAIT       => FALSE
    )
    port map (
      clkin1   => clk_i,
      clkfbin  => pll_fb,
      rst      => rst_i,
      pwrdwn   => '0',
      clkout0  => pll_core_clk,
      clkout1  => pll_fast_clk,
      clkfbout => pll_fb,
      locked   => pll_locked
    ); -- mmcme2_base_inst : component mmcme2_base


  bufg_core_inst : component bufg
    port map (
      i => pll_core_clk,
      o => core_clk_o
    ); -- bufg_core_inst


  bufg_fast_inst : component bufg
    port map (
      i => pll_fast_clk,
      o => fast_clk_o
    ); -- bufg_fast_inst


  xpm_cdc_sync_core_inst : component xpm_cdc_sync_rst
    generic map (
      DEST_SYNC_FF => 2,
      INIT         => 1
    )
    port map (
      src_rst  => not pll_locked,
      dest_clk => core_clk_o,
      dest_rst => core_rst_o
    ); -- xpm_cdc_sync_core_inst

  xpm_cdc_sync_fast_inst : component xpm_cdc_sync_rst
    generic map (
      DEST_SYNC_FF => 2,
      INIT         => 1
    )
    port map (
      src_rst  => not pll_locked,
      dest_clk => fast_clk_o,
      dest_rst => fast_rst_o
    ); -- xpm_cdc_sync_fast_inst

end architecture synthesis;

