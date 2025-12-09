library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_addSub_32bit is
end entity tb_addSub_32bit;

architecture behavioral of tb_addSub_32bit is

    -- Component Declaration for the DUT
    component addSub_32bit is
        port (
            i_A        : in  std_logic_vector(31 downto 0);
            i_B        : in  std_logic_vector(31 downto 0);
            i_Cin      : in  std_logic; -- 0 for add, 1 for subtract
            o_Sum      : out std_logic_vector(31 downto 0);
            o_Cout     : out std_logic;
            o_LessThan : out std_logic;
            o_Zero     : out std_logic;
            o_Overflow : out std_logic
        );
    end component;

    -- Testbench signals
    signal s_A, s_B      : std_logic_vector(31 downto 0);
    signal s_Cin         : std_logic;
    signal s_Sum         : std_logic_vector(31 downto 0);
    signal s_Cout        : std_logic;
    signal s_LessThan    : std_logic;
    signal s_Zero        : std_logic;
    signal s_Overflow    : std_logic;

    -- Constants for operation readability
    constant OP_ADD : std_logic := '0';
    constant OP_SUB : std_logic := '1';

begin

    -- Instantiate the Device Under Test (DUT)
    DUT: addSub_32bit
        port map (
            i_A        => s_A,
            i_B        => s_B,
            i_Cin      => s_Cin,
            o_Sum      => s_Sum,
            o_Cout     => s_Cout,
            o_LessThan => s_LessThan,
            o_Zero     => s_Zero,
            o_Overflow => s_Overflow
        );

    -- Test process
    process
    begin
        -- Test 1: Simple Addition (Positive)
        s_A   <= std_logic_vector(to_signed(5, 32));
        s_B   <= std_logic_vector(to_signed(3, 32));
        s_Cin <= OP_ADD;
        -- Expected: o_Sum = 8, o_Zero = '0', o_Overflow = '0'
        wait for 10 ns;

        -- Test 2: Simple Addition (Negative)
        s_A   <= std_logic_vector(to_signed(-5, 32));
        s_B   <= std_logic_vector(to_signed(-3, 32));
        s_Cin <= OP_ADD;
        -- Expected: o_Sum = -8 (x"FFFFFFF8"), o_Zero = '0'
        wait for 10 ns;

        -- Test 3: Simple Subtraction (Positive Result)
        s_A   <= std_logic_vector(to_signed(10, 32));
        s_B   <= std_logic_vector(to_signed(4, 32));
        s_Cin <= OP_SUB;
        -- Expected: o_Sum = 6, o_Zero = '0'
        wait for 10 ns;

        -- Test 4: Subtraction (Negative Result)
        s_A   <= std_logic_vector(to_signed(5, 32));
        s_B   <= std_logic_vector(to_signed(8, 32));
        s_Cin <= OP_SUB;
        -- Expected: o_Sum = -3 (x"FFFFFFFD"), o_LessThan = '1'
        wait for 10 ns;

        -- Test 5: Zero Flag Test
        s_A   <= std_logic_vector(to_signed(50, 32));
        s_B   <= std_logic_vector(to_signed(50, 32));
        s_Cin <= OP_SUB;
        -- Expected: o_Sum = 0, o_Zero = '1'
        wait for 10 ns;

        -- Test 6: Carry Out Test (Unsigned Overflow)
        s_A   <= x"FFFFFFFF"; -- -1 in signed, Max Int in unsigned
        s_B   <= x"00000001"; -- 1
        s_Cin <= OP_ADD;
        -- Expected: o_Sum = 0, o_Cout = '1'
        wait for 10 ns;

        -- Test 7: Signed Overflow Test (Positive)
        -- Adding two large positive numbers to produce a negative result
        s_A   <= x"7FFFFFFF"; -- Max positive (2,147,483,647)
        s_B   <= x"00000001"; -- 1
        s_Cin <= OP_ADD;
        -- Expected: o_Sum = x"80000000" (Min negative), o_Overflow = '1'
        wait for 10 ns;

        -- Test 8: Signed Overflow Test (Negative)
        -- Adding two large negative numbers to produce a positive result
        s_A   <= x"80000000"; -- Min negative (-2,147,483,648)
        s_B   <= x"FFFFFFFF"; -- -1
        s_Cin <= OP_ADD;
        -- Expected: o_Sum = x"7FFFFFFF" (Max positive), o_Overflow = '1'
        wait for 10 ns;

        -- Test 9: Less Than Check (A < B is True)
        s_A   <= std_logic_vector(to_signed(-10, 32));
        s_B   <= std_logic_vector(to_signed(5, 32));
        s_Cin <= OP_SUB; 
        -- Note: LessThan is usually derived from subtraction logic
        -- Expected: o_LessThan = '1'
        wait for 10 ns;

        -- Test 10: Less Than Check (A > B is False)
        s_A   <= std_logic_vector(to_signed(10, 32));
        s_B   <= std_logic_vector(to_signed(5, 32));
        s_Cin <= OP_SUB;
        -- Expected: o_LessThan = '0'
        wait for 10 ns;
        
        wait;
    end process;

end architecture behavioral;
