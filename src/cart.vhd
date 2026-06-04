library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- Drive the MEGA65 (C64) Cartridge port.
-- Include support for DMA.

entity cart is
  generic (
    G_ADDR_SIZE : natural
  );
  port (
    clk_i           : in    std_logic;
    rst_i           : in    std_logic;
    bram_addr_o     : out   std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    bram_data_i     : in    std_logic_vector(7 downto 0);

    -- Wishbone bus Slave interface
    wbus_cyc_i      : in    std_logic;                     -- Valid bus cycle
    wbus_stall_o    : out   std_logic;
    wbus_stb_i      : in    std_logic;                     -- Strobe signals / core select signal
    wbus_addr_i     : in    std_logic_vector(15 downto 0); -- lower address bits
    wbus_we_i       : in    std_logic;                     -- Write enable
    wbus_wrdat_i    : in    std_logic_vector(7 downto 0);  -- Write Databus
    wbus_ack_o      : out   std_logic;                     -- Bus cycle acknowledge
    wbus_rddat_o    : out   std_logic_vector(7 downto 0);  -- Read Databus

    cart_phi2_o     : out   std_logic;
    cart_dotclock_o : out   std_logic;
    cart_dma_i      : in    std_logic;
    cart_ctrl_oe_o  : out   std_logic;                     -- 0 : tristate (i.e. input), 1 : output
    cart_ba_i       : in    std_logic;
    cart_rw_i       : in    std_logic;
    cart_io1_i      : in    std_logic;
    cart_io2_i      : in    std_logic;
    cart_ba_o       : out   std_logic;
    cart_rw_o       : out   std_logic;
    cart_io1_o      : out   std_logic;
    cart_io2_o      : out   std_logic;
    cart_addr_oe_o  : out   std_logic;                     -- 0 : tristate (i.e. input), 1 : output
    cart_a_i        : in    std_logic_vector(15 downto 0);
    cart_a_o        : out   std_logic_vector(15 downto 0);
    cart_data_oe_o  : out   std_logic;                     -- 0 : tristate (i.e. input), 1 : output
    cart_d_i        : in    std_logic_vector( 7 downto 0);
    cart_d_o        : out   std_logic_vector( 7 downto 0)
  );
end entity cart;

architecture synthesis of cart is

  type   state_type is (IDLE_ST, BUSY_ST);
  signal state : state_type                  := IDLE_ST;

  signal cnt5 : std_logic_vector(4 downto 0) := (others => '0');

  signal wbus_addr  : std_logic_vector(15 downto 0);
  signal wbus_we    : std_logic;
  signal wbus_wrdat : std_logic_vector(7 downto 0);

begin

  wbus_stall_o    <= '1' when cart_dma_i /= '1' else
                     '1' when cnt5 /= "00000" else
                     '1' when state /= IDLE_ST else
                     '0';

  wbus_proc : process (clk_i)
  begin
    if rising_edge(clk_i) then
      wbus_ack_o   <= '0';
      wbus_rddat_o <= (others => '0');

      case state is

        when IDLE_ST =>
          if wbus_stall_o = '0' and wbus_cyc_i = '1' and wbus_stb_i = '1' then
            wbus_addr  <= wbus_addr_i;
            wbus_we    <= wbus_we_i;
            wbus_wrdat <= wbus_wrdat_i;

            if wbus_addr_i(15 downto 8) = X"DF" then
              state <= BUSY_ST;
            else
              -- Just return if not accessing I/O2
              wbus_ack_o <= '1';
            end if;
          end if;

        when BUSY_ST =>
          if cnt5 = "00000" then
            wbus_rddat_o <= cart_d_i;
            wbus_ack_o   <= '1';
            state        <= IDLE_ST;
          end if;

      end case;

      if rst_i = '1' then
        state <= IDLE_ST;
      end if;
    end if;
  end process wbus_proc;

  bram_addr_o     <= cart_a_i(G_ADDR_SIZE - 1 downto 0);

  cnt5            <= std_logic_vector(unsigned(cnt5) + 1) when rising_edge(clk_i);

  cart_phi2_o     <= cnt5(4); -- 1 MHz
  cart_dotclock_o <= cnt5(1); -- 8 MHz

  cart_proc : process (all)
  begin
    cart_ctrl_oe_o <= '1';               -- Output
    cart_ba_o      <= '1';
    cart_rw_o      <= '1';
    cart_io1_o     <= '1';
    cart_io2_o     <= '1';
    cart_addr_oe_o <= '1';               -- Output
    cart_a_o       <= X"FFFC";
    cart_data_oe_o <= '0';               -- Input
    cart_d_o       <= (others => 'Z');

    if cart_dma_i = '0' then
      cart_addr_oe_o <= '0';             -- Input
      cart_a_o       <= (others => 'Z');
      cart_data_oe_o <= '1';             -- Output
      cart_d_o       <= bram_data_i;
    elsif state = BUSY_ST then
      cart_addr_oe_o <= '1';             -- Output
      cart_a_o       <= wbus_addr;
      cart_data_oe_o <= not wbus_we;
      cart_d_o       <= wbus_wrdat;
      cart_rw_o      <= not wbus_we;
      cart_io2_o     <= '0';
    end if;
  end process cart_proc;

end architecture synthesis;

