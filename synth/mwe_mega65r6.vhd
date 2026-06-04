library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mwe_mega65r6 is
  port (
    -- Onboard crystal oscillator = 100 MHz
    clk_i             : in    std_logic;

    -- Reset button on the side of the machine
    reset_button_i    : in    std_logic; -- Active high

    uart_rxd_i        : in    std_logic;
    uart_txd_o        : out   std_logic;

    cart_phi2_o       : out   std_logic;
    cart_dotclock_o   : out   std_logic;
    cart_dma_i        : in    std_logic;
    cart_reset_oe_n_o : out   std_logic;
    cart_reset_io     : inout std_logic;
    cart_game_oe_n_o  : out   std_logic;
    cart_game_io      : inout std_logic;
    cart_exrom_oe_n_o : out   std_logic;
    cart_exrom_io     : inout std_logic;
    cart_nmi_oe_n_o   : out   std_logic;
    cart_nmi_io       : inout std_logic;
    cart_irq_oe_n_o   : out   std_logic;
    cart_irq_io       : inout std_logic;
    cart_ctrl_en_o    : out   std_logic;
    cart_ctrl_dir_o   : out   std_logic; -- =1 means FPGA->Port, =0 means Port->FPGA
    cart_ba_io        : inout std_logic;
    cart_rw_io        : inout std_logic;
    cart_io1_io       : inout std_logic;
    cart_io2_io       : inout std_logic;
    cart_romh_oe_n_o  : out   std_logic;
    cart_romh_io      : inout std_logic;
    cart_roml_oe_n_o  : out   std_logic;
    cart_roml_io      : inout std_logic;
    cart_en_o         : out   std_logic;
    cart_addr_en_o    : out   std_logic;
    cart_haddr_dir_o  : out   std_logic; -- =1 means FPGA->Port, =0 means Port->FPGA
    cart_laddr_dir_o  : out   std_logic; -- =1 means FPGA->Port, =0 means Port->FPGA
    cart_a_io         : inout unsigned(15 downto 0);
    cart_data_en_o    : out   std_logic;
    cart_data_dir_o   : out   std_logic; -- =1 means FPGA->Port, =0 means Port->FPGA
    cart_d_io         : inout unsigned(7 downto 0)
  );
end entity mwe_mega65r6;

architecture synthesis of mwe_mega65r6 is

  signal core_clk : std_logic;
  signal core_rst : std_logic;

  signal cart_en        : std_logic;
  signal cart_reset_oe  : std_logic;
  signal cart_reset_in  : std_logic;
  signal cart_reset_out : std_logic;
  signal cart_game_oe   : std_logic;
  signal cart_game_in   : std_logic;
  signal cart_game_out  : std_logic;
  signal cart_exrom_oe  : std_logic;
  signal cart_exrom_in  : std_logic;
  signal cart_exrom_out : std_logic;
  signal cart_nmi_oe    : std_logic;
  signal cart_nmi_in    : std_logic;
  signal cart_nmi_out   : std_logic;
  signal cart_irq_oe    : std_logic;
  signal cart_irq_in    : std_logic;
  signal cart_irq_out   : std_logic;
  signal cart_roml_oe   : std_logic;
  signal cart_roml_in   : std_logic;
  signal cart_roml_out  : std_logic;
  signal cart_romh_oe   : std_logic;
  signal cart_romh_in   : std_logic;
  signal cart_romh_out  : std_logic;
  signal cart_ctrl_oe   : std_logic;
  signal cart_ba_in     : std_logic;
  signal cart_rw_in     : std_logic;
  signal cart_io1_in    : std_logic;
  signal cart_io2_in    : std_logic;
  signal cart_ba_out    : std_logic;
  signal cart_rw_out    : std_logic;
  signal cart_io1_out   : std_logic;
  signal cart_io2_out   : std_logic;
  signal cart_addr_oe   : std_logic;
  signal cart_a_in      : unsigned(15 downto 0);
  signal cart_a_out     : unsigned(15 downto 0);
  signal cart_data_oe   : std_logic;
  signal cart_d_in      : unsigned(7 downto 0);
  signal cart_d_out     : unsigned(7 downto 0);

