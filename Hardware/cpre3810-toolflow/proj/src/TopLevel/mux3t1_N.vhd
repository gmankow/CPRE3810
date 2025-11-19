library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux3t1_N is
    generic(N : integer := 32);
    port(
        i_S  : in  std_logic_vector(1 downto 0);
        i_D0 : in  std_logic_vector(N-1 downto 0);
        i_D1 : in  std_logic_vector(N-1 downto 0);
        i_D2 : in  std_logic_vector(N-1 downto 0);
        o_O  : out std_logic_vector(N-1 downto 0)
    );
end entity mux3t1_N;

architecture behavioral of mux3t1_N is
begin
    with i_S select
        o_O <= i_D0 when "00",
               i_D1 when "01",
               i_D2 when "10",
               (others => '0') when others; -- default case
end architecture behavioral;