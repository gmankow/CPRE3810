-- ID/EX Register
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ID_EX_Reg is
    port (
        i_CLK : in std_logic;
        i_RST : in std_logic; -- Reset signal to clear the pipeline stage
        i_Stall : in std_logic; -- '1' to stall (hold current value)
        i_Flush : in std_logic; -- '1' to flush (clear to '0's)
        
        i_Halt : in std_logic; -- Halt signal to freeze the pipeline stage
        i_ALUsrcA : in std_logic; -- ALU source A input
        i_ALUsrcA0 : in std_logic; -- ALU source A0 input (load 0s)
        i_ALUsrcB : in std_logic; -- ALU source B input
        i_ALUop : in std_logic_vector(3 downto 0); -- ALU operation input
        i_MemWrite : in std_logic; -- Memory write enable input
        i_RegWrite : in std_logic; -- For dircet data in
        i_Jump : in std_logic; -- Jump signal input
        i_Jalr : in std_logic; -- JALR signal input
        i_Branch : in std_logic; -- Branch signal input
        i_PCorMemtoReg : in std_logic_vector(1 downto 0); -- PC or Memory to Register input

        i_Fuct3 : in std_logic_vector(2 downto 0); -- Function 3 input
        i_PC : in std_logic_vector(31 downto 0); -- PC input
        i_PCPlus4 : in std_logic_vector(31 downto 0); -- PC + 4 input
        i_PCPlusImm : in std_logic_vector(31 downto 0); -- PC + Immediate input
        i_Immediate : in std_logic_vector(31 downto 0); -- Immediate value input
        i_Out1 : in std_logic_vector(31 downto 0); -- Read data 1 input
        i_Out2 : in std_logic_vector(31 downto 0); -- Read data 2 input
        i_RegWrAddr : in std_logic_vector(4 downto 0);
        
        o_Halt : out std_logic; -- Halt signal output
        o_ALUsrcA : out std_logic; -- ALU source A output
        o_ALUsrcA0 : out std_logic; -- ALU source A0 output
        o_ALUsrcB : out std_logic; -- ALU source B output
        o_ALUop : out std_logic_vector(3 downto 0); -- ALU operation output
        o_MemWrite : out std_logic; -- Memory write enable output
        o_RegWrite : out std_logic;
        o_Jump : out std_logic; -- Jump signal output
        o_Jalr : out std_logic; -- JALR signal output
        o_Branch : out std_logic; -- Branch signal output
        o_PCorMemtoReg : out std_logic_vector(1 downto 0); -- PC or Memory to Register output
        o_Fuct3 : out std_logic_vector(2 downto 0); -- Function 3 output
        o_PC : out std_logic_vector(31 downto 0); -- PC output
        o_PCPlus4 : out std_logic_vector(31 downto 0); -- PC + 4 output
        o_PCPlusImm : out std_logic_vector(31 downto 0); -- PC + Immediate output
        o_Immediate : out std_logic_vector(31 downto 0); -- Immediate value output
        o_Out1 : out std_logic_vector(31 downto 0); -- Read data 1 output
        o_Out2 : out std_logic_vector(31 downto 0); -- Read data 2 output
        o_RegWrAddr : out std_logic_vector(4 downto 0)
        
    );
end entity ID_EX_Reg;

architecture structural of ID_EX_Reg is

    component register_N
        generic (
            N : integer := 32;
            INIT_VALUE : std_logic_vector(N-1 downto 0) := (others => '0')
        );
        port(
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(N-1 downto 0);
            o_Q : out std_logic_vector(N-1 downto 0)
        );
    end component;

    -- Internal signals to hold register inputs (for flush muxing)
    signal s_D_Halt : std_logic;
    signal s_D_ALUsrcA : std_logic;
    signal s_D_ALUsrcA0 : std_logic;
    signal s_D_ALUsrcB : std_logic;
    signal s_D_MemWrite : std_logic;
    signal s_D_RegWrite : std_logic;
    signal s_D_Jump : std_logic;
    signal s_D_Jalr : std_logic;
    signal s_D_Branch : std_logic;
    signal s_D_ALUop : std_logic_vector(3 downto 0);
    signal s_D_PCorMemtoReg : std_logic_vector(1 downto 0);
    signal s_D_Fuct3 : std_logic_vector(2 downto 0);
    signal s_D_PC : std_logic_vector(31 downto 0);
    signal s_D_PCPlus4 : std_logic_vector(31 downto 0);
    signal s_D_PCPlusImm : std_logic_vector(31 downto 0);
    signal s_D_Immediate : std_logic_vector(31 downto 0);
    signal s_D_Out1 : std_logic_vector(31 downto 0);
    signal s_D_Out2 : std_logic_vector(31 downto 0);
    signal s_D_RegWrAddr : std_logic_vector(4 downto 0);

    -- Internal signals for register outputs
    signal Halt_reg : std_logic_vector(0 downto 0);
    signal ALUsrcA_reg : std_logic_vector(0 downto 0);
    signal ALUsrcA0_reg : std_logic_vector(0 downto 0);
    signal ALUsrcB_reg : std_logic_vector(0 downto 0);
    signal MemWrite_reg : std_logic_vector(0 downto 0);
    signal RegWrite_reg : std_logic_vector(0 downto 0);
    signal Jump_reg : std_logic_vector(0 downto 0);
    signal Jalr_reg : std_logic_vector(0 downto 0);
    signal Branch_reg : std_logic_vector(0 downto 0);
    signal ALUop_reg : std_logic_vector(3 downto 0);
    signal PCorMemtoReg_reg : std_logic_vector(1 downto 0);
    signal Fuct3_reg : std_logic_vector(2 downto 0);
    signal PC_reg : std_logic_vector(31 downto 0);
    signal PCPlus4_reg : std_logic_vector(31 downto 0);
    signal PCPlusImm_reg : std_logic_vector(31 downto 0);
    signal Immediate_reg : std_logic_vector(31 downto 0);
    signal Out1_reg : std_logic_vector(31 downto 0);
    signal Out2_reg : std_logic_vector(31 downto 0);
    signal RegWrAddr_reg : std_logic_vector(4 downto 0);
    signal s_WE : std_logic;

