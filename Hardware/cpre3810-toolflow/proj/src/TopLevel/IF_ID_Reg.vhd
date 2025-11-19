-- IF/ID Register
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IF_ID_Reg is
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic; -- Reset signal to clear the pipeline stage
        i_Stall : in std_logic; -- For future use, to hold current value
        i_Flush : in std_logic; -- For future use, for nop clearing
        i_PCPlus4 : in std_logic_vector(31 downto 0); -- PC + 4 input
        i_PC : in std_logic_vector(31 downto 0); -- PC input
        i_Instruction : in std_logic_vector(31 downto 0); -- Instruction input
        o_PCPlus4 : out std_logic_vector(31 downto 0); -- PC + 4 output
        o_Instruction : out std_logic_vector(31 downto 0); -- Instruction output
        o_PC : out std_logic_vector(31 downto 0) -- PC output
    );
end entity IF_ID_Reg;

architecture structural of IF_ID_Reg is

    component register_N
        generic (
            N : integer := 32;
            INIT_VALUE : std_logic_vector(N-1 downto 0) := (others => '0')
        );
        port(
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(31 downto 0);
            o_Q : out std_logic_vector(31 downto 0)
        );
    end component;

    -- This is for future use, nop instruction to force load
    constant NOP_INSTRUCTION : std_logic_vector(31 downto 0) := x"00000013";

    -- Internal signals for register inputs
    signal s_WE : std_logic;
    signal s_D_PCPlus4 : std_logic_vector(31 downto 0);
    signal s_D_Instruction : std_logic_vector(31 downto 0);
    signal s_D_PC : std_logic_vector(31 downto 0);

    -- Internal signals for register outputs
    signal PCPlus4_reg : std_logic_vector(31 downto 0);
    signal Instruction_reg : std_logic_vector(31 downto 0);
    signal PC_reg : std_logic_vector(31 downto 0);

begin

    -- Stall logic, write enable is active only when not stalled
    s_WE <= i_Stall;
    

    s_D_Instruction <= NOP_INSTRUCTION when i_Flush = '1' else
        i_Instruction;

    s_D_PCPlus4 <= (others => '0') when i_Flush = '1' else
        i_PCPlus4;

    s_D_PC <= (others => '0') when i_Flush = '1' else
        i_PC;

    -- Instantiate registers for each output
    PCPlus4_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_PCPlus4,
            o_Q => PCPlus4_reg
        );

    Instruction_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_Instruction,
            o_Q => Instruction_reg
        );

    PC_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_PC,
            o_Q => PC_reg
        );

    -- Connect outputs
    o_PCPlus4 <= PCPlus4_reg;
    o_Instruction <= Instruction_reg;
    o_PC <= PC_reg;

end architecture structural;
