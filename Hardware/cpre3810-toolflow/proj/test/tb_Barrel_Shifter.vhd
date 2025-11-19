-- Simplified VHDL Testbench for Barrel_Shifter
-- Sets inputs sequentially.
-- Added 'wait for 10 ns;' between tests to see each in a waveform.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Barrel_Shifter is
end entity tb_Barrel_Shifter;

architecture test of tb_Barrel_Shifter is

    -- Component declaration for the Device Under Test (DUT)
    component Barrel_Shifter is
        port (
            data_in      : in  std_logic_vector(31 downto 0);
            shift_amount : in  std_logic_vector(4 downto 0);
            ALUOp        : in  std_logic_vector(3 downto 0);
            data_out     : out std_logic_vector(31 downto 0)
        );
    end component Barrel_Shifter;

    -- Testbench signals
    signal tb_data_in      : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_shift_amount : std_logic_vector(4 downto 0) := (others => '0');
    signal tb_ALUOp        : std_logic_vector(3 downto 0) := (others => '0');
    signal tb_data_out     : std_logic_vector(31 downto 0);

begin

    -- Instantiate the Device Under Test (DUT)
    dut_inst: Barrel_Shifter
        port map (
            data_in      => tb_data_in,
            shift_amount => tb_shift_amount,
            ALUOp        => tb_ALUOp,
            data_out     => tb_data_out
        );

    -- Main test process
    stimulus_process: process
    begin
        -- === TEST CASES: SHIFT LEFT LOGICAL (SLL) ===
        -- ALUOp "0000" = SLL
        tb_data_in      <= x"80000001";
        tb_shift_amount <= "00001"; -- 1
        tb_ALUOp        <= "0000";
        -- Expected: x"00000002"
        wait for 10 ns;

        tb_data_in      <= x"00000003";
        tb_shift_amount <= "01111"; -- 15
        tb_ALUOp        <= "0000";
        -- Expected: x"00018000"
        wait for 10 ns;

        tb_data_in      <= x"00000003";
        tb_shift_amount <= "11111"; -- 31
        tb_ALUOp        <= "0000";
        -- Expected: x"80000000"
        wait for 10 ns;

        tb_data_in      <= x"DEADBEEF";
        tb_shift_amount <= "00000"; -- 0
        tb_ALUOp        <= "0000";
        -- Expected: x"DEADBEEF"
        wait for 10 ns;

        tb_data_in      <= x"FFFF0000";
        tb_shift_amount <= "00001"; -- 1
        tb_ALUOp        <= "0000";
        -- Expected: x"FFFE0000"
        wait for 10 ns;

        tb_data_in      <= x"AAAAAAAA";
        tb_shift_amount <= "00100"; -- 4
        tb_ALUOp        <= "0000";
        -- Expected: x"AAAAAAA0"
        wait for 10 ns;

        tb_data_in      <= x"FFFFFFFF";
        tb_shift_amount <= "01000"; -- 8
        tb_ALUOp        <= "0000";
        -- Expected: x"FFFFFF00"
        wait for 10 ns;

        -- === TEST CASES: SHIFT RIGHT LOGICAL (SRL) ===
        -- ALUOp "0001" = SRL
        tb_data_in      <= x"80000001";
        tb_shift_amount <= "00001"; -- 1
        tb_ALUOp        <= "0001";
        -- Expected: x"40000000"
        wait for 10 ns;

        tb_data_in      <= x"C0000000";
        tb_shift_amount <= "01111"; -- 15
        tb_ALUOp        <= "0001";
        -- Expected: x"00000018"
        wait for 10 ns;

        tb_data_in      <= x"C0000000";
        tb_shift_amount <= "11111"; -- 31
        tb_ALUOp        <= "0001";
        -- Expected: x"00000000"
        wait for 10 ns;

        tb_data_in      <= x"DEADBEEF";
        tb_shift_amount <= "00000"; -- 0
        tb_ALUOp        <= "0001";
        -- Expected: x"DEADBEEF"
        wait for 10 ns;

        -- === TEST CASES: SHIFT RIGHT ARITHMETIC (SRA) ===
        -- ALUOp "1001" = SRA
        tb_data_in      <= x"80000000";
        tb_shift_amount <= "00001"; -- 1
        tb_ALUOp        <= "1001";
        -- Expected: x"C0000000"
        wait for 10 ns;

        tb_data_in      <= x"55555555";
        tb_shift_amount <= "00100"; -- 4
        tb_ALUOp        <= "1001";
        -- Expected: x"05555555"
        wait for 10 ns;

        tb_data_in      <= x"A0000000";
        tb_shift_amount <= "01000"; -- 8
        tb_ALUOp        <= "1001";
        -- Expected: x"FFA00000"
        wait for 10 ns;

        wait; -- End of simulation
    end process stimulus_process;
end architecture test;