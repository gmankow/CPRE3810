-- EX/MEM Register
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity EX_MEM_Reg is
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic; -- Reset signal to clear the pipeline stage
        i_Halt : in std_logic; -- Halt signal to freeze the pipeline stage
        i_MemWrite : in std_logic; -- Memory write enable input
        i_RegWrite : in std_logic;
        i_Fuct3 : in std_logic_vector(2 downto 0); -- Function 3 input
        i_PCorMemtoReg : in std_logic; -- PC or Memory to Register input
        i_Jump : in std_logic; -- Jump signal input
        i_Jalr : in std_logic; -- JALR signal input
        i_Branch : in std_logic; -- Branch signal input
        i_Branch_cond_met : in std_logic; -- Branch condition met input
        i_PCPlus4 : in std_logic_vector(31 downto 0); -- PC + 4 input
        i_ALUout : in std_logic_vector(31 downto 0); -- ALU output input
        i_Out2 : in std_logic_vector(31 downto 0); -- Read data 2 input
        i_PCPlusImm : in std_logic_vector(31 downto 0); -- PC + Immediate input
        i_RegWrAddr : in std_logic_vector(4 downto 0);

        o_Halt : out std_logic; -- Halt signal output
        o_MemWrite : out std_logic; -- Memory write enable output
        o_RegWrite : out std_logic;
        o_Fuct3 : out std_logic_vector(2 downto 0); -- Function 3 output
        o_PCorMemtoReg : out std_logic_vector(1 downto 0); -- PC or Memory to Register output
        o_Jump : out std_logic; -- Jump signal output
        o_Jalr : out std_logic; -- JALR signal output
        o_Branch : out std_logic; -- Branch signal output
        o_Branch_cond_met : out std_logic; -- Branch condition met output
        o_PCPlus4 : out std_logic_vector(31 downto 0); -- PC + 4 output
        o_ALUout : out std_logic_vector(31 downto 0); -- ALU output output
        o_Out2 : out std_logic_vector(31 downto 0); -- Read data 2 output
        o_PCPlusImm : out std_logic_vector(31 downto 0); -- PC + Immediate output
        o_RegWrAddr : out std_logic_vector(4 downto 0)
    );
end entity EX_MEM_Reg;

architecture structural of EX_MEM_Reg is

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

    -- Internal register output signals
    signal Halt_reg : std_logic_vector(0 downto 0);
    signal MemWrite_reg : std_logic_vector(0 downto 0);
    signal RegWrite_reg : std_logic_vector(0 downto 0);
    signal Fuct3_reg : std_logic_vector(2 downto 0);
    signal PCorMemtoReg_reg : std_logic_vector(1 downto 0);
    signal Jump_reg : std_logic_vector(0 downto 0);
    signal Jalr_reg : std_logic_vector(0 downto 0);
    signal Branch_reg : std_logic_vector(0 downto 0);
    signal Branch_cond_met_reg : std_logic_vector(0 downto 0);
    signal PCPlus4_reg : std_logic_vector(31 downto 0);
    signal ALUout_reg : std_logic_vector(31 downto 0);
    signal Out2_reg : std_logic_vector(31 downto 0);
    signal PCPlusImm_reg : std_logic_vector(31 downto 0);
    signal RegWrAddr_reg : std_logic_vector(4 downto 0);

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

    MemWrite_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_MemWrite,
            o_Q => MemWrite_reg
        );

    RegWrite_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_RegWrite,
            o_Q => RegWrite_reg
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

    PCorMemtoReg_reg_inst : register_N
        generic map (N => 2)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PCorMemtoReg,
            o_Q => PCorMemtoReg_reg
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

    Branch_cond_met_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D(0) => i_Branch_cond_met,
            o_Q => Branch_cond_met_reg
        );

    PCPlus4_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PCPlus4,
            o_Q => PCPlus4_reg
        );

    ALUout_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_ALUout,
            o_Q => ALUout_reg
        );
    
    Out2_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_Out2,
            o_Q => Out2_reg
        );

    PCPlusImm_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_PCPlusImm,
            o_Q => PCPlusImm_reg
        );

    RegWrAddr_reg_inst : register_N
        generic map (N => 5)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => '1',
            i_D => i_RegWrAddr,
            o_Q => RegWrAddr_reg
        );

    -- Connect outputs
    o_Halt <= Halt_reg(0);
    o_MemWrite <= MemWrite_reg(0);
    o_RegWrite <= RegWrite_reg(0);
    o_Fuct3 <= Fuct3_reg;
    o_PCorMemtoReg <= PCorMemtoReg_reg;
    o_Jump <= Jump_reg(0);
    o_Jalr <= Jalr_reg(0);
    o_Branch <= Branch_reg(0);
    o_Branch_cond_met <= Branch_cond_met_reg(0);
    o_PCPlus4 <= PCPlus4_reg;
    o_ALUout <= ALUout_reg;
    o_Out2 <= Out2_reg;
    o_PCPlusImm <= PCPlusImm_reg;
    o_RegWrAddr <= RegWrAddr_reg;

end architecture structural;