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

    cart_phi2_o     : out   std_logic;
    cart_dotclock_o : out   std_logic;
    cart_dma_i      : in    std_logic;
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
end entity cart;

architecture synthesis of cart is

  signal cnt5 : std_logic_vector(4 downto 0) := (others => '0');

begin

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
    end if;
  end process cart_proc;

end architecture synthesis;

