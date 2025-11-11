-- branch adder in decode stage
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BranchCalc is
    port(
        i_PC : in std_logic_vector(31 downto 0);
        i_Immediate : in std_logic_vector(31 downto 0);
        o_BranchAddr : out std_logic_vector(31 downto 0)
    );
end entity BranchCalc;

architecture structural of BranchCalc is

    component addSub_32bit is
        port (
            i_A      : in  std_logic_vector(31 downto 0);
            i_B      : in  std_logic_vector(31 downto 0);
            i_Cin     : in  std_logic; -- 0 for add, 1 for subtract
            o_Sum : out std_logic_vector(31 downto 0);
            o_Cout  : out std_logic;
            o_LessThan : out std_logic; -- 1 if A < B, else 0
            o_Zero : out std_logic; -- 1 if result is 0, else 0
            o_Overflow : out std_logic -- Overflow flag (for addition/subtraction)
        );
    end component;

begin

    BranchAdder_inst : addSub_32bit
        port map (
            i_A => i_PC,
            i_B => i_Immediate,
            i_Cin => '0', -- Addition
            o_Sum => o_BranchAddr,
            o_Cout => open,
            o_LessThan => open,
            o_Zero => open,
            o_Overflow => open
        );

end architecture structural;