library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ALU is
end entity tb_ALU;

architecture behavioral of tb_ALU is
    -- Component declaration for the DUT (Updated to match new ALU.vhd)
    component ALU is
        port (
            i_A             : in  std_logic_vector(31 downto 0);
            i_B             : in  std_logic_vector(31 downto 0);
            i_Control       : in  std_logic_vector(3 downto 0);
            i_Func3         : in  std_logic_vector(2 downto 0); -- New input
            o_Result        : out std_logic_vector(31 downto 0);
            o_Zero          : out std_logic;
            o_LessThan      : out std_logic;
            o_CarryOut      : out std_logic;
            o_BranchCondMet : out std_logic; -- New output
            o_Overflow      : out std_logic  -- New output
        );
    end component;

    -- Testbench signals
    signal s_A, s_B      : std_logic_vector(31 downto 0);
    signal s_Control     : std_logic_vector(3 downto 0);
    signal s_Func3       : std_logic_vector(2 downto 0); -- New signal
    signal s_Result      : std_logic_vector(31 downto 0);
    signal s_Zero        : std_logic;
    signal s_LessThan    : std_logic;
    signal s_CarryOut    : std_logic;
    signal s_BranchCondMet : std_logic; -- New signal
    signal s_Overflow    : std_logic; -- New signal

    -- Constants for control signals
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0001";
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0011";
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "1100"; -- Corrected from "1000"
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "1101";

    -- Constants for i_Func3 (Branch Types)
    constant F3_BEQ  : std_logic_vector(2 downto 0) := "000";
    constant F3_BNE  : std_logic_vector(2 downto 0) := "001";
    constant F3_BLT  : std_logic_vector(2 downto 0) := "100";
    constant F3_BGE  : std_logic_vector(2 downto 0) := "101";
    constant F3_BLTU : std_logic_vector(2 downto 0) := "110";
    constant F3_BGEU : std_logic_vector(2 downto 0) := "111";


