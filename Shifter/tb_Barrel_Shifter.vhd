-- VHDL Testbench for the 32-bit Bidirectional Barrel Shifter
--
-- This testbench verifies the functionality of the barrel_shifter component
-- by applying a series of test vectors and checking the output.
-- It now uses the ALUOp signal to control shift type (SLL, SRL, SRA).
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Barrel_Shifter is
end entity tb_Barrel_Shifter;

architecture test of tb_Barrel_Shifter is

    -- Component declaration for the Device Under Test (DUT)
    -- MODIFIED: To match the actual entity in Barrel_Shifter.vhd
    component Barrel_Shifter is
        port (
            data_in      : in  std_logic_vector(31 downto 0);
            shift_amount : in  std_logic_vector(4 downto 0);
            ALUOp        : in  std_logic_vector(3 downto 0); -- Correct control signal
            data_out     : out std_logic_vector(31 downto 0)
        );
    end component Barrel_Shifter;

    -- Testbench signals
    signal tb_data_in      : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_shift_amount : std_logic_vector(4 downto 0) := (others => '0');
    signal tb_ALUOp        : std_logic_vector(3 downto 0) := (others => '0'); -- MODIFIED
    signal tb_data_out     : std_logic_vector(31 downto 0);

    -- Clock signal for timing the test sequence
    signal clk : std_logic := '0';
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Device Under Test (DUT)
    -- MODIFIED: Port map updated to use ALUOp
    dut_inst: Barrel_Shifter
        port map (
            data_in      => tb_data_in,
            shift_amount => tb_shift_amount,
            ALUOp        => tb_ALUOp,
            data_out     => tb_data_out
        );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;

    -- Main test process
    stimulus_process: process
        -- MODIFIED: Procedure now takes direction and an arithmetic flag
        procedure apply_test (
            test_name    : string;
            data         : std_logic_vector(31 downto 0);
            amount       : integer;
            dir          : std_logic; -- '0' for LEFT, '1' for RIGHT
            is_arith     : boolean;   -- true for SRA, false for SLL/SRL
            expected_out : std_logic_vector(31 downto 0)
        ) is
        begin
            tb_data_in      <= data;
            tb_shift_amount <= std_logic_vector(to_unsigned(amount, 5));
            
            -- Construct ALUOp from test parameters
            -- ALUOp(0) controls direction, ALUOp(3) controls arithmetic shift
            if is_arith then
                tb_ALUOp <= "100" & dir; -- "1001" for SRA
            else
                tb_ALUOp <= "000" & dir; -- "0000" for SLL, "0001" for SRL
            end if;
            
            wait for CLK_PERIOD;

            assert tb_data_out = expected_out
                report "TEST FAILED: " & test_name & ". Expected " & to_hstring(expected_out) & ", got " & to_hstring(tb_data_out)
                severity error;
        end procedure apply_test;

    begin
        report "Starting Barrel Shifter Testbench...";
        wait for CLK_PERIOD;

        -- === TEST CASES: SHIFT LEFT LOGICAL (SLL) ===
        apply_test("SLL by 1", x"80000001", 1, '0', false, x"00000002");
        apply_test("SLL by 15", x"00000003", 15, '0', false, x"00018000");
        apply_test("SLL by 31", x"00000003", 31, '0', false, x"80000000");
        apply_test("SLL by 0", x"DEADBEEF", 0, '0', false, x"DEADBEEF");
        -- CORRECTED: Left shifts are always logical (fill with 0)
        apply_test("SLL by 1 (was fill 1)", x"FFFF0000", 1, '0', false, x"FFFE0000"); 
        apply_test("SLL by 4", x"AAAAAAAA", 4, '0', false, x"AAAAAAA0");
        apply_test("SLL all 1s", x"FFFFFFFF", 8, '0', false, x"FFFFFF00");

        -- === TEST CASES: SHIFT RIGHT LOGICAL (SRL) & ARITHMETIC (SRA) ===
        apply_test("SRL by 1", x"80000001", 1, '1', false, x"40000000");
        apply_test("SRL by 15", x"C0000000", 15, '1', false, x"00000018");
        apply_test("SRL by 31", x"C0000000", 31, '1', false, x"00000000");
        apply_test("SRL by 0", x"DEADBEEF", 0, '1', false, x"DEADBEEF");
        apply_test("ASR by 1 (negative #)", x"80000000", 1, '1', true, x"C0000000");
        -- CORRECTED: ASR on a positive number is the same as SRL
        apply_test("ASR by 4 (positive #)", x"55555555", 4, '1', true, x"05555555");
        -- CORRECTED: Meaningful ASR test with a negative number
        apply_test("ASR by 8 (negative #)", x"A0000000", 8, '1', true, x"FFA00000");
        
        report "All tests completed successfully." severity note;
        wait; -- End of simulation
    end process stimulus_process;
end architecture test;
