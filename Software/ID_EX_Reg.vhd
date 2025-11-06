-- ID/EX Register
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ID_EX_Reg is
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic; -- Reset signal to clear the pipeline stage
        i_Halt : in std_logic; -- Halt signal to freeze the pipeline stage
        i_ALUsrcA : in std_logic; -- ALU source A input
        i_ALUsrcA0 : in std_logic; -- ALU source A0 input (load 0s)
        i_ALUsrcB : in std_logic; -- ALU source B input
        i_ALUop : in std_logic_vector(3 downto 0); -- ALU operation input
        i_Fuct3 : in std_logic_vector(2 downto 0); -- Function 3 input
        i_MemWrite : in std_logic; -- Memory write enable input
        i_Jump : in std_logic; -- Jump signal input
        i_Jalr : in std_logic; -- JALR signal input
        i_Branch : in std_logic; -- Branch signal input
        i_PC : in std_logic_vector(31 downto 0); -- PC input
        i_PCPlus4 : in std_logic_vector(31 downto 0); -- PC + 4 input
        i_PCPlusImm : in std_logic_vector(31 downto 0); -- PC + Immediate input
        i_Immediate : in std_logic_vector(31 downto 0); -- Immediate value input
        i_Out1 : in std_logic_vector(31 downto 0); -- Read data 1 input
        i_Out2 : in std_logic_vector(31 downto 0); -- Read data 2 input
        i_PCorMemtoReg : in std_logic; -- PC or Memory to Register input
        o_Halt : out std_logic; -- Halt signal output
        o_ALUsrcA : out std_logic; -- ALU source A output
        o_ALUsrcA0 : out std_logic; -- ALU source A0 output
        o_ALUsrcB : out std_logic; -- ALU source B output
        o_ALUop : out std_logic_vector(3 downto 0); -- ALU operation output
        o_Fuct3 : out std_logic_vector(2 downto 0); -- Function 3 output
        o_MemWrite : out std_logic; -- Memory write enable output
        o_Jump : out std_logic; -- Jump signal output
        o_Jalr : out std_logic; -- JALR signal output
        o_Branch : out std_logic; -- Branch signal output
        o_PC : out std_logic_vector(31 downto 0); -- PC output
        o_PCPlus4 : out std_logic_vector(31 downto 0); -- PC + 4 output
        o_PCPlusImm : out std_logic_vector(31 downto 0); -- PC + Immediate output
        o_Immediate : out std_logic_vector(31 downto 0); -- Immediate value output
        o_Out1 : out std_logic_vector(31 downto 0); -- Read data 1 output
        o_Out2 : out std_logic_vector(31 downto 0); -- Read data 2 output
        o_PCorMemtoReg : out std_logic -- PC or Memory to Register output
    );
end entity ID_EX_Reg;

architecture structural of ID_EX_Reg is

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
    signal ALUsrcA_reg : std_logic_vector(0 downto 0);
    signal ALUsrcA0_reg : std_logic_vector(0 downto 0);
    signal ALUsrcB_reg : std_logic_vector(0 downto 0);
    signal ALUop_reg : std_logic_vector(3 downto 0);
    signal Fuct3_reg : std_logic_vector(2 downto 0);
    signal MemWrite_reg : std_logic_vector(0 downto 0);
    signal Jump_reg : std_logic_vector(0 downto 0);
    signal Jalr_reg : std_logic_vector(0 downto 0);
    signal Branch_reg : std_logic_vector(0 downto 0);
    signal PC_reg : std_logic_vector(31 downto 0);
    signal PCPlus4_reg : std_logic_vector(31 downto 0);
    signal PCPlusImm_reg : std_logic_vector(31 downto 0);
    signal Immediate_reg : std_logic_vector(31 downto 0);
    signal Out1_reg : std_logic_vector(31 downto 0);
    signal Out2_reg : std_logic_vector(31 downto 0);
    signal PCorMemtoReg_reg : std_logic_vector(0 downto 0);

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

    ALUsrcA_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_ALUsrcA,
            o_Q => ALUsrcA_reg
        );

    ALUsrcA0_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_ALUsrcA0,
            o_Q => ALUsrcA0_reg
        );

    ALUsrcB_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_ALUsrcB,
            o_Q => ALUsrcB_reg
        );

    ALUop_reg_inst : register_N
        generic map (N => 4)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_ALUop,
            o_Q => ALUop_reg
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
    
    MemWrite_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_MemWrite,
            o_Q => MemWrite_reg
        );
    
    Jump_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_Jump,
            o_Q => Jump_reg
        );
        
    Jalr_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_Jalr,
            o_Q => Jalr_reg
        );
    
    Branch_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_Branch,
            o_Q => Branch_reg
        );
    
    PC_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PC,
            o_Q => PC_reg
        );

    PCPlus4_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PCPlus4,
            o_Q => PCPlus4_reg
        );

    PCPlusImm_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PCPlusImm,
            o_Q => PCPlusImm_reg
        );
    
    Immediate_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_Immediate,
            o_Q => Immediate_reg
        );

    Out1_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_Out1,
            o_Q => Out1_reg
        );
    
    Out2_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_Out2,
            o_Q => Out2_reg
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

    -- Connect outputs
    o_Halt <= Halt_reg(0);
    o_ALUsrcA <= ALUsrcA_reg(0);
    o_ALUsrcA0 <= ALUsrcA0_reg(0);
    o_ALUsrcB <= ALUsrcB_reg(0);
    o_ALUop <= ALUop_reg;
    o_Fuct3 <= Fuct3_reg;
    o_MemWrite <= MemWrite_reg(0);
    o_Jump <= Jump_reg(0);
    o_Jalr <= Jalr_reg(0);
    o_Branch <= Branch_reg(0);
    o_PC <= PC_reg;
    o_PCPlus4 <= PCPlus4_reg;
    o_PCPlusImm <= PCPlusImm_reg;
    o_Immediate <= Immediate_reg;
    o_Out1 <= Out1_reg;
    o_Out2 <= Out2_reg;
    o_PCorMemtoReg <= PCorMemtoReg_reg(0);

end architecture structural;
