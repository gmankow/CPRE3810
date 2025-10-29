library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- NOTE
-- EDITED TO USE 12 BIT IMMEDIATE VALUES

entity extender_12t32 is
    port(
        i_in    : in  std_logic_vector(11 downto 0); -- Changed to 12 bits for immediate values
        i_sign  : in  std_logic; -- '1' for sign extension, '0' for zero extension
        o_out   : out std_logic_vector(31 downto 0)
    );
end entity extender_12t32;

architecture behavioral of extender_12t32 is
begin
    with i_sign select
        o_out <= 
            std_logic_vector(resize(signed(i_in), 32)) when '1',  -- Sign extension
            std_logic_vector(resize(unsigned(i_in), 32)) when others; -- Zero extension
end architecture behavioral;
