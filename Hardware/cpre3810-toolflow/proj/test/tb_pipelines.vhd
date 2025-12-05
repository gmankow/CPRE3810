library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_pipelines is
end entity tb_pipelines;

architecture behavioral of tb_pipelines is

    component IF_ID_Reg is
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
    end component;

    component ID_EX_Reg is 
        port (
            i_CLK : in std_logic;
            i_RST : in std_logic; -- Reset signal to clear the pipeline stage
            i_Stall : in std_logic; -- '0' to stall (hold current value)
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
            i_Rs1Addr : in std_logic_vector(4 downto 0);
            i_Rs2Addr : in std_logic_vector(4 downto 0);
            
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
            o_RegWrAddr : out std_logic_vector(4 downto 0);
            o_Rs1Addr : out std_logic_vector(4 downto 0);
            o_Rs2Addr : out std_logic_vector(4 downto 0)
        );
    end component;

    component EX_MEM_Reg is
        port (
            i_CLK : in std_logic;
            i_RST : in std_logic; -- Reset signal to clear the pipeline stage
            i_Halt : in std_logic; -- Halt signal to freeze the pipeline stage
            i_MemWrite : in std_logic; -- Memory write enable input
            i_RegWrite : in std_logic;
            i_Fuct3 : in std_logic_vector(2 downto 0); -- Function 3 input
            i_PCorMemtoReg : in std_logic_vector(1 downto 0); -- PC or Memory to Register input
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
    end component;

    component MEM_WB_Reg is
        port (
            i_CLK           : in std_logic; -- Clock
            i_RST           : in std_logic; -- Reset
            
            -- Control Signals from MEM stage
            i_Halt          : in std_logic; -- Halt signal
            i_RegWrite      : in std_logic; -- Write enable for Register File
            i_PCorMemtoReg  : in std_logic_vector(1 downto 0); -- Mux select for WB data
            i_Fuct3         : in std_logic_vector(2 downto 0); -- funct3 (for load sign-extension)
            i_RegWrAddr     : in std_logic_vector(4 downto 0); -- Destination register address (rd)

            -- Data Signals from MEM stage
            i_ALUout        : in std_logic_vector(31 downto 0); -- Result from ALU
            i_dMemOut       : in std_logic_vector(31 downto 0); -- Data read from memory
            i_PCPlus4       : in std_logic_vector(31 downto 0); -- PC+4 (for JAL/JALR)
            
            -- Corresponding Outputs to WB stage
            o_Halt          : out std_logic;
            o_RegWrite      : out std_logic;
            o_PCorMemtoReg  : out std_logic_vector(1 downto 0);
            o_ALUout        : out std_logic_vector(31 downto 0);
            o_dMemOut       : out std_logic_vector(31 downto 0);
            o_PCPlus4       : out std_logic_vector(31 downto 0);
            o_Fuct3         : out std_logic_vector(2 downto 0);
            o_RegWrAddr     : out std_logic_vector(4 downto 0)
        );
    end component;

    -- Testbench signals for IF/ID Register
    signal s_IFID_i_CLK : std_logic;
    signal s_IFID_i_RST : std_logic; -- Reset signal to clear the pipeline stage
    signal s_IFID_i_Stall : std_logic; -- For future use, to hold current value
    signal s_IFID_i_Flush : std_logic; -- For future use, for nop clearing
    signal s_IFID_i_PCPlus4 : std_logic_vector(31 downto 0); -- PC + 4 input
    signal s_IFID_i_PC : std_logic_vector(31 downto 0); -- PC input
    signal s_IFID_i_Instruction : std_logic_vector(31 downto 0); -- Instruction input
    signal s_IFID_o_PCPlus4 : std_logic_vector(31 downto 0); -- PC + 4 output
    signal s_IFID_o_Instruction : std_logic_vector(31 downto 0); -- Instruction output
    signal s_IFID_o_PC : std_logic_vector(31 downto 0); -- PC output


    -- Testbench signals for ID/EX Register
    signal s_IDEX_i_CLK : std_logic;
    signal s_IDEX_i_RST : std_logic; -- Reset signal to clear the pipeline stage
    signal s_IDEX_i_Stall : std_logic; -- '0' to stall (hold current value)
    signal s_IDEX_i_Flush : std_logic; -- '1' to flush (clear to '0's)
    
    signal s_IDEX_i_Halt : std_logic; -- Halt signal to freeze the pipeline stage
    signal s_IDEX_i_ALUsrcA : std_logic; -- ALU source A input
    signal s_IDEX_i_ALUsrcA0 : std_logic; -- ALU source A0 input (load 0s)
    signal s_IDEX_i_ALUsrcB : std_logic; -- ALU source B input
    signal s_IDEX_i_ALUop : std_logic_vector(3 downto 0); -- ALU operation input
    signal s_IDEX_i_MemWrite : std_logic; -- Memory write enable input
    signal s_IDEX_i_RegWrite : std_logic; -- For dircet data in
    signal s_IDEX_i_Jump : std_logic; -- Jump signal input
    signal s_IDEX_i_Jalr : std_logic; -- JALR signal input
    signal s_IDEX_i_Branch : std_logic; -- Branch signal input
    signal s_IDEX_i_PCorMemtoReg : std_logic_vector(1 downto 0); -- PC or Memory to Register input

    signal s_IDEX_i_Fuct3 : std_logic_vector(2 downto 0); -- Function 3 input
    signal s_IDEX_i_PC : std_logic_vector(31 downto 0); -- PC input
    signal s_IDEX_i_PCPlus4 : std_logic_vector(31 downto 0); -- PC + 4 input
    signal s_IDEX_i_PCPlusImm : std_logic_vector(31 downto 0); -- PC + Immediate input
    signal s_IDEX_i_Immediate : std_logic_vector(31 downto 0); -- Immediate value input
    signal s_IDEX_i_Out1 : std_logic_vector(31 downto 0); -- Read data 1 input
    signal s_IDEX_i_Out2 : std_logic_vector(31 downto 0); -- Read data 2 input
    signal s_IDEX_i_RegWrAddr : std_logic_vector(4 downto 0);
    signal s_IDEX_i_Rs1Addr : std_logic_vector(4 downto 0);
    signal s_IDEX_i_Rs2Addr : std_logic_vector(4 downto 0);
    
    signal s_IDEX_o_Halt : std_logic; -- Halt signal output
    signal s_IDEX_o_ALUsrcA : std_logic; -- ALU source A output
    signal s_IDEX_o_ALUsrcA0 : std_logic; -- ALU source A0 output
    signal s_IDEX_o_ALUsrcB : std_logic; -- ALU source B output
    signal s_IDEX_o_ALUop : std_logic_vector(3 downto 0); -- ALU operation output
    signal s_IDEX_o_MemWrite : std_logic; -- Memory write enable output
    signal s_IDEX_o_RegWrite : std_logic;
    signal s_IDEX_o_Jump : std_logic; -- Jump signal output
    signal s_IDEX_o_Jalr : std_logic; -- JALR signal output
    signal s_IDEX_o_Branch : std_logic; -- Branch signal output
    signal s_IDEX_o_PCorMemtoReg : std_logic_vector(1 downto 0); -- PC or Memory to Register output
    signal s_IDEX_o_Fuct3 : std_logic_vector(2 downto 0); -- Function 3 output
    signal s_IDEX_o_PC : std_logic_vector(31 downto 0); -- PC output
    signal s_IDEX_o_PCPlus4 : std_logic_vector(31 downto 0); -- PC + 4 output
    signal s_IDEX_o_PCPlusImm : std_logic_vector(31 downto 0); -- PC + Immediate output
    signal s_IDEX_o_Immediate : std_logic_vector(31 downto 0); -- Immediate value output
    signal s_IDEX_o_Out1 : std_logic_vector(31 downto 0); -- Read data 1 output
    signal s_IDEX_o_Out2 : std_logic_vector(31 downto 0); -- Read data 2 output
    signal s_IDEX_o_RegWrAddr : std_logic_vector(4 downto 0);
    signal s_IDEX_o_Rs1Addr : std_logic_vector(4 downto 0);
    signal s_IDEX_o_Rs2Addr : std_logic_vector(4 downto 0);

    -- Testbench signals for EX/MEM Register
    signal s_EXMEM_i_CLK : std_logic;
    signal s_EXMEM_i_RST : std_logic; -- Reset signal to clear the pipeline stage
    signal s_EXMEM_i_Halt : std_logic; -- Halt signal to freeze the pipeline stage
    signal s_EXMEM_i_MemWrite : std_logic; -- Memory write enable input
    signal s_EXMEM_i_RegWrite : std_logic;
    signal s_EXMEM_i_Fuct3 : std_logic_vector(2 downto 0); -- Function 3 input
    signal s_EXMEM_i_PCorMemtoReg : std_logic_vector(1 downto 0); -- PC or Memory to Register input
    signal s_EXMEM_i_Jump : std_logic; -- Jump signal input
    signal s_EXMEM_i_Jalr : std_logic; -- JALR signal input
    signal s_EXMEM_i_Branch : std_logic; -- Branch signal input
    signal s_EXMEM_i_Branch_cond_met : std_logic; -- Branch condition met input
    signal s_EXMEM_i_PCPlus4 : std_logic_vector(31 downto 0); -- PC + 4 input
    signal s_EXMEM_i_ALUout : std_logic_vector(31 downto 0); -- ALU output input
    signal s_EXMEM_i_Out2 : std_logic_vector(31 downto 0); -- Read data 2 input
    signal s_EXMEM_i_PCPlusImm : std_logic_vector(31 downto 0); -- PC + Immediate input
    signal s_EXMEM_i_RegWrAddr : std_logic_vector(4 downto 0);

    signal s_EXMEM_o_Halt : std_logic; -- Halt signal output
    signal s_EXMEM_o_MemWrite : std_logic; -- Memory write enable output
    signal s_EXMEM_o_RegWrite : std_logic;
    signal s_EXMEM_o_Fuct3 : std_logic_vector(2 downto 0); -- Function 3 output
    signal s_EXMEM_o_PCorMemtoReg : std_logic_vector(1 downto 0); -- PC or Memory to Register output
    signal s_EXMEM_o_Jump : std_logic; -- Jump signal output
    signal s_EXMEM_o_Jalr : std_logic; -- JALR signal output
    signal s_EXMEM_o_Branch : std_logic; -- Branch signal output
    signal s_EXMEM_o_Branch_cond_met : std_logic; -- Branch condition met output
    signal s_EXMEM_o_PCPlus4 : std_logic_vector(31 downto 0); -- PC + 4 output
    signal s_EXMEM_o_ALUout : std_logic_vector(31 downto 0); -- ALU output output
    signal s_EXMEM_o_Out2 : std_logic_vector(31 downto 0); -- Read data 2 output
    signal s_EXMEM_o_PCPlusImm : std_logic_vector(31 downto 0); -- PC + Immediate output
    signal s_EXMEM_o_RegWrAddr : std_logic_vector(4 downto 0);

    -- Testbench signals for MEM/WB Register
    signal s_MEMWB_i_CLK           : std_logic; -- Clock
    signal s_MEMWB_i_RST           : std_logic; -- Reset
    
    -- Control Signals from MEM stage
    signal s_MEMWB_i_Halt          : std_logic; -- Halt signal
    signal s_MEMWB_i_RegWrite      : std_logic; -- Write enable for Register File
    signal s_MEMWB_i_PCorMemtoReg  : std_logic_vector(1 downto 0); -- Mux select for WB data
    signal s_MEMWB_i_Fuct3         : std_logic_vector(2 downto 0); -- funct3 (for load sign-extension)
    signal s_MEMWB_i_RegWrAddr     : std_logic_vector(4 downto 0); -- Destination register address (rd)

    -- Data Signals from MEM stage
    signal s_MEMWB_i_ALUout        : std_logic_vector(31 downto 0); -- Result from ALU
    signal s_MEMWB_i_dMemOut       : std_logic_vector(31 downto 0); -- Data read from memory
    signal s_MEMWB_i_PCPlus4       : std_logic_vector(31 downto 0); -- PC+4 (for JAL/JALR)
    
    -- Corresponding Outputs to WB stage
    signal s_MEMWB_o_Halt          : std_logic;
    signal s_MEMWB_o_RegWrite      : std_logic;
    signal s_MEMWB_o_PCorMemtoReg  : std_logic_vector(1 downto 0);
    signal s_MEMWB_o_ALUout        : std_logic_vector(31 downto 0);
    signal s_MEMWB_o_dMemOut       : std_logic_vector(31 downto 0);
    signal s_MEMWB_o_PCPlus4       : std_logic_vector(31 downto 0);
    signal s_MEMWB_o_Fuct3         : std_logic_vector(2 downto 0);
    signal s_MEMWB_o_RegWrAddr     : std_logic_vector(4 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    signal s_CLK : std_logic := '0';

begin

    --instantiate clock process
    -- Clock generation process
    clk_process : process
    begin
        loop
            s_CLK <= '0';
            wait for CLK_PERIOD / 2;
            s_CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Instantiate IF/ID Register
    UUT_IF_ID : IF_ID_Reg
        port map(
            i_CLK => s_CLK,
            i_RST => s_IFID_i_RST,
            i_Stall => s_IFID_i_Stall,
            i_Flush => s_IFID_i_Flush,
            i_PCPlus4 => s_IFID_i_PCPlus4,
            i_PC => s_IFID_i_PC,
            i_Instruction => s_IFID_i_Instruction,
            o_PCPlus4 => s_IFID_o_PCPlus4,
            o_Instruction => s_IFID_o_Instruction,
            o_PC => s_IFID_o_PC
        );

    s_IDEX_i_PCPlus4 <= s_IFID_o_PCPlus4;
    s_IDEX_i_PC <= s_IFID_o_PC;

    -- Instantiate ID/EX Register
    UUT_ID_EX : ID_EX_Reg
        port map(
            i_CLK => s_CLK,
            i_RST => s_IDEX_i_RST,
            i_Stall => s_IDEX_i_Stall,
            i_Flush => s_IDEX_i_Flush,
            i_Halt          => s_IDEX_i_Halt,
            i_ALUsrcA       => s_IDEX_i_ALUsrcA,
            i_ALUsrcA0      => s_IDEX_i_ALUsrcA0,
            i_ALUsrcB       => s_IDEX_i_ALUsrcB,
            i_ALUop         => s_IDEX_i_ALUop,
            i_MemWrite      => s_IDEX_i_MemWrite,
            i_RegWrite      => s_IDEX_i_RegWrite,
            i_Jump          => s_IDEX_i_Jump,
            i_Jalr          => s_IDEX_i_Jalr,
            i_Branch        => s_IDEX_i_Branch,
            i_PCorMemtoReg  => s_IDEX_i_PCorMemtoReg,
            i_Fuct3         => s_IDEX_i_Fuct3,
            i_PC            => s_IDEX_i_PC,
            i_PCPlus4       => s_IDEX_i_PCPlus4,
            i_PCPlusImm     => s_IDEX_i_PCPlusImm,
            i_Immediate     => s_IDEX_i_Immediate,
            i_Out1          => s_IDEX_i_Out1,
            i_Out2          => s_IDEX_i_Out2,
            i_RegWrAddr     => s_IDEX_i_RegWrAddr,
            i_Rs1Addr       => s_IDEX_i_Rs1Addr,
            i_Rs2Addr       => s_IDEX_i_Rs2Addr,
            
            o_Halt          => s_IDEX_o_Halt,
            o_ALUsrcA       => s_IDEX_o_ALUsrcA,
            o_ALUsrcA0      => s_IDEX_o_ALUsrcA0,
            o_ALUsrcB       => s_IDEX_o_ALUsrcB,
            o_ALUop         => s_IDEX_o_ALUop,
            o_MemWrite      => s_IDEX_o_MemWrite,
            o_RegWrite      => s_IDEX_o_RegWrite,
            o_Jump          => s_IDEX_o_Jump,
            o_Jalr          => s_IDEX_o_Jalr,
            o_Branch        => s_IDEX_o_Branch,
            o_PCorMemtoReg  => s_IDEX_o_PCorMemtoReg,
            o_Fuct3         => s_IDEX_o_Fuct3,
            o_PC            => s_IDEX_o_PC,
            o_PCPlus4       => s_IDEX_o_PCPlus4,
            o_PCPlusImm     => s_IDEX_o_PCPlusImm,
            o_Immediate     => s_IDEX_o_Immediate,
            o_Out1          => s_IDEX_o_Out1,
            o_Out2          => s_IDEX_o_Out2,
            o_RegWrAddr     => s_IDEX_o_RegWrAddr,
            o_Rs1Addr       => s_IDEX_o_Rs1Addr,
            o_Rs2Addr       => s_IDEX_o_Rs2Addr
        );

    s_EXMEM_i_Halt          <= s_IDEX_o_Halt;
    s_EXMEM_i_MemWrite      <= s_IDEX_o_MemWrite;
    s_EXMEM_i_RegWrite      <= s_IDEX_o_RegWrite;
    s_EXMEM_i_Fuct3         <= s_IDEX_o_Fuct3;
    s_EXMEM_i_PCorMemtoReg  <= s_IDEX_o_PCorMemtoReg;
    s_EXMEM_i_Jump          <= s_IDEX_o_Jump;
    s_EXMEM_i_Jalr          <= s_IDEX_o_Jalr;
    s_EXMEM_i_Branch        <= s_IDEX_o_Branch;
    s_EXMEM_i_PCPlus4       <= s_IDEX_o_PCPlus4;
    s_EXMEM_i_PCPlusImm     <= s_IDEX_o_PCPlusImm;
    s_EXMEM_i_RegWrAddr     <= s_IDEX_o_RegWrAddr;

    -- Instantiate EX/MEM Register
    UUT_EX_MEM : EX_MEM_Reg
        port map(
            i_CLK               => s_CLK,
            i_RST               => s_EXMEM_i_RST,
            i_Halt              => s_EXMEM_i_Halt,
            i_MemWrite          => s_EXMEM_i_MemWrite,
            i_RegWrite          => s_EXMEM_i_RegWrite,
            i_Fuct3             => s_EXMEM_i_Fuct3,
            i_PCorMemtoReg      => s_EXMEM_i_PCorMemtoReg,
            i_Jump              => s_EXMEM_i_Jump,
            i_Jalr              => s_EXMEM_i_Jalr,
            i_Branch            => s_EXMEM_i_Branch,
            i_Branch_cond_met   => s_EXMEM_i_Branch_cond_met,
            i_PCPlus4           => s_EXMEM_i_PCPlus4,
            i_ALUout            => s_EXMEM_i_ALUout,
            i_Out2              => s_EXMEM_i_Out2,
            i_PCPlusImm         => s_EXMEM_i_PCPlusImm,
            i_RegWrAddr         => s_EXMEM_i_RegWrAddr,
            
            o_Halt              => s_EXMEM_o_Halt,
            o_MemWrite          => s_EXMEM_o_MemWrite,
            o_RegWrite          => s_EXMEM_o_RegWrite,
            o_Fuct3             => s_EXMEM_o_Fuct3,
            o_PCorMemtoReg      => s_EXMEM_o_PCorMemtoReg,
            o_Jump              => s_EXMEM_o_Jump,
            o_Jalr              => s_EXMEM_o_Jalr,
            o_Branch            => s_EXMEM_o_Branch,
            o_Branch_cond_met   => s_EXMEM_o_Branch_cond_met,
            o_PCPlus4           => s_EXMEM_o_PCPlus4,
            o_ALUout            => s_EXMEM_o_ALUout,
            o_Out2              => s_EXMEM_o_Out2,
            o_PCPlusImm         => s_EXMEM_o_PCPlusImm,
            o_RegWrAddr         => s_EXMEM_o_RegWrAddr
        );

    s_MEMWB_i_Halt          <= s_EXMEM_o_Halt;
    s_MEMWB_i_RegWrite      <= s_EXMEM_o_RegWrite;
    s_MEMWB_i_PCorMemtoReg  <= s_EXMEM_o_PCorMemtoReg;
    s_MEMWB_i_Fuct3         <= s_EXMEM_o_Fuct3;
    s_MEMWB_i_RegWrAddr     <= s_EXMEM_o_RegWrAddr;
    s_MEMWB_i_ALUout        <= s_EXMEM_o_ALUout;
    s_MEMWB_i_PCPlus4       <= s_EXMEM_o_PCPlus4;

    -- Instantiate MEM/WB Register
    UUT_MEM_WB : MEM_WB_Reg
        port map(
            i_CLK           => s_CLK,
            i_RST           => s_MEMWB_i_RST,
            i_Halt          => s_MEMWB_i_Halt,
            i_RegWrite      => s_MEMWB_i_RegWrite,
            i_PCorMemtoReg  => s_MEMWB_i_PCorMemtoReg,
            i_Fuct3         => s_MEMWB_i_Fuct3,
            i_RegWrAddr     => s_MEMWB_i_RegWrAddr,
            i_ALUout        => s_MEMWB_i_ALUout,
            i_dMemOut       => s_MEMWB_i_dMemOut,
            i_PCPlus4       => s_MEMWB_i_PCPlus4,
            
            o_Halt          => s_MEMWB_o_Halt,
            o_RegWrite      => s_MEMWB_o_RegWrite,
            o_PCorMemtoReg  => s_MEMWB_o_PCorMemtoReg,
            o_ALUout        => s_MEMWB_o_ALUout,
            o_dMemOut       => s_MEMWB_o_dMemOut,
            o_PCPlus4       => s_MEMWB_o_PCPlus4,
            o_Fuct3         => s_MEMWB_o_Fuct3,
            o_RegWrAddr     => s_MEMWB_o_RegWrAddr
        );

    stim_proc : process
    begin
        -- initialize inputs
        s_IFID_i_RST <= '1';
        s_IDEX_i_RST <= '1';
        s_EXMEM_i_RST <= '1';
        s_MEMWB_i_RST <= '1';
        wait for CLK_PERIOD;
        
        -- Release Reset
        s_IFID_i_RST <= '0';
        s_IDEX_i_RST <= '0';
        s_EXMEM_i_RST <= '0';
        s_MEMWB_i_RST <= '0';

        s_IFID_i_Stall <= '1';
        s_IFID_i_Flush <= '0';
        s_IDEX_i_Stall <= '1';

        wait for CLK_PERIOD;

        -- 2. TEST IF/ID PASS-THROUGH
        -- Expect inputs to appear at outputs on next rising edge
        s_IFID_i_PCPlus4     <= x"10000004";
        wait for CLK_PERIOD;

        -- 3. TEST IF/ID FLUSH (Active Low '0')
        -- Input remains valid, but Flush is asserted. Output should become NOP/0.
        s_IFID_i_Flush <= '1'; -- Active Flush
        wait for CLK_PERIOD;
        
        -- Release Flush
        s_IFID_i_Flush <= '0'; -- Normal Run
        s_IFID_i_PCPlus4 <= x"10000008"; -- Change input
        wait for CLK_PERIOD;

        s_IFID_i_Stall <= '0'; -- Active Stall
        s_IFID_i_PCPlus4 <= x"1000000C"; -- Change input
        wait for CLK_PERIOD;

        -- 4. TEST ID/EX STALL (Active Low '0')
        -- expect inputs to appear at outputs on next rising edge
        wait for CLK_PERIOD;

        -- 5. TEST EX/MEM PASS-THROUGH
        wait for CLK_PERIOD;

        wait for CLK_PERIOD;

        -- End Simulation
        wait;
    end process;

end architecture behavioral;