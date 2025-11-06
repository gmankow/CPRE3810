-- MEM/WB Register
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MEM_WB_Reg is
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic; -- Reset signal to clear the pipeline stage
        i_Halt : in std_logic; -- Halt signal to freeze the pipeline stage
        i_PCorMemtoReg : in std_logic; -- PC or Memory to Register input
        i_Fuct3 : in std_logic_vector(2 downto 0); -- Function 3 input
        i_ALUout : in std_logic_vector(31 downto 0); -- ALU output input
        i_MemReadData : in std_logic_vector(31 downto 0); -- Memory read data input
        i_PCPlus4 : in std_logic_vector(31 downto 0); -- PC + 4 input
        o_Halt : out std_logic; -- Halt signal output
        o_PCorMemtoReg : out std_logic; -- PC or Memory to Register output
        o_ALUout : out std_logic_vector(31 downto 0); -- ALU output output
        o_MemReadData : out std_logic_vector(31 downto 0); -- Memory read data output
        o_PCPlus4 : out std_logic_vector(31 downto 0); -- PC + 4 output
        o_Fuct3 : out std_logic_vector(2 downto 0) -- Function 3 output
    );
end entity MEM_WB_Reg;

architecture structural of MEM_WB_Reg is

    component register_N
        generic (
            N : integer := 32;
            INIT_VALUE : std_logic_vector(31 downto 0) := (others => '0')
        );
        port(
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(N-1 downto 0);
            o_Q : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal Halt_reg : std_logic_vector(0 downto 0);
    signal PCorMemtoReg_reg : std_logic_vector(0 downto 0);
    signal Fuct3_reg : std_logic_vector(2 downto 0);
    signal ALUout_reg : std_logic_vector(31 downto 0);
    signal MemReadData_reg : std_logic_vector(31 downto 0);
    signal PCPlus4_reg : std_logic_vector(31 downto 0);

begin
    
    -- Instantiate registers for each output
    Halt_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_Halt,
            o_Q => Halt_reg
        );

    PCorMemtoReg_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_PCorMemtoReg,
            o_Q => PCorMemtoReg_reg
        );

    Fuct3_reg_inst : register_N
        generic map (N => 3)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_Fuct3,
            o_Q => Fuct3_reg
        );

    ALUout_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_ALUout,
            o_Q => ALUout_reg
        );

    MemReadData_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_MemReadData,
            o_Q => MemReadData_reg
        );

    PCPlus4_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PCPlus4,
            o_Q => PCPlus4_reg
        );

    -- Connect outputs
    o_Halt <= Halt_reg(0);
    o_PCorMemtoReg <= PCorMemtoReg_reg(0);
    o_Fuct3 <= Fuct3_reg;
    o_ALUout <= ALUout_reg;
    o_MemReadData <= MemReadData_reg;
    o_PCPlus4 <= PCPlus4_reg;

end architecture structural;