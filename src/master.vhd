library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity master is
  port (
    clk_i        : in    std_logic;
    rst_i        : in    std_logic;
    start_i      : in    std_logic;
    wbus_cyc_o   : out   std_logic;                     -- Valid bus cycle
    wbus_stall_i : in    std_logic;
    wbus_stb_o   : out   std_logic;                     -- Strobe signals / core select signal
    wbus_addr_o  : out   std_logic_vector(15 downto 0); -- lower address bits
    wbus_we_o    : out   std_logic;                     -- Write enable
    wbus_wrdat_o : out   std_logic_vector(7 downto 0);  -- Write Databus
    wbus_ack_i   : in    std_logic;                     -- Bus cycle acknowledge
    wbus_rddat_i : in    std_logic_vector(7 downto 0)   -- Read Databus
  );
end entity master;

architecture synthesis of master is

  type     state_type is (IDLE_ST, BUSY_ST);
  signal   state : state_type         := IDLE_ST;

  type     addr_vector_type is array (natural range <>) of std_logic_vector(15 downto 0);

  type     data_vector_type is array (natural range <>) of std_logic_vector(7 downto 0);

  constant C_ADDRS : addr_vector_type := (
                                           X"DF02", X"DF03",          -- C64 base address
                                           X"DF04", X"DF05", X"DF06", -- REU base address
                                           X"DF07", X"DF08",          -- transfer length
                                           X"DF09",                   -- interrupt mask
                                           X"DF0A",                   -- address control
                                           X"DF01");                  -- command

  constant C_DATAS : data_vector_type := (
                                           X"00", X"00",              -- C64 base address
                                           X"00", X"00", X"00",       -- REU base address
                                           X"00", X"10",              -- transfer length
                                           X"00",                     -- interrupt mask
                                           X"00",                     -- address control
                                           X"90");                    -- command : C64 -> REU

  signal   idx : natural range 0 to C_ADDRS'length;

begin

  state_proc : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if wbus_ack_i = '1' then
        wbus_cyc_o <= '0';
      end if;

      if wbus_stall_i = '0' then
        wbus_stb_o   <= '0';
        wbus_addr_o  <= (others => '0');
        wbus_we_o    <= '0';
        wbus_wrdat_o <= (others => '0');
      end if;

      case state is

        when IDLE_ST =>
          if start_i = '1' then
            idx   <= 0;
            state <= BUSY_ST;
          end if;

        when BUSY_ST =>
          if wbus_cyc_o = '0' and idx < C_ADDRS'length then
            wbus_cyc_o   <= '1';
            wbus_addr_o  <= C_ADDRS(idx);
            wbus_wrdat_o <= C_DATAS(idx);
            wbus_stb_o   <= '1';
            wbus_we_o    <= '1';
            idx          <= idx + 1;
          end if;

          if wbus_cyc_o = '0' and idx = C_ADDRS'length then
            state <= IDLE_ST;
          end if;

      end case;

      if rst_i = '1' then
        wbus_cyc_o   <= '0';
        wbus_stb_o   <= '0';
        wbus_addr_o  <= (others => '0');
        wbus_we_o    <= '0';
        wbus_wrdat_o <= (others => '0');
        state        <= IDLE_ST;
      end if;
    end if;
  end process state_proc;

end architecture synthesis;

