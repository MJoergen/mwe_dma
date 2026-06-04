library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std_unsigned.all;

-- Generic Dual-Port Block RAM, with simple initialization pattern.

entity bram is
  generic (
    G_ADDR_SIZE : natural;
    G_DATA_SIZE : natural
  );
  port (
    a_clk_i  : in    std_logic;
    a_ce_i   : in    std_logic;
    a_addr_i : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    a_data_o : out   std_logic_vector(G_DATA_SIZE - 1 downto 0);

    b_clk_i  : in    std_logic;
    b_ce_i   : in    std_logic;
    b_addr_i : in    std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    b_data_o : out   std_logic_vector(G_DATA_SIZE - 1 downto 0)
  );
end entity bram;

architecture synthesis of bram is

  type   ram_type is array (natural range <>) of std_logic_vector(G_DATA_SIZE - 1 downto 0);

  pure function init_ram return ram_type is
    variable res_v    : ram_type(0 to 2 ** G_ADDR_SIZE - 1);
    variable addr_v   : std_logic_vector(G_ADDR_SIZE - 1 downto 0);
    variable data_v   : std_logic_vector(G_DATA_SIZE - 1 downto 0);
  begin
    for i in 0 to 2 ** G_ADDR_SIZE - 1 loop
      addr_v   := to_stdlogicvector(i, G_ADDR_SIZE);
      data_v   := addr_v(G_DATA_SIZE downto 1) + addr_v(G_DATA_SIZE - 1 downto 0);
      res_v(i) := data_v;
    end loop;
    return res_v;
  end function init_ram;

  signal ram : ram_type(0 to 2 ** G_ADDR_SIZE - 1) := init_ram;

  attribute ram_style : string;
  attribute ram_style of ram : signal is "block";

begin

  ram_proc : process (a_clk_i, b_clk_i)
  begin
    if rising_edge(a_clk_i) then
      if a_ce_i = '1' then
        a_data_o <= ram(to_integer(a_addr_i));
      end if;
    end if;

    if rising_edge(a_clk_i) then
      if b_ce_i = '1' then
        b_data_o <= ram(to_integer(b_addr_i));
      end if;
    end if;
  end process ram_proc;

end architecture synthesis;

