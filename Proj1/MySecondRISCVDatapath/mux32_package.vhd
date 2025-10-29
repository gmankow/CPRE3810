library IEEE;
use IEEE.std_logic_1164.all;

package mux32_package is
    type mux32_array is array (31 downto 0) of std_logic_vector(31 downto 0);
end mux32_package;