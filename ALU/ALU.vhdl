library ieee;
use ieee.std_logic_1164.all;

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
    signal s_carry_out: std_logic; -- Carry out from adder/subtractor
    signal s_addSub_zero: std_logic; -- Zero flag from adder/subtractor
    signal s_addSub_lessThan: std_logic; -- Less than flag from adder/sub
    signal s_And_result: std_logic_vector(31 downto 0); -- Result from AND operation
    signal s_Or_result: std_logic_vector(31 downto 0); -- Result from OR operation
    signal s_Shifter_result: std_logic_vector(31 downto 0); -- Result from shifter

    component addSub_32bit is
        port (
            i_A : in std_logic_vector(31 downto 0);
            i_B : in std_logic_vector(31 downto 0);
            i_Cin : in std_logic; -- 0 for add, 1 for subtract
            o_Sum : out std_logic_vector(31 downto 0);
            o_Cout : out std_logic;
            o_LessThan : out std_logic; -- 1 if A < B, else 0
            o_Zero : out std_logic -- 1 if result is 0, else 0
        );
    end component;

    -- Shifter to be implemented later

    -- AND

    -- OR

    -- XOR

    with i_Control select
        o_Result <= s_shiftout 0000, s_shiftout 0001

    -- Zero flag output
    s_addSub_zero <= o_Zero;
    o_Zero <= s_addSub_zero;

    -- Less than flag output
    s_addSub_lessThan <= o_LessThan;
    o_LessThan <= s_addSub_lessThan;

    -- Carry out output
    s_carry_out <= o_CarryOut;
    o_CarryOut <= s_carry_out;

end architecture mixed;