begin

    -- Stall logic: Write Enable is active ('1') only when not stalled ('0')
    s_WE <= not i_Stall;

    -- Flush logic: When i_Flush = '1', load all '0's (safe values)
    -- This effectively inserts a "bubble" into the pipeline.
    s_D_Halt <= '0' when i_Flush = '1' else i_Halt;
    s_D_ALUsrcA <= '0' when i_Flush = '1' else i_ALUsrcA;
    s_D_ALUsrcA0 <= '0' when i_Flush = '1' else i_ALUsrcA0;
    s_D_ALUsrcB <= '0' when i_Flush = '1' else i_ALUsrcB;
    s_D_MemWrite <= '0' when i_Flush = '1' else i_MemWrite;
    s_D_RegWrite <= '0' when i_Flush = '1' else i_RegWrite;
    s_D_Jump <= '0' when i_Flush = '1' else i_Jump;
    s_D_Jalr <= '0' when i_Flush = '1' else i_Jalr;
    s_D_Branch <= '0' when i_Flush = '1' else i_Branch;
    s_D_ALUop <= (others => '0') when i_Flush = '1' else i_ALUop;
    s_D_PCorMemtoReg <= (others => '0') when i_Flush = '1' else i_PCorMemtoReg;
    s_D_Fuct3 <= (others => '0') when i_Flush = '1' else i_Fuct3;
    s_D_PC <= (others => '0') when i_Flush = '1' else i_PC;
    s_D_PCPlus4 <= (others => '0') when i_Flush = '1' else i_PCPlus4;
    s_D_PCPlusImm <= (others => '0') when i_Flush = '1' else i_PCPlusImm;
    s_D_Immediate <= (others => '0') when i_Flush = '1' else i_Immediate;
    s_D_Out1 <= (others => '0') when i_Flush = '1' else i_Out1;
    s_D_Out2 <= (others => '0') when i_Flush = '1' else i_Out2;
    s_D_RegWrAddr <= (others => '0') when i_Flush = '1' else i_RegWrAddr;


    -- Instantiate registers for each output
    Halt_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_Halt,
            o_Q => Halt_reg
        );

    ALUsrcA_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_ALUsrcA,
            o_Q => ALUsrcA_reg
        );

    ALUsrcA0_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_ALUsrcA0,
            o_Q => ALUsrcA0_reg
        );

    ALUsrcB_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_ALUsrcB,
            o_Q => ALUsrcB_reg
        );

    ALUop_reg_inst : register_N
        generic map (N => 4)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_ALUop,
            o_Q => ALUop_reg
        );
    
    Fuct3_reg_inst : register_N
        generic map (N => 3)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_Fuct3,
            o_Q => Fuct3_reg
        );
    
    MemWrite_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_MemWrite,
            o_Q => MemWrite_reg
        );

    -- <<< NEW REGISTER >>>
    RegWrite_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_RegWrite,
            o_Q => RegWrite_reg
        );
    
    Jump_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_Jump,
            o_Q => Jump_reg
        );
        
    Jalr_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_Jalr,
            o_Q => Jalr_reg
        );
    
    Branch_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D(0) => s_D_Branch,
            o_Q => Branch_reg
        );
    
    PC_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_PC,
            o_Q => PC_reg
        );

    PCPlus4_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_PCPlus4,
            o_Q => PCPlus4_reg
        );

    PCPlusImm_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_PCPlusImm,
            o_Q => PCPlusImm_reg
        );
    
    Immediate_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_Immediate,
            o_Q => Immediate_reg
        );

    Out1_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_Out1,
            o_Q => Out1_reg
        );
    
    Out2_reg_inst : register_N
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_Out2,
            o_Q => Out2_reg
        );

    -- <<< NEW REGISTER >>>
    RegWrAddr_reg_inst : register_N
        generic map (N => 5)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_RegWrAddr,
            o_Q => RegWrAddr_reg
        );

    -- <<< MODIFIED REGISTER >>>
    PCorMemtoReg_reg_inst : register_N
        generic map (N => 2) -- Was 1 bit, now 2
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => s_WE,
            i_D => s_D_PCorMemtoReg, -- Was i_D(0)
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
    o_RegWrite <= RegWrite_reg(0); -- <<< ADDED
    o_Jump <= Jump_reg(0);
    o_Jalr <= Jalr_reg(0);
    o_Branch <= Branch_reg(0);
    o_PC <= PC_reg;
    o_PCPlus4 <= PCPlus4_reg;
    o_PCPlusImm <= PCPlusImm_reg;
    o_Immediate <= Immediate_reg;
    o_Out1 <= Out1_reg;
    o_Out2 <= Out2_reg;
    o_PCorMemtoReg <= PCorMemtoReg_reg; -- <<< MODIFIED
    o_RegWrAddr <= RegWrAddr_reg;     -- <<< ADDED

end architecture structural;