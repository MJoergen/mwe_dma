library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mwe is
  port (
    core_clk_i      : in    std_logic;
    core_rst_i      : in    std_logic;

    fast_clk_i      : in    std_logic;
    fast_rst_i      : in    std_logic;

    uart_rx_ready_o : out   std_logic;
    uart_rx_valid_i : in    std_logic;
    uart_rx_data_i  : in    std_logic_vector(7 downto 0);
    uart_tx_ready_i : in    std_logic;
    uart_tx_valid_o : out   std_logic;
    uart_tx_data_o  : out   std_logic_vector(7 downto 0);

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
    cart_a_i        : in    std_logic_vector(15 downto 0);
    cart_a_o        : out   std_logic_vector(15 downto 0);
    cart_data_oe_o  : out   std_logic; -- 0 : tristate (i.e. input), 1 : output
    cart_d_i        : in    std_logic_vector( 7 downto 0);
    cart_d_o        : out   std_logic_vector( 7 downto 0)
  );
end entity mwe;

architecture synthesis of mwe is

  constant C_ADDR_SIZE : natural  := 12;

  signal   core_addr : std_logic_vector(C_ADDR_SIZE - 1 downto 0);
  signal   core_data : std_logic_vector(7 downto 0);

  signal   wbus_cyc   : std_logic;
  signal   wbus_stall : std_logic;
  signal   wbus_stb   : std_logic;
  signal   wbus_addr  : std_logic_vector(15 downto 0);
  signal   wbus_we    : std_logic;
  signal   wbus_wrdat : std_logic_vector(7 downto 0);
  signal   wbus_ack   : std_logic;
  signal   wbus_rddat : std_logic_vector(7 downto 0);

  signal   fast_start : std_logic := '1';
  signal   fast_busy  : std_logic;
  signal   fast_crc   : std_logic_vector(15 downto 0);
  signal   fast_cyc   : std_logic;
  signal   fast_stb   : std_logic;
  signal   fast_addr  : std_logic_vector(C_ADDR_SIZE - 1 downto 0);
  signal   fast_ack   : std_logic;
  signal   fast_rddat : std_logic_vector(31 downto 0);

  signal   fast_toggle : std_logic;

  signal   slow_toggle : std_logic;
  signal   slow_crc    : std_logic_vector(15 downto 0);

  attribute mark_debug : string;
  attribute mark_debug of slow_toggle           : signal is "true";
  attribute mark_debug of slow_crc              : signal is "true";
  attribute mark_debug of cart_phi2_o           : signal is "true";
  attribute mark_debug of cart_dotclock_o       : signal is "true";
  attribute mark_debug of cart_dma_i            : signal is "true";
  attribute mark_debug of cart_ctrl_oe_o        : signal is "true";
  attribute mark_debug of cart_ba_i             : signal is "true";
  attribute mark_debug of cart_rw_i             : signal is "true";
  attribute mark_debug of cart_io1_i            : signal is "true";
  attribute mark_debug of cart_io2_i            : signal is "true";
  attribute mark_debug of cart_addr_oe_o        : signal is "true";
  attribute mark_debug of cart_a_i              : signal is "true";
  attribute mark_debug of cart_data_oe_o        : signal is "true";
  attribute mark_debug of cart_d_i              : signal is "true";

  attribute mark_debug_clock : string;
  attribute mark_debug_clock of slow_toggle     : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of slow_crc        : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_phi2_o     : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_dotclock_o : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_dma_i      : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_ctrl_oe_o  : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_ba_i       : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_rw_i       : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_io1_i      : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_io2_i      : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_addr_oe_o  : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_a_i        : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_data_oe_o  : signal is "clk_rst_inst/core_clk_o";
  attribute mark_debug_clock of cart_d_i        : signal is "clk_rst_inst/core_clk_o";

