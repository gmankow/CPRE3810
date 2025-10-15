library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_addSub_32bit is
end entity tb_addSub_32bit;

architecture behavioral of tb_addSub_32bit is
    -- Component declaration
    component addSub_32bit
        port (
            i_A : in std_logic_vector(31 downto 0);
            i_B : in std_logic_vector(31 downto 0);
            i_Cin : in std_logic; -- 0 for add, 1 for subtract
            o_Sum : out std_logic_vector(31 downto 0);
            o_Cout : out std_logic;
            o_LessThan : out std_logic;
            o_Zero : out std_logic
        );
    end component;

    -- Test bench signals
    signal s_A, s_B : std_logic_vector(31 downto 0);
    signal s_Cin : std_logic;
    signal s_Sum : std_logic_vector(31 downto 0);
    signal s_Cout, s_LessThan, s_Zero : std_logic;

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
    DUT: addSub_32bit
        port map (
            i_A => s_A,
            i_B => s_B,
            i_Cin => s_Cin,
            o_Sum => s_Sum,
            o_Cout => s_Cout,
            o_LessThan => s_LessThan,
            o_Zero => s_Zero
        );

    -- Test process
    process
        variable error_count : integer := 0;

        -- Helper procedure to check results and report only failures
        procedure check_result(
            test_name : string;
            expected_sum : std_logic_vector(31 downto 0);
            expected_zero : std_logic := '0';
            expected_less : std_logic := '0';
            expected_cout : std_logic := '0'
        ) is
        begin
            wait for 10 ns; -- Allow signals to settle

            if s_Sum /= expected_sum or s_Zero /= expected_zero or 
               s_LessThan /= expected_less or s_Cout /= expected_cout then
                report "Test " & test_name & " FAILED" severity error;
                error_count := error_count + 1;
            end if;
        end procedure;

    begin
        report "Starting addSub_32bit testbench" severity note;

        -- Test 1: Simple Addition
        s_A <= to_slv32(5);
        s_B <= to_slv32(3);
        s_Cin <= '0';  -- Addition
        check_result("Simple Addition (5 + 3)", to_slv32(8));

        -- Test 2: Addition with negative numbers
        s_A <= to_slv32(-5);
        s_B <= to_slv32(-3);
        s_Cin <= '0';  -- Addition
        check_result("Addition with negatives (-5 + -3)", to_slv32(-8));

        -- Test 3: Addition resulting in zero
        s_A <= to_slv32(5);
        s_B <= to_slv32(-5);
        s_Cin <= '0';  -- Addition
        check_result("Addition to zero (5 + -5)", to_slv32(0), '1');

        -- Test 4: Simple Subtraction
        s_A <= to_slv32(10);
        s_B <= to_slv32(4);
        s_Cin <= '1';  -- Subtraction
        check_result("Simple Subtraction (10 - 4)", to_slv32(6));

        -- Test 5: Subtraction resulting in negative
        s_A <= to_slv32(5);
        s_B <= to_slv32(8);
        s_Cin <= '1';  -- Subtraction
        check_result("Subtraction to negative (5 - 8)", to_slv32(-3), '0', '1');

        -- Test 6: Subtraction resulting in zero
        s_A <= to_slv32(5);
        s_B <= to_slv32(5);
        s_Cin <= '1';  -- Subtraction
        check_result("Subtraction to zero (5 - 5)", to_slv32(0), '1');

        -- Test 7: Addition with overflow
        s_A <= x"7FFFFFFF";  -- Maximum positive 32-bit number
        s_B <= x"00000001";  -- 1
        s_Cin <= '0';  -- Addition
        check_result("Addition with overflow (MAX_INT + 1)", x"80000000", '0', '0', '1');

        -- Test 8: Subtraction with large numbers
        s_A <= x"FFFFFFFF";  -- -1 in two's complement
        s_B <= x"FFFFFFFF";  -- -1 in two's complement
        s_Cin <= '1';  -- Subtraction
        check_result("Subtraction of equal large numbers (-1 - -1)", x"00000000", '1');

        -- Test 9: Addition boundary case
        s_A <= x"FFFFFFFF";  -- -1
        s_B <= x"00000001";  -- 1
        s_Cin <= '0';  -- Addition
        check_result("Addition boundary (-1 + 1)", x"00000000", '1');

        -- Test 10: Subtraction boundary case
        s_A <= x"80000000";  -- Minimum negative number
        s_B <= x"00000001";  -- 1
        s_Cin <= '1';  -- Subtraction
        check_result("Subtraction boundary (MIN_INT - 1)", x"7FFFFFFF", '0', '1', '1');

        -- Report final status
        if error_count = 0 then
            report "addSub_32bit testbench PASSED - All tests completed successfully!" severity note;
        else
            report "addSub_32bit testbench FAILED - " & integer'image(error_count) & " errors found" severity failure;
        end if;
        wait;
    end process;

end architecture behavioral;
