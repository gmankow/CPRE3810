library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
    port (
        i_A : in std_logic_vector(31 downto 0); -- Input A
        i_B : in std_logic_vector(31 downto 0); -- Input B
        i_Control : in std_logic_vector(3 downto 0); -- ALU control signal (4 bits)
        o_Result : out std_logic_vector(31 downto 0); -- ALU result output
        o_Zero : out std_logic; -- '1' if result is zero, else '0'
        o_LessThan : out std_logic; -- '1' if A < B, else '0'
        o_CarryOut : out std_logic -- Carry out from addition/subtraction
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

    -- TODO shifter component (for SLL, SRL, SRA)

begin

    --add/sub (ADD : 0010, SUB : 0110)
    addSub_inst : addSub_32bit
        port map (
            i_A => i_A,
            i_B => i_B,
            i_Cin => i_Control(2), -- bit 2 is 0 for add, 1 for sub
            o_Sum => s_addSub_result,
            o_Cout => o_CarryOut,
            o_LessThan => s_lessThan,
            o_Zero => s_zero
        );

    -- TODO: Implement shifter operations (SLL : 0100, SRL : 0101, SRA : 1101)
    -- For now, set to zero
    s_Shifter_result <= (others => '0');

    -- (SLT : 0111) -- set less than
    -- if A < B then result is 1 else 0
    s_SLT_result <= s_internal_lessThan;

    -- (SLTU : 1000) -- set less than unsigned
    s_SLTU_result <= '1' when unsigned(i_A) < unsigned(i_B) else '0';

    -- AND : 0000
    s_And_result <= i_A and i_B;

    -- OR : 0001
    s_Or_result <= i_A or i_B;

    -- XOR : 0011
    s_Xor_result <= i_A xor i_B;

    -- Zero flag: set when result is zero
    o_Zero <= '1' when o_Result = x"00000000" else '0';
    
    -- Less than flag: use internal signal for consistency
    o_LessThan <= s_lessThan;

    -- MUX to select output based on control signal
    with i_Control select
        o_Result <= s_addSub_result when "0010" | "0110",
                    s_And_result when "0000",
                    s_Or_result when "0001",
                    s_Xor_result when "0011",
                    (31 downto 1 => '0') & s_SLT_result when "0111",
                    (31 downto 1 => '0') & s_SLTU_result when "1000",
                    s_Shifter_result when "0100" | "0101" | "1101",
                    (others => '0') when others; -- default to 0

end architecture mixed;
