library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
    port (
        i_A : in std_logic_vector(31 downto 0); -- Input A
        i_B : in std_logic_vector(31 downto 0); -- Input B
        i_Control : in std_logic_vector(3 downto 0); -- ALU control signal (4 bits)
        i_Func3 : in std_logic_vector(2 downto 0); -- funct3 field from instruction (for branch ops)
        o_Result : out std_logic_vector(31 downto 0); -- ALU result output
        o_Zero : out std_logic; -- '1' if result is zero, else '0'
        o_LessThan : out std_logic; -- '1' if A < B, else '0'
        o_CarryOut : out std_logic; -- Carry out from addition/subtraction
        o_BranchCondMet : out std_logic; -- Branch condition met flag
        o_Overflow : out std_logic -- Overflow flag (for addition/subtraction)
    );
end entity ALU;

architecture mixed of ALU is

    signal s_addSub_result: std_logic_vector(31 downto 0); -- Result from adder/subtractor
    signal s_And_result: std_logic_vector(31 downto 0); -- Result from AND operation
    signal s_Or_result: std_logic_vector(31 downto 0); -- Result from OR operation
    signal s_Shifter_result: std_logic_vector(31 downto 0); -- Result from shifter
    signal s_Xor_result: std_logic_vector(31 downto 0); -- Result from XOR operation
    signal s_SLT_result: std_logic; -- Result from set less than (signed)
    signal s_SLTU_result: std_logic; -- Result from set less than (unsigned)
    signal s_zero: std_logic; -- Internal zero flag from adder/subtractor
    signal s_lessThan: std_logic; -- Internal less than flag from adder/subtractor
    signal s_CarryOut: std_logic; -- Internal carry out from adder/subtractor

    signal s_branch_eq: std_logic; -- Branch equal condition
    signal s_branch_ne: std_logic; -- Branch not equal condition
    signal s_branch_lt: std_logic; -- Branch less than condition
    signal s_branch_ge: std_logic; -- Branch greater than or equal condition
    signal s_branch_ltu: std_logic; -- Branch less than unsigned condition
    signal s_branch_geu: std_logic; -- Branch greater than or equal unsigned condition

    -- add/sub component
    component addSub_32bit is
        port (
            i_A : in std_logic_vector(31 downto 0);
            i_B : in std_logic_vector(31 downto 0);
            i_Cin : in std_logic; -- 0 for add, 1 for subtract
            o_Sum : out std_logic_vector(31 downto 0);
            o_Cout : out std_logic; -- Carry out
            o_LessThan : out std_logic; -- 1 if A < B, else 0
            o_Zero : out std_logic -- 1 if result is 0, else 0
        );
    end component;

    -- shifter component (for SLL, SRL, SRA)
    component Barrel_Shifter is
        port (
                data_in      : in  std_logic_vector(31 downto 0);
                shift_amount : in  std_logic_vector(4 downto 0);
                ALUOp : in std_logic_vector (3 downto 0);
                data_out     : out std_logic_vector(31 downto 0)
        );
    end component;

    component mux2t1_N is 
        generic (N : integer := 32);
        port (
            i_S          : in std_logic;
            i_D0         : in std_logic_vector(N-1 downto 0);
            i_D1         : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0)
        );
    end component;

begin

    --add/sub (ADD : 0010, SUB : 0110)
    addSub_inst : addSub_32bit
        port map (
            i_A => i_A,
            i_B => i_B,
            i_Cin => i_Control(2), -- bit 2 is 0 for add, 1 for sub
            o_Sum => s_addSub_result,
            o_Cout => s_CarryOut,
            o_LessThan => s_lessThan,
            o_Zero => s_zero,
            o_Overflow => o_Overflow
        );

    -- shifter operations (SLL : 0100, SRL : 0101, SRA : 1101)
    shifter_inst : Barrel_Shifter
        port map (
            data_in => i_A,
            shift_amount => i_B(4 downto 0), -- Use lower 5 bits for shift amount
            ALUOp => i_Control, -- bits for shift control
            data_out => s_Shifter_result
        );

    -- (SLT : 0111) -- set less than
    -- if A < B then result is 1 else 0
    s_SLT_result <= s_lessThan;

    -- (SLTU : 1100) -- set less than unsigned (corrected from 1000, so 2nd bit is 1 to use subtractor)
    s_SLTU_result <= not s_CarryOut; -- if no carry out from A - B, then A < B unsigned

    -- AND : 0000
    s_And_result <= i_A and i_B;

    -- OR : 0001
    s_Or_result <= i_A or i_B;

    -- XOR : 0011
    s_Xor_result <= i_A xor i_B;

    -- Zero flag: set when result is zero
    o_Zero <= s_zero;
    
    -- Less than flag: use internal signal for consistency
    o_LessThan <= s_lessThan;

    -- Carry out flag from adder/subtractor
    o_CarryOut <= s_CarryOut;

    -- signal for EQ condition (for BEQ)
    s_branch_eq <= '1' when s_zero = '1' else '0';

    -- signal for NE condition (for BNE)
    s_branch_ne <= '1' when s_zero = '0' else '0';

    -- signal for LT condition (for BLT)
    s_branch_lt <= s_lessThan;

    -- signal for GE condition (for BGE)
    s_branch_ge <= '1' when s_lessThan = '0' else '0';

    -- signal for LTU condition (for BLTU)
    s_branch_ltu <= not s_CarryOut; -- if no carry out from A - B, then A < B unsigned

    -- signal for GEU condition (for BGEU)
    s_branch_geu <= s_CarryOut; -- if carry out from A - B, then A >= B unsigned

    -- MUX to select output based on control signal
    with i_Control select
        o_Result <= s_addSub_result when "0010" | "0110",
                    s_And_result when "0000",
                    s_Or_result when "0001",
                    s_Xor_result when "0011",
                    (31 downto 1 => '0') & s_SLT_result when "0111",
                    (31 downto 1 => '0') & s_SLTU_result when "1100",
                    s_Shifter_result when "0100" | "0101" | "1101",
                    (others => '0') when others; -- default to 0

    -- Branch condition met flag (for BEQ : 0110, BNE : 0110, BLT : 0111, BGE : 0111, BLTU : 1100, BGEU : 1100)
    with i_Func3 select
        o_BranchCondMet <= s_branch_eq when "000" else
                           s_branch_ne when "001" else
                           s_branch_lt when "100" else
                           s_branch_ge when "101" else
                           s_branch_ltu when "110" else
                           s_branch_geu when "111" else
                           '0'; -- default to 0

end architecture mixed;