begin

  clk_rst_inst : entity work.clk_rst
    port map (
      clk_i      => clk_i,
      rst_i      => reset_button_i,
      core_clk_o => core_clk,
      core_rst_o => core_rst
    ); -- clk_rst_inst : entity work.clk_rst

  mwe_inst : entity work.mwe
    port map (
      core_clk_i      => core_clk,
      core_rst_i      => core_rst,
      uart_rxd_i      => uart_rxd_i,
      uart_txd_o      => uart_txd_o,
      cart_en_o       => cart_en,      -- Enable port, active high
      cart_phi2_o     => cart_phi2_o,
      cart_dotclock_o => cart_dotclock_o,
      cart_dma_i      => cart_dma_i,
      cart_reset_oe_o => cart_reset_oe,
      cart_reset_i    => cart_reset_in,
      cart_reset_o    => cart_reset_out,
      cart_game_oe_o  => cart_game_oe,
      cart_game_i     => cart_game_in,
      cart_game_o     => cart_game_out,
      cart_exrom_oe_o => cart_exrom_oe,
      cart_exrom_i    => cart_exrom_in,
      cart_exrom_o    => cart_exrom_out,
      cart_nmi_oe_o   => cart_nmi_oe,
      cart_nmi_i      => cart_nmi_in,
      cart_nmi_o      => cart_nmi_out,
      cart_irq_oe_o   => cart_irq_oe,
      cart_irq_i      => cart_irq_in,
      cart_irq_o      => cart_irq_out,
      cart_roml_oe_o  => cart_roml_oe,
      cart_roml_i     => cart_roml_in,
      cart_roml_o     => cart_roml_out,
      cart_romh_oe_o  => cart_romh_oe,
      cart_romh_i     => cart_romh_in,
      cart_romh_o     => cart_romh_out,
      cart_ctrl_oe_o  => cart_ctrl_oe, -- 0 : tristate (i.e. input), 1 : output
      cart_ba_i       => cart_ba_in,
      cart_rw_i       => cart_rw_in,
      cart_io1_i      => cart_io1_in,
      cart_io2_i      => cart_io2_in,
      cart_ba_o       => cart_ba_out,
      cart_rw_o       => cart_rw_out,
      cart_io1_o      => cart_io1_out,
      cart_io2_o      => cart_io2_out,
      cart_data_oe_o  => cart_data_oe, -- 0 : tristate (i.e. input), 1 : output
      cart_d_i        => cart_d_in,
      cart_d_o        => cart_d_out,
      cart_addr_oe_o  => cart_addr_oe, -- 0 : tristate (i.e. input), 1 : output
      cart_a_i        => cart_a_in,
      cart_a_o        => cart_a_out
    ); -- mwe_inst : entity work.mwe

  cart_en_o         <= cart_en;
  cart_reset_io     <= cart_reset_out when cart_reset_oe = '1' else
                       'Z';
  cart_game_io      <= cart_game_out when cart_game_oe  = '1' else
                       'Z';
  cart_exrom_io     <= cart_exrom_out when cart_exrom_oe = '1' else
                       'Z';
  cart_nmi_io       <= cart_nmi_out when cart_nmi_oe   = '1' else
                       'Z';
  cart_irq_io       <= cart_irq_out when cart_irq_oe   = '1' else
                       'Z';
  cart_roml_io      <= cart_roml_out when cart_roml_oe  = '1' else
                       'Z';
  cart_romh_io      <= cart_romh_out when cart_romh_oe  = '1' else
                       'Z';
  cart_reset_in     <= cart_reset_io;
  cart_game_in      <= cart_game_io;
  cart_exrom_in     <= cart_exrom_io;
  cart_nmi_in       <= cart_nmi_io;
  cart_irq_in       <= cart_irq_io;
  cart_roml_in      <= cart_roml_io;
  cart_romh_in      <= cart_romh_io;
  cart_reset_oe_n_o <= not cart_reset_oe;
  cart_game_oe_n_o  <= not cart_game_oe;
  cart_exrom_oe_n_o <= not cart_exrom_oe;
  cart_nmi_oe_n_o   <= not cart_nmi_oe;
  cart_irq_oe_n_o   <= not cart_irq_oe;
  cart_roml_oe_n_o  <= not cart_roml_oe;
  cart_romh_oe_n_o  <= not cart_romh_oe;

  cart_ba_io        <= cart_ba_out when cart_ctrl_oe = '1' else
                       'Z';
  cart_rw_io        <= cart_rw_out when cart_ctrl_oe = '1' else
                       'Z';
  cart_io1_io       <= cart_io1_out when cart_ctrl_oe = '1' else
                       'Z';
  cart_io2_io       <= cart_io2_out when cart_ctrl_oe = '1' else
                       'Z';
  cart_ba_in        <= cart_ba_io;
  cart_rw_in        <= cart_rw_io;
  cart_io1_in       <= cart_io1_io;
  cart_io2_in       <= cart_io2_io;
  cart_ctrl_en_o    <= not cart_en;
  cart_ctrl_dir_o   <= cart_ctrl_oe;

  cart_d_io         <= cart_d_out when cart_data_oe = '1' else
                       (others => 'Z');
  cart_d_in         <= cart_d_io;
  cart_data_en_o    <= not cart_en;
  cart_data_dir_o   <= cart_data_oe;

  cart_a_io         <= cart_a_out when cart_addr_oe = '1' else
                       (others => 'Z');
  cart_a_in         <= cart_a_io;
  cart_addr_en_o    <= not cart_en;
  cart_haddr_dir_o  <= cart_addr_oe;
  cart_laddr_dir_o  <= cart_addr_oe;

end architecture synthesis;