begin
    -- Instantiate the DUT (Updated to match new ALU.vhd)
    DUT: ALU
        port map (
            i_A             => s_A,
            i_B             => s_B,
            i_Control       => s_Control,
            i_Func3         => s_Func3,
            o_Result        => s_Result,
            o_Zero          => s_Zero,
            o_LessThan      => s_LessThan,
            o_CarryOut      => s_CarryOut,
            o_BranchCondMet => s_BranchCondMet,
            o_Overflow      => s_Overflow
        );

    -- Test process
    process
    begin
        -- For non-branch tests, i_Func3 doesn't matter for o_Result
        -- but we set it to '000' for clarity.
        s_Func3 <= "000";

        -- Test 1: Addition (positive numbers)
        s_A       <= std_logic_vector(to_signed(5, 32));
        s_B       <= std_logic_vector(to_signed(3, 32));
        s_Control <= ALU_ADD;
        -- Expected: o_Result = 8 (x"00000008"), o_Zero = '0'
        wait for 10 ns;

        -- Test 2: Addition (negative numbers)
        s_A       <= std_logic_vector(to_signed(-5, 32));
        s_B       <= std_logic_vector(to_signed(-3, 32));
        s_Control <= ALU_ADD;
        -- Expected: o_Result = -8 (x"FFFFFFF8"), o_Zero = '0'
        wait for 10 ns;

        -- Test 3: Subtraction (positive numbers)
        s_A       <= std_logic_vector(to_signed(10, 32));
        s_B       <= std_logic_vector(to_signed(4, 32));
        s_Control <= ALU_SUB;
        -- Expected: o_Result = 6 (x"00000006"), o_Zero = '0'
        wait for 10 ns;

        -- Test 4: Subtraction (negative result)
        s_A       <= std_logic_vector(to_signed(5, 32));
        s_B       <= std_logic_vector(to_signed(8, 32));
        s_Control <= ALU_SUB;
        -- Expected: o_Result = -3 (x"FFFFFFFD"), o_Zero = '0'
        wait for 10 ns;

        -- Test 5: AND
        s_A       <= x"FF00FF00";
        s_B       <= x"0F0F0F0F";
        s_Control <= ALU_AND;
        -- Expected: o_Result = x"0F000F00"
        wait for 10 ns;

        -- Test 6: OR
        s_A       <= x"FF00FF00";
        s_B       <= x"0F0F0F0F";
        s_Control <= ALU_OR;
        -- Expected: o_Result = x"FF0FFF0F"
        wait for 10 ns;

        -- Test 7: XOR
        s_A       <= x"FF00FF00";
        s_B       <= x"0F0F0F0F";
        s_Control <= ALU_XOR;
        -- Expected: o_Result = x"F00FF00F"
        wait for 10 ns;

        -- Test 8: SLT (A < B)
        s_A       <= std_logic_vector(to_signed(5, 32));
        s_B       <= std_logic_vector(to_signed(10, 32));
        s_Control <= ALU_SLT;
        -- Expected: o_Result = 1 (x"00000001"), o_LessThan = '1'
        wait for 10 ns;

        -- Test 9: SLT (A < B, negative)
        s_A       <= std_logic_vector(to_signed(-10, 32));
        s_B       <= std_logic_vector(to_signed(-5, 32));
        s_Control <= ALU_SLT;
        -- Expected: o_Result = 1 (x"00000001"), o_LessThan = '1'
        wait for 10 ns;

        -- Test 10: SLT (A > B)
        s_A       <= std_logic_vector(to_signed(10, 32));
        s_B       <= std_logic_vector(to_signed(5, 32));
        s_Control <= ALU_SLT;
        -- Expected: o_Result = 0 (x"00000000"), o_LessThan = '0'
        wait for 10 ns;

        -- Test 11: SLTU (A > B) (Using new control code "1100")
        s_A       <= x"FFFFFFFF";  -- Max unsigned value
        s_B       <= x"00000001";  -- 1
        s_Control <= ALU_SLTU;
        -- Expected: o_Result = 0 (x"00000000"), o_LessThan = '0'
        wait for 10 ns;

        -- Test 12: SLTU (A < B) (Using new control code "1100")
        s_A       <= x"00000001";
        s_B       <= x"FFFFFFFF";
        s_Control <= ALU_SLTU;
        -- Expected: o_Result = 1 (x"00000001"), o_LessThan = '1'
        wait for 10 ns;

        -- Test 13: Zero flag test
        s_A       <= std_logic_vector(to_signed(5, 32));
        s_B       <= std_logic_vector(to_signed(5, 32));
        s_Control <= ALU_SUB;
        -- Expected: o_Result = 0 (x"00000000"), o_Zero = '1'
        wait for 10 ns;

        -- Test 14: Invalid operation (default case)
        s_A       <= std_logic_vector(to_signed(5, 32));
        s_B       <= std_logic_vector(to_signed(3, 32));
        s_Control <= "1111";
        -- Expected: o_Result = 0 (or default)
        wait for 10 ns;

        -- === NEW TESTS FOR BRANCH CONDITION LOGIC ===
        -- The ALU always calculates branch conditions.
        -- We just need to set i_Func3 to check the o_BranchCondMet output.

        -- Test 15: BEQ (A = B) -> Met
        s_A       <= std_logic_vector(to_signed(100, 32));
        s_B       <= std_logic_vector(to_signed(100, 32));
        s_Control <= ALU_SUB; -- Branch ops use subtractor
        s_Func3   <= F3_BEQ;
        -- Expected: o_Zero = '1', o_BranchCondMet = '1'
        wait for 10 ns;

        -- Test 16: BEQ (A != B) -> Not Met
        s_A       <= std_logic_vector(to_signed(101, 32));
        s_B       <= std_logic_vector(to_signed(100, 32));
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BEQ;
        -- Expected: o_Zero = '0', o_BranchCondMet = '0'
        wait for 10 ns;

        -- Test 17: BNE (A != B) -> Met
        s_A       <= std_logic_vector(to_signed(101, 32));
        s_B       <= std_logic_vector(to_signed(100, 32));
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BNE;
        -- Expected: o_Zero = '0', o_BranchCondMet = '1'
        wait for 10 ns;

        -- Test 18: BLT (A < B) -> Met
        s_A       <= std_logic_vector(to_signed(-10, 32));
        s_B       <= std_logic_vector(to_signed(10, 32));
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BLT;
        -- Expected: o_LessThan = '1', o_BranchCondMet = '1'
        wait for 10 ns;

        -- Test 19: BLT (A > B) -> Not Met
        s_A       <= std_logic_vector(to_signed(20, 32));
        s_B       <= std_logic_vector(to_signed(10, 32));
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BLT;
        -- Expected: o_LessThan = '0', o_BranchCondMet = '0'
        wait for 10 ns;

        -- Test 20: BGE (A >= B) -> Met
        s_A       <= std_logic_vector(to_signed(20, 32));
        s_B       <= std_logic_vector(to_signed(10, 32));
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BGE;
        -- Expected: o_LessThan = '0', o_BranchCondMet = '1'
        wait for 10 ns;

        -- Test 21: BGE (A < B) -> Not Met
        s_A       <= std_logic_vector(to_signed(-10, 32));
        s_B       <= std_logic_vector(to_signed(10, 32));
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BGE;
        -- Expected: o_LessThan = '1', o_BranchCondMet = '0'
        wait for 10 ns;

        -- Test 22: BLTU (A < B, unsigned) -> Met
        s_A       <= x"00000005";
        s_B       <= x"FFFFFFFF"; -- Large unsigned
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BLTU;
        -- Expected: o_CarryOut = '0', o_BranchCondMet = '1'
        wait for 10 ns;

        -- Test 23: BLTU (A > B, unsigned) -> Not Met
        s_A       <= x"FFFFFFFF"; -- Large unsigned
        s_B       <= x"00000005";
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BLTU;
        -- Expected: o_CarryOut = '1', o_BranchCondMet = '0'
        wait for 10 ns;

        -- Test 24: BGEU (A >= B, unsigned) -> Met
        s_A       <= x"FFFFFFFF";
        s_B       <= x"00000005";
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BGEU;
        -- Expected: o_CarryOut = '1', o_BranchCondMet = '1'
        wait for 10 ns;

        -- Test 25: BGEU (A < B, unsigned) -> Not Met
        s_A       <= x"00000005";
        s_B       <= x"FFFFFFFF";
        s_Control <= ALU_SUB;
        s_Func3   <= F3_BGEU;
        -- Expected: o_CarryOut = '0', o_BranchCondMet = '0'
        wait for 10 ns;

        wait;
    end process;

end architecture behavioral;