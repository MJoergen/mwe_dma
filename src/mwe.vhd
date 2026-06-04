library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mwe is
  port (
    core_clk_i      : in    std_logic;
    core_rst_i      : in    std_logic;

    uart_rxd_i      : in    std_logic;
    uart_txd_o      : out   std_logic;

    cart_en_o       : out   std_logic; -- Enable port, active high
    cart_phi2_o     : out   std_logic;
    cart_dotclock_o : out   std_logic;
    cart_dma_i      : in    std_logic;
    cart_reset_oe_o : out   std_logic;
    cart_reset_i    : in    std_logic;
    cart_reset_o    : out   std_logic;
    cart_game_oe_o  : out   std_logic;
    cart_game_i     : in    std_logic;
    cart_game_o     : out   std_logic;
    cart_exrom_oe_o : out   std_logic;
    cart_exrom_i    : in    std_logic;
    cart_exrom_o    : out   std_logic;
    cart_nmi_oe_o   : out   std_logic;
    cart_nmi_i      : in    std_logic;
    cart_nmi_o      : out   std_logic;
    cart_irq_oe_o   : out   std_logic;
    cart_irq_i      : in    std_logic;
    cart_irq_o      : out   std_logic;
    cart_roml_oe_o  : out   std_logic;
    cart_roml_i     : in    std_logic;
    cart_roml_o     : out   std_logic;
    cart_romh_oe_o  : out   std_logic;
    cart_romh_i     : in    std_logic;
    cart_romh_o     : out   std_logic;
    cart_ctrl_oe_o  : out   std_logic; -- 0 : tristate (i.e. input), 1 : output
    cart_ba_i       : in    std_logic;
    cart_rw_i       : in    std_logic;
    cart_io1_i      : in    std_logic;
    cart_io2_i      : in    std_logic;
    cart_ba_o       : out   std_logic;
    cart_rw_o       : out   std_logic;
    cart_io1_o      : out   std_logic;
    cart_io2_o      : out   std_logic;
    cart_addr_oe_o  : out   std_logic; -- 0 : tristate (i.e. input), 1 : output
    cart_a_i        : in    unsigned(15 downto 0);
    cart_a_o        : out   unsigned(15 downto 0);
    cart_data_oe_o  : out   std_logic; -- 0 : tristate (i.e. input), 1 : output
    cart_d_i        : in    unsigned( 7 downto 0);
    cart_d_o        : out   unsigned( 7 downto 0)
  );
end entity mwe;

architecture synthesis of mwe is

  signal cnt5 : std_logic_vector(4 downto 0) := (others => '0');

begin

  cnt5            <= std_logic_vector(unsigned(cnt5) + 1) when rising_edge(core_clk_i);

  cart_en_o       <= '1';
  cart_phi2_o     <= cnt5(4); -- 1 MHz
  cart_dotclock_o <= cnt5(1); -- 8 MHz
  cart_reset_oe_o <= '1';     -- Output
  cart_reset_o    <= '1';
  cart_game_oe_o  <= '0';     -- Input
  cart_game_o     <= 'Z';
  cart_exrom_oe_o <= '0';     -- Input
  cart_exrom_o    <= 'Z';
  cart_nmi_oe_o   <= '0';     -- Input
  cart_nmi_o      <= 'Z';
  cart_irq_oe_o   <= '0';     -- Input
  cart_irq_o      <= 'Z';
  cart_roml_oe_o  <= '1';     -- Output
  cart_roml_o     <= '1';
  cart_romh_oe_o  <= '1';     -- Output
  cart_romh_o     <= '1';
  cart_ctrl_oe_o  <= '1';     -- Output
  cart_ba_o       <= '1';
  cart_rw_o       <= '1';
  cart_io1_o      <= '1';
  cart_io2_o      <= '1';
  cart_addr_oe_o  <= '1';     -- Output
  cart_a_o        <= X"FFFC";
  cart_data_oe_o  <= '0';     -- Input
  cart_d_o        <= (others => 'Z');

end architecture synthesis;