begin

  uart_rx_ready_o <= '1';

  uart_proc : process (core_clk_i)
  begin
    if rising_edge(core_clk_i) then
      if uart_tx_ready_i = '1' then
        uart_tx_valid_o <= '0';
      end if;

      if uart_rx_valid_i = '1' then
        uart_tx_data_o  <= uart_rx_data_i;
        uart_tx_valid_o <= '1';
      end if;

      if core_rst_i = '1' then
        uart_tx_data_o  <= X"41";
        uart_tx_valid_o <= '1';
      end if;
    end if;
  end process uart_proc;

  fast_toggle     <= fast_toggle xor (not fast_busy) when rising_edge(fast_clk_i);

  slow_toggle     <= fast_toggle when rising_edge(core_clk_i);
  slow_crc        <= fast_crc when rising_edge(core_clk_i);

  cart_en_o       <= '1';
  cart_reset_oe_o <= '1'; -- Output
  cart_reset_o    <= '1';
  cart_game_oe_o  <= '0'; -- Input
  cart_game_o     <= 'Z';
  cart_exrom_oe_o <= '0'; -- Input
  cart_exrom_o    <= 'Z';
  cart_nmi_oe_o   <= '0'; -- Input
  cart_nmi_o      <= 'Z';
  cart_irq_oe_o   <= '0'; -- Input
  cart_irq_o      <= 'Z';
  cart_roml_oe_o  <= '1'; -- Output
  cart_roml_o     <= '1';
  cart_romh_oe_o  <= '1'; -- Output
  cart_romh_o     <= '1';


  master_inst : entity work.master
    port map (
      clk_i        => core_clk_i,
      rst_i        => core_rst_i,
      start_i      => '1',
      wbus_cyc_o   => wbus_cyc,
      wbus_stall_i => wbus_stall,
      wbus_stb_o   => wbus_stb,
      wbus_addr_o  => wbus_addr,
      wbus_we_o    => wbus_we,
      wbus_wrdat_o => wbus_wrdat,
      wbus_ack_i   => wbus_ack,
      wbus_rddat_i => wbus_rddat
    ); -- master_inst : entity work.master

  cart_inst : entity work.cart
    generic map (
      G_ADDR_SIZE => C_ADDR_SIZE
    )
    port map (
      clk_i           => core_clk_i,
      rst_i           => core_rst_i,
      bram_addr_o     => core_addr,
      bram_data_i     => core_data,
      wbus_cyc_i      => wbus_cyc,
      wbus_stall_o    => wbus_stall,
      wbus_stb_i      => wbus_stb,
      wbus_addr_i     => wbus_addr,
      wbus_we_i       => wbus_we,
      wbus_wrdat_i    => wbus_wrdat,
      wbus_ack_o      => wbus_ack,
      wbus_rddat_o    => wbus_rddat,
      cart_phi2_o     => cart_phi2_o,
      cart_dotclock_o => cart_dotclock_o,
      cart_dma_i      => cart_dma_i,
      cart_ctrl_oe_o  => cart_ctrl_oe_o,
      cart_ba_i       => cart_ba_i,
      cart_rw_i       => cart_rw_i,
      cart_io1_i      => cart_io1_i,
      cart_io2_i      => cart_io2_i,
      cart_ba_o       => cart_ba_o,
      cart_rw_o       => cart_rw_o,
      cart_io1_o      => cart_io1_o,
      cart_io2_o      => cart_io2_o,
      cart_addr_oe_o  => cart_addr_oe_o,
      cart_a_i        => cart_a_i,
      cart_a_o        => cart_a_o,
      cart_data_oe_o  => cart_data_oe_o,
      cart_d_i        => cart_d_i,
      cart_d_o        => cart_d_o
    ); -- cart_inst : entity work.cart

  sweeper_inst : entity work.sweeper
    generic map (
      G_ADDR_SIZE => C_ADDR_SIZE
    )
    port map (
      clk_i        => fast_clk_i,
      rst_i        => fast_rst_i,
      start_i      => fast_start,
      busy_o       => fast_busy,
      crc_o        => fast_crc,
      wbus_cyc_o   => fast_cyc,
      wbus_stall_i => '0',
      wbus_stb_o   => fast_stb,
      wbus_addr_o  => fast_addr,
      wbus_we_o    => open,
      wbus_wrdat_o => open,
      wbus_ack_i   => fast_ack,
      wbus_rddat_i => fast_rddat
    ); -- sweeper_inst : entity work.sweeper

  fast_ack <= fast_cyc and fast_stb when rising_edge(fast_clk_i);

  bram_inst : entity work.bram
    generic map (
      G_ADDR_SIZE => C_ADDR_SIZE,
      G_DATA_SIZE => 8
    )
    port map (
      a_clk_i  => core_clk_i,
      a_ce_i   => '1',
      a_addr_i => core_addr,
      a_data_o => core_data,
      b_clk_i  => fast_clk_i,
      b_ce_i   => '1',
      b_addr_i => fast_addr,
      b_data_o => fast_rddat(7 downto 0)
    ); -- bram_inst : entity work.bram

  fast_rddat(31 downto 8) <= (others => '0');

end architecture synthesis;

