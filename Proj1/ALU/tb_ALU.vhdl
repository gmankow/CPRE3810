library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ALU is
end entity tb_ALU;

architecture behavioral of tb_ALU is
    -- Component declaration for the DUT
    component ALU is
        port (
            i_A : in std_logic_vector(31 downto 0);
            i_B : in std_logic_vector(31 downto 0);
            i_Control : in std_logic_vector(3 downto 0);
            o_Result : out std_logic_vector(31 downto 0);
            o_Zero : out std_logic;
            o_LessThan : out std_logic;
            o_CarryOut : out std_logic
        );
    end component;

    -- Testbench signals
    signal s_A, s_B : std_logic_vector(31 downto 0);
    signal s_Control : std_logic_vector(3 downto 0);
    signal s_Result : std_logic_vector(31 downto 0);
    signal s_Zero, s_LessThan, s_CarryOut : std_logic;

    -- Constants for control signals
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0001";
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0011";
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "1000";
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "1101";

    -- Helper function to convert integer to 32-bit std_logic_vector
    function to_slv32(value : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(value, 32));
    end function;

    -- Function to convert std_logic_vector to hex string for reporting
    function to_hex_string(slv : std_logic_vector) return string is
        variable result : string(1 to 8);  -- 32 bits = 8 hex digits
        variable nibble : std_logic_vector(3 downto 0);
    begin
        for i in 0 to 7 loop
            nibble := slv(31-i*4 downto 28-i*4);
            case nibble is
                when "0000" => result(i+1) := '0';
                when "0001" => result(i+1) := '1';
                when "0010" => result(i+1) := '2';
                when "0011" => result(i+1) := '3';
                when "0100" => result(i+1) := '4';
                when "0101" => result(i+1) := '5';
                when "0110" => result(i+1) := '6';
                when "0111" => result(i+1) := '7';
                when "1000" => result(i+1) := '8';
                when "1001" => result(i+1) := '9';
                when "1010" => result(i+1) := 'A';
                when "1011" => result(i+1) := 'B';
                when "1100" => result(i+1) := 'C';
                when "1101" => result(i+1) := 'D';
                when "1110" => result(i+1) := 'E';
                when "1111" => result(i+1) := 'F';
                when others => result(i+1) := 'X';
            end case;
        end loop;
        return result;
    end function;

begin
    -- Instantiate the DUT
    DUT: ALU
        port map (
            i_A => s_A,
            i_B => s_B,
            i_Control => s_Control,
            o_Result => s_Result,
            o_Zero => s_Zero,
            o_LessThan => s_LessThan,
            o_CarryOut => s_CarryOut
        );

    -- Test process
    process
        variable error_count : integer := 0;

        -- Helper procedure to check results and report
        procedure check_result(
            test_name : string;
            expected_result : std_logic_vector(31 downto 0);
            expected_zero : std_logic := '0';
            expected_less : std_logic := '0'
        ) is
        begin
            wait for 10 ns; -- Allow signals to settle
            
            report "Test: " & test_name severity note;
            report "  A = 0x" & to_hex_string(s_A) & " (" & integer'image(to_integer(signed(s_A))) & ")" severity note;
            report "  B = 0x" & to_hex_string(s_B) & " (" & integer'image(to_integer(signed(s_B))) & ")" severity note;
            report "  Expected: 0x" & to_hex_string(expected_result) & " (" & integer'image(to_integer(signed(expected_result))) & ")" severity note;
            report "  Got:      0x" & to_hex_string(s_Result) & " (" & integer'image(to_integer(signed(s_Result))) & ")" severity note;

            if s_Result /= expected_result then
                report "ERROR: Result mismatch!" severity error;
                error_count := error_count + 1;
            end if;

            if s_Zero /= expected_zero then
                report "ERROR: Zero flag mismatch! Expected " & std_logic'image(expected_zero) & " got " & std_logic'image(s_Zero) severity error;
                error_count := error_count + 1;
            end if;

            if s_LessThan /= expected_less then
                report "ERROR: LessThan flag mismatch! Expected " & std_logic'image(expected_less) & " got " & std_logic'image(s_LessThan) severity error;
                error_count := error_count + 1;
            end if;

            report "" severity note;  -- Blank line
        end procedure;

    begin
        report "Starting ALU testbench" severity note;

        -- Test 1: Addition (positive numbers)
        s_A <= to_slv32(5);
        s_B <= to_slv32(3);
        s_Control <= ALU_ADD;
        check_result("ADD 5 + 3", to_slv32(8));

        -- Test 2: Addition (negative numbers)
        s_A <= to_slv32(-5);
        s_B <= to_slv32(-3);
        s_Control <= ALU_ADD;
        check_result("ADD (-5) + (-3)", to_slv32(-8));

        -- Test 3: Subtraction (positive numbers)
        s_A <= to_slv32(10);
        s_B <= to_slv32(4);
        s_Control <= ALU_SUB;
        check_result("SUB 10 - 4", to_slv32(6));

        -- Test 4: Subtraction (negative result)
        s_A <= to_slv32(5);
        s_B <= to_slv32(8);
        s_Control <= ALU_SUB;
        check_result("SUB 5 - 8", to_slv32(-3), '0', '1');

        -- Test 5: AND
        s_A <= x"FF00FF00";
        s_B <= x"0F0F0F0F";
        s_Control <= ALU_AND;
        check_result("AND FF00FF00 & 0F0F0F0F", x"0F000F00");

        -- Test 6: OR
        s_A <= x"FF00FF00";
        s_B <= x"0F0F0F0F";
        s_Control <= ALU_OR;
        check_result("OR FF00FF00 | 0F0F0F0F", x"FF0FFF0F");

        -- Test 7: XOR
        s_A <= x"FF00FF00";
        s_B <= x"0F0F0F0F";
        s_Control <= ALU_XOR;
        check_result("XOR FF00FF00 ^ 0F0F0F0F", x"F00FF00F");

        -- Test 8: SLT (positive numbers)
        s_A <= to_slv32(5);
        s_B <= to_slv32(10);
        s_Control <= ALU_SLT;
        check_result("SLT 5 < 10", x"00000001", '0', '1');

        -- Test 9: SLT (negative numbers)
        s_A <= to_slv32(-10);
        s_B <= to_slv32(-5);
        s_Control <= ALU_SLT;
        check_result("SLT -10 < -5", x"00000001", '0', '1');

        -- Test 10: SLTU
        s_A <= x"FFFFFFFF";  -- Max unsigned value
        s_B <= x"00000001";  -- 1
        s_Control <= ALU_SLTU;
        check_result("SLTU FFFFFFFF < 1", x"00000000");

        -- Test 11: Zero flag test
        s_A <= to_slv32(5);
        s_B <= to_slv32(5);
        s_Control <= ALU_SUB;
        check_result("Zero flag test (5-5)", x"00000000", '1', '0');

        -- Test 12: Invalid operation
        s_A <= to_slv32(5);
        s_B <= to_slv32(3);
        s_Control <= "1111";
        check_result("Invalid operation", x"00000000");

        -- Report final status
        if error_count = 0 then
            report "ALU testbench PASSED - All tests completed successfully!" severity note;
        else
            report "ALU testbench FAILED - " & integer'image(error_count) & " errors found" severity failure;
        end if;
        wait;
    end process;

end architecture behavioral;

-- written by VSCode Claude Sonnet 3.5