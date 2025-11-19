-- Simplified VHDL Testbench for immediateGenerate
-- Sets inputs sequentially.
-- Added 'wait for 10 ns;' between tests to see each in a waveform.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_immediateGenerate is
end entity tb_immediateGenerate;

architecture behavioral of tb_immediateGenerate is

    -- DUT component
    component immediateGenerate is
        port(
            i_ImmType     : in  std_logic_vector(2 downto 0);
            i_Instruction : in  std_logic_vector(31 downto 0);
            o_Immediate   : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signals
    signal i_ImmType : std_logic_vector(2 downto 0) := (others => '0');
    signal i_Instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal o_Immediate : std_logic_vector(31 downto 0);

begin

    dut: component immediateGenerate
        port map(
            i_ImmType => i_ImmType,
            i_Instruction => i_Instruction,
            o_Immediate => o_Immediate
        );

    stimulus: process
    begin
        -- Test: I-type +12
        i_ImmType <= "000";
        i_Instruction <= x"00C58593";
        -- Expected: o_Immediate = x"0000000C"
        wait for 10 ns;

        -- Test: I-type -1
        i_ImmType <= "000";
        i_Instruction <= x"FFF58593";
        -- Expected: o_Immediate = x"FFFFFFFF"
        wait for 10 ns;

        -- Test: I-type -2048
        i_ImmType <= "000";
        i_Instruction <= x"80058593";
        -- Expected: o_Immediate = x"FFFFF800"
        wait for 10 ns;

        -- Test: I-type +2047
        i_ImmType <= "000";
        i_Instruction <= x"7FF58593";
        -- Expected: o_Immediate = x"000007FF"
        wait for 10 ns;

        -- Test: S-type offset 0
        i_ImmType <= "001";
        i_Instruction <= x"00B62023";
        -- Expected: o_Immediate = x"00000000"
        wait for 10 ns;

        -- Test: S-type offset 4
        i_ImmType <= "001";
        i_Instruction <= x"00B62223";
        -- Expected: o_Immediate = x"00000004"
        wait for 10 ns;

        -- Test: S-type offset -4
        i_ImmType <= "001";
        i_Instruction <= x"FEB62E23";
        -- Expected: o_Immediate = x"FFFFFFFC"
        wait for 10 ns;

        -- Test: SB-type +8
        i_ImmType <= "010";
        i_Instruction <= x"00B60463";
        -- Expected: o_Immediate = x"00000008"
        wait for 10 ns;

        -- Test: SB-type -4
        i_ImmType <= "010";
        i_Instruction <= x"FEB616E3";
        -- Expected: o_Immediate = x"FFFFFFEC"
        wait for 10 ns;

        -- Test: SB-type 0
        i_ImmType <= "010";
        i_Instruction <= x"00B61063";
        -- Expected: o_Immediate = x"00000000"
        wait for 10 ns;

        -- Test: U-type upper
        i_ImmType <= "011";
        i_Instruction <= x"123455B7";
        -- Expected: o_Immediate = x"12345000"
        wait for 10 ns;

        -- Test: U-type neg
        i_ImmType <= "011";
        i_Instruction <= x"FFFFF5B7";
        -- Expected: o_Immediate = x"FFFFF000"
        wait for 10 ns;

        -- Test: U-type small
        i_ImmType <= "011";
        i_Instruction <= x"000015B7";
        -- Expected: o_Immediate = x"00001000"
        wait for 10 ns;

        -- Test: UJ-type +8
        i_ImmType <= "100";
        i_Instruction <= x"008000EF";
        -- Expected: o_Immediate = x"00000008"
        wait for 10 ns;

        -- Test: UJ-type -8
        i_ImmType <= "100";
        i_Instruction <= x"FF8000EF";
        -- Expected: o_Immediate = x"FFF007F8"
        wait for 10 ns;

        -- Test: UJ-type 0
        i_ImmType <= "100";
        i_Instruction <= x"000000EF";
        -- Expected: o_Immediate = x"00000000"
        wait for 10 ns;
        
        -- Test: Invalid ImmType
        i_ImmType <= "111";
        i_Instruction <= x"12345678";
        -- Expected: o_Immediate = x"00000000" (or default)
        wait for 10 ns;

        wait;
    end process stimulus;

end architecture behavioral;