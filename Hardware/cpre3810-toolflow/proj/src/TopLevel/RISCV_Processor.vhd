-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  signal s_Inst_ID : std_logic_vector(31 downto 0); -- Instruction from instruction memory
  signal s_Inst_EX : std_logic_vector(31 downto 0); -- Instruction from instruction memory
  signal s_Inst_MEM : std_logic_vector(31 downto 0); -- Instruction from instruction memory

  signal s_Immediate_ID : std_logic_vector(31 downto 0); -- Immediate value from immediate generator
  signal s_Immediate_EX : std_logic_vector(31 downto 0); -- Immediate value from immediate generator
  signal s_Immediate_MEM : std_logic_vector(31 downto 0); -- Immediate value from immediate generator

  signal s_Jump_ID : std_logic; -- Jump control signal from control unit
  signal s_Jump_EX : std_logic; -- Jump control signal from control unit
  signal s_Jump_MEM : std_logic; -- Jump control signal from control unit

  signal s_Branch_ID : std_logic; -- Branch control signal from control unit
  signal s_Branch_EX : std_logic; -- Branch control signal from control unit
  signal s_Branch_MEM : std_logic; -- Branch control signal from control unit

  signal s_BranchCondMet_ID : std_logic; -- Branch condition met signal from ALU
  signal s_BranchCondMet_EX : std_logic; -- Branch condition met signal from ALU
  signal s_BranchCondMet_MEM : std_logic; -- Branch condition met signal from ALU

  signal s_PC_plus_4_IF : std_logic_vector(31 downto 0); -- PC + 4 output from fetch
  signal s_PC_plus_4_ID : std_logic_vector(31 downto 0); -- PC + 4 output from fetch
  signal s_PC_plus_4_EX : std_logic_vector(31 downto 0); -- PC + 4 output from fetch
  signal s_PC_plus_4_MEM : std_logic_vector(31 downto 0); -- PC + 4 output from fetch
  signal s_PC_plus_4_WB : std_logic_vector(31 downto 0); -- PC + 4 output from fetch

  signal s_ALUop_ID : std_logic_vector(3 downto 0); -- ALU operation control signal from control unit
  signal s_ALUop_EX : std_logic_vector(3 downto 0); -- ALU operation control signal from control unit

  signal s_ALUsrcA_ID : std_logic; -- ALU source A select from control
  signal s_ALUsrcA_EX : std_logic; -- ALU source A select from control

  signal s_ALUsrcB_ID : std_logic; -- ALU source B select from control
  signal s_ALUsrcB_EX : std_logic; -- ALU source B select from control

  signal s_PCorMemtoReg_ID : std_logic_vector(1 downto 0); -- PC or Memory to Register select from control
  signal s_PCorMemtoReg_EX : std_logic_vector(1 downto 0); -- PC or Memory to Register select from control
  signal s_PCorMemtoReg_MEM : std_logic_vector(1 downto 0); -- PC or Memory to Register select from control
  signal s_PCorMemtoReg_WB : std_logic_vector(1 downto 0); -- PC or Memory to Register select from control

  signal s_ImmSel_ID : std_logic_vector(2 downto 0); -- Immediate selection from control
  
  signal s_Func3_ID : std_logic_vector(2 downto 0); -- Function 3 from instruction
  signal s_Func3_EX : std_logic_vector(2 downto 0); -- Function 3 from instruction
  signal s_Func3_MEM : std_logic_vector(2 downto 0); -- Function 3 from instruction

  signal s_RegData1_ID : std_logic_vector(31 downto 0); -- Data from source register 1
  signal s_RegData1_EX : std_logic_vector(31 downto 0); -- Data from source register 1

  signal s_RegData2_ID : std_logic_vector(31 downto 0); -- Data from source register 2
  signal s_RegData2_EX : std_logic_vector(31 downto 0); -- Data from source register 2
  signal s_RegData2_MEM : std_logic_vector(31 downto 0); -- Data from source register 2
  signal s_RegData2_WB : std_logic_vector(31 downto 0); -- Data from source register 2

  signal s_PC_Out : std_logic_vector(31 downto 0) := (others => '0'); -- Current PC value from fetch
  signal s_ALUinA : std_logic_vector(31 downto 0); -- ALU input A
  signal s_ALUinB : std_logic_vector(31 downto 0); -- ALU input B

  signal s_Zero_EX : std_logic; -- Zero flag from ALU
  signal s_Zero_MEM : std_logic; -- Zero flag from ALU

  signal s_LessThan_EX : std_logic; -- Less than flag from ALU
  signal s_LessThan_MEM : std_logic; -- Less than flag from ALU

  signal s_CarryOut_EX : std_logic; -- Carry out from ALU
  signal s_CarryOut_MEM : std_logic; -- Carry out from ALU

  signal s_DMemOut_Muxed : std_logic_vector(31 downto 0); -- Muxed Data Memory Output
  signal s_ALUsrcA1MuxOut : std_logic_vector(31 downto 0); -- ALU source A after mux1

  signal s_JALR_Select_ID : std_logic; -- JALR select signal from control unit
  signal s_JALR_Select_EX : std_logic; -- JALR select signal from control unit
  signal s_JALR_Select_MEM : std_logic; -- JALR select signal from control unit

  signal s_ALUsrcA0_ID : std_logic; -- ALU source A0 select (for LUI)
  signal s_ALUsrcA0_EX : std_logic; -- ALU source A0 select (for LUI)
  
  signal s_ALUOut_EX : std_logic_vector(31 downto 0); --ALU Output Signal
  signal s_ALUOut_MEM : std_logic_vector(31 downto 0); --ALU Output Signal
  signal s_ALUOut_WB : std_logic_vector(31 downto 0); --ALU Output Signal

  signal s_BranchImmed_ID : std_logic_vector(31 downto 0); -- Branch Immediate Value
  signal s_BranchImmed_EX : std_logic_vector(31 downto 0); -- Branch Immediate Value
  signal s_BranchImmed_MEM : std_logic_vector(31 downto 0); -- Branch Immediate Value

  signal s_CurPC_ID : std_logic_vector(31 downto 0); -- Current PC value in ID stage
  signal s_CurPC_EX : std_logic_vector(31 downto 0); -- Current PC value in EX stage
  signal s_CurPC_MEM : std_logic_vector(31 downto 0); -- Current PC value in MEM stage
  signal s_CurPC_WB : std_logic_vector(31 downto 0); -- Current PC value in WB stage

  signal s_Halt_ID : std_logic; -- Halt signal in ID stage
  signal s_Halt_EX : std_logic; -- Halt signal in EX stage
  signal s_Halt_MEM : std_logic; -- Halt signal in MEM stage
  signal s_Halt_WB : std_logic; -- Halt signal in WB stage

  signal s_DMemWr_ID : std_logic; -- Data Memory Write signal in ID stage
  signal s_DMemWr_EX : std_logic; -- Data Memory Write signal in EX stage
  signal s_DMemWr_MEM : std_logic; -- Data Memory Write signal in MEM stage

  signal s_dMemOut_WB : std_logic_vector(31 downto 0);   -- <<< NEW
  signal s_PCPlus4_WB : std_logic_vector(31 downto 0);   -- <<< NEW
  signal s_Func3_WB : std_logic_vector(2 downto 0);     -- <<< NEW
  --signal s_DMemOut_Muxed : std_logic_vector(31 downto 0); -- <<< NEW
  signal s_RegWr_ID : std_logic;
  signal s_RegWr_EX : std_logic;
  signal s_RegWr_MEM : std_logic;
  signal s_RegWr_WB : std_logic;

  signal s_RegWrAddr_ID : std_logic_vector(4 downto 0);
  signal s_RegWrAddr_EX : std_logic_vector(4 downto 0);
  signal s_RegWrAddr_MEM : std_logic_vector(4 downto 0);
  signal s_RegWrAddr_WB : std_logic_vector(4 downto 0);

  signal PC_Write : std_logic;
  signal IF_ID_Write : std_logic;
  signal IF_ID_Flush : std_logic;
  signal ID_EX_Flush : std_logic;
  signal EX_MEM_Flush : std_logic;

  signal forwardA : std_logic_vector(1 downto 0);
  signal forwardB : std_logic_vector(1 downto 0);

  signal forwardOutA : std_logic_vector(31 downto 0);
  signal forwardOutB : std_logic_vector(31 downto 0);
  signal rs1Addr_EX : std_logic_vector(4 downto 0);
  signal rs2Addr_EX : std_logic_vector(4 downto 0);
  
  component ALU is
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
  end component;

  component controlSignals is
    port (
       i_Opcode : in std_logic_vector(6 downto 0); -- 7 bit opcode
        i_Funct3 : in std_logic_vector(2 downto 0); -- 3 bit funct3
        i_Funct7 : in std_logic_vector(6 downto 0); -- 7 bit funct7
        o_ALUop : out std_logic_vector(3 downto 0); -- 4 bit ALU operation
        o_Branch : out std_logic; -- Branch signal
        o_ALUsrcA : out std_logic; -- ALU source A select
        o_ALUsrcB : out std_logic; -- ALU source B select
        o_PCorMemtoReg : out std_logic_vector(1 downto 0); -- PC or Memory to Register select
        o_MemWrite : out std_logic; -- Memory write enable
        o_RegWrite : out std_logic; -- Register file write enable
        o_Jump : out std_logic; -- Jump signal
        o_ImmSel : out std_logic_vector(2 downto 0); -- Immediate selection
        o_WFI : out std_logic; -- Wait for interrupt signal
        o_JALR_Select : out std_logic; -- JALR select signal
        o_ALUsrcA0 : out std_logic -- ALU source A0 select (for LUI)
    );
  end component;

  component Fetch is
    port (
        i_Stall : in std_Logic;
        i_BranchAddr : in std_logic_vector(31 downto 0);
        i_CLK : in std_logic;
        i_RST : in std_logic;
        i_ALUout : in std_logic_vector(31 downto 0); -- ALU output for JALR target
        c_jump : in std_logic;
        c_branch : in std_logic;
        c_branch_cond_met : in std_logic;
        c_jalr : in std_logic;
        o_PC_out : out std_logic_vector(31 downto 0);
        o_PC_plus_4_out : out std_logic_vector(31 downto 0);
        o_PC_final : out std_logic_vector(31 downto 0)
    );
  end component;

  component immediateGenerate is 
    port (
        i_ImmType : in std_logic_vector(2 downto 0); -- 3 bit immediate type
        i_Instruction : in std_logic_vector(31 downto 0); -- 32 bit instruction
        o_Immediate : out std_logic_vector(31 downto 0) -- 32 bit immediate
    );
  end component;

  component register_file is 
    port (
        CLK : in std_logic;
        RST : in std_logic;
        WriteEnable : in std_logic;
        i_Source1 : in std_logic_vector(4 downto 0);
        i_Source2 : in std_logic_vector(4 downto 0);
        i_WriteReg : in std_logic_vector(4 downto 0);
        DIN : in std_logic_vector(N-1 downto 0);
        Source1Out : out std_logic_vector(N-1 downto 0);
        Source2Out : out std_logic_vector(N-1 downto 0)
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

  component mux3t1_N is
      generic(N : integer := 32);
      port(
          i_S  : in  std_logic_vector(1 downto 0);
          i_D0 : in  std_logic_vector(N-1 downto 0);
          i_D1 : in  std_logic_vector(N-1 downto 0);
          i_D2 : in  std_logic_vector(N-1 downto 0);
          o_O  : out std_logic_vector(N-1 downto 0)
      );
  end component;

  component dMem_Out_Mux is
    port (
        i_dMemOut : in std_logic_vector(31 downto 0); -- Data Memory Output
        i_Func3 : in std_logic_vector(2 downto 0); -- funct3 field from instruction
        o_dMemOut_Muxed : out std_logic_vector(31 downto 0) -- Muxed Data Memory Output
    );
  end component;

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

  -- branch adder
  component addSub_32bit is
      port (
          i_A      : in  std_logic_vector(31 downto 0);
          i_B      : in  std_logic_vector(31 downto 0);
          i_Cin     : in  std_logic; -- 0 for add, 1 for subtract
          o_Sum : out std_logic_vector(31 downto 0);
          o_Cout  : out std_logic;
          o_LessThan : out std_logic; -- 1 if A < B, else 0
          o_Zero : out std_logic; -- 1 if result is 0, else 0
          o_Overflow : out std_logic -- Overflow flag (for addition/subtraction)
      );
  end component;

  component forwardingUnit is
    port (
        rs1_ex        : in std_logic_vector(4 downto 0);
        rs2_ex        : in std_logic_vector(4 downto 0);
        rd_mem        : in std_logic_vector(4 downto 0);
        reg_write_mem : in std_logic;
        rd_wb         : in std_logic_vector(4 downto 0);
        reg_write_wb  : in std_logic;
        forward_a     : out std_logic_vector(1 downto 0);
        forward_b     : out std_logic_vector(1 downto 0)
    );
  end component;

  component hazardDetectionUnit is
    port (
        rs1_id       : in std_logic_vector(4 downto 0);
        rs2_id       : in std_logic_vector(4 downto 0);
        rd_ex        : in std_logic_vector(4 downto 0);
        mem_read_ex  : in std_logic;
        branch_taken : in std_logic; -- Branch AND Branch_cond_met
        pc_write     : out std_logic;
        if_id_write  : out std_logic;
        if_id_flush  : out std_logic;
        id_ex_flush  : out std_logic;
        ex_mem_flush : out std_logic
    );
  end component;

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);
            
  fetch_inst : Fetch
    port map (
        i_Stall => PC_Write, -- TODO put in stall signal from HDU
        i_BranchAddr => s_BranchImmed_MEM,
        i_CLK => iCLK,
        i_RST => iRST,
        i_ALUout => s_ALUOut_MEM,
        c_jump => s_Jump_MEM,
        c_branch => s_Branch_MEM,
        c_branch_cond_met => s_BranchCondMet_MEM,
        c_jalr => s_JALR_Select_MEM,
        o_PC_out => s_NextInstAddr,
        o_PC_plus_4_out => s_PC_plus_4_IF,
        o_PC_final => s_PC_Out
    );

  IF_ID_inst : IF_ID_Reg
    port map (
      i_CLK => iCLK,
      i_RST => iRST OR IF_ID_Flush,
      i_Stall => IF_ID_Write,  -- Tie Stall and fetch to '0' (no hardware detection yet)
      i_Flush => IF_ID_Flush, -- TODO: update for hardware
      i_PCPlus4 => s_PC_plus_4_IF,
      i_Instruction => s_Inst,
      i_PC => s_NextInstAddr,
      o_PCPlus4 => s_PC_plus_4_ID,
      o_Instruction => s_Inst_ID,
      o_PC => s_CurPC_ID
    );

  control_unit : controlSignals
    port map (
      i_Opcode => s_Inst_ID(6 downto 0),
      i_Funct3 => s_Inst_ID(14 downto 12),
      i_Funct7 => s_Inst_ID(31 downto 25),
      o_ALUop => s_ALUop_ID,
      o_Branch => s_Branch_ID,
      o_ALUsrcA => s_ALUsrcA_ID,
      o_ALUsrcB => s_ALUsrcB_ID,
      o_PCorMemtoReg => s_PCorMemtoReg_ID,
      o_MemWrite => s_DMemWr_ID,
      o_RegWrite => s_RegWr_ID,
      o_Jump => s_Jump_ID,
      o_ImmSel => s_ImmSel_ID,
      o_WFI => s_Halt_ID,
      o_JALR_Select => s_JALR_Select_ID,
      o_ALUsrcA0 => s_ALUsrcA0_ID
  );

  HDU : hazardDetectionUnit
    port map (
      rs1_id => s_Inst_ID(19 downto 15),
      rs2_id => s_Inst_ID(24 downto 20),
      rd_ex => s_RegWrAddr_EX, -- from ID/EX Register
      mem_read_ex => s_PCorMemtoReg_EX(0), -- least sig bit is for load instructions
      branch_taken => s_Branch_EX AND s_BranchCondMet_EX, -- Branch AND Branch_cond_met
      pc_write => PC_Write,
      if_id_write => IF_ID_Write,
      if_id_flush => IF_ID_Flush,
      id_ex_flush => ID_EX_Flush,
      ex_mem_flush => EX_MEM_Flush
    );

  regFile_inst : register_file
    port map (
      CLK => iCLK,
      RST => iRST,
      WriteEnable => s_RegWr,
      i_Source1 => s_Inst_ID(19 downto 15),
      i_Source2 => s_Inst_ID(24 downto 20),
      i_WriteReg => s_RegWrAddr,
      DIN => s_RegWrData, -- from WB stage
      Source1Out => s_RegData1_ID,
      Source2Out => s_RegData2_ID
  );

  immediate_gen_inst : immediateGenerate
    port map (
      i_ImmType => s_ImmSel_ID,
      i_Instruction => s_Inst_ID,
      o_Immediate => s_Immediate_ID
  );

  branch_adder_inst : addSub_32bit
    port map (
      i_A => s_CurPC_ID,
      i_B => s_Immediate_ID,
      i_Cin => '0',
      o_Sum => s_BranchImmed_ID,
      o_Cout => open,
      o_LessThan => open,
      o_Zero => open,
      o_Overflow => open
  );

  ID_EX_inst : ID_EX_Reg
    port map (
      i_CLK => iCLK,
      i_RST => iRST OR ID_EX_Flush,
      i_Stall => '1',  -- Tie Stall to '0'
      i_Flush => ID_EX_Flush,  -- Tie Flush to '0'
      
      -- Control Signals
      i_Halt => s_Halt_ID,
      i_ALUsrcA => s_ALUsrcA_ID,
      i_ALUsrcA0 => s_ALUsrcA0_ID,
      i_ALUsrcB => s_ALUsrcB_ID,
      i_ALUop => s_ALUop_ID,
      i_MemWrite => s_DMemWr_ID,
      i_RegWrite => s_RegWr_ID,
      i_Jump => s_Jump_ID,
      i_Jalr => s_JALR_Select_ID,
      i_Branch => s_Branch_ID,
      i_PCorMemtoReg => s_PCorMemtoReg_ID,
      
      -- Data Signals
      i_Fuct3 => s_Inst_ID(14 downto 12),
      i_PC => s_CurPC_ID,
      i_PCPlus4 => s_PC_plus_4_ID,
      i_PCPlusImm => s_BranchImmed_ID,
      i_Immediate => s_Immediate_ID,
      i_Out1 => s_RegData1_ID,
      i_Out2 => s_RegData2_ID,
      i_RegWrAddr => s_Inst_ID(11 downto 7),
      i_Rs1Addr => s_Inst_ID(19 downto 15),
      i_Rs2Addr => s_Inst_ID(24 downto 20),



      -- Corresponding Outputs
      o_Halt => s_Halt_EX,
      o_ALUsrcA => s_ALUsrcA_EX,
      o_ALUsrcA0 => s_ALUsrcA0_EX,
      o_ALUsrcB => s_ALUsrcB_EX,
      o_ALUop => s_ALUop_EX,
      o_MemWrite => s_DMemWr_EX,
      o_RegWrite => s_RegWr_EX,    
      o_Jump => s_Jump_EX,
      o_Jalr => s_JALR_Select_EX,
      o_Branch => s_Branch_EX,
      o_PCorMemtoReg => s_PCorMemtoReg_EX, 
      o_Fuct3 => s_Func3_EX,
      o_PC => s_CurPC_EX,
      o_PCPlus4 => s_PC_plus_4_EX,
      o_PCPlusImm => s_BranchImmed_EX,
      o_Immediate => s_Immediate_EX,
      o_Out1 => s_RegData1_EX,
      o_Out2 => s_RegData2_EX,
      o_RegWrAddr => s_RegWrAddr_EX,
      o_Rs1Addr => rs1Addr_EX,
      o_Rs2Addr => rs2Addr_EX
  );

  ForwardUnit : forwardingUnit
    port map (
      rs1_ex => rs1Addr_EX,
      rs2_ex => rs2Addr_EX,
      rd_mem => s_RegWrAddr_MEM,
      reg_write_mem => s_RegWr_MEM,
      rd_wb => s_RegWrAddr,
      reg_write_wb => s_RegWr,
      forward_a => forwardA,
      forward_b => forwardB
    );

  forwardA_mux : mux3t1_N
    generic map (N => 32)
    port map (
      i_S => forwardA,
      i_D0 => s_RegData1_EX,
      i_D1 => s_ALUOut_MEM,
      i_D2 => s_RegWrData,
      o_O => forwardOutA
  );

  ALUsrcA_mux : mux2t1_N
    generic map (N => 32)
    port map (
      i_S => s_ALUsrcA_EX,
      i_D0 => forwardOutA,
      i_D1 => s_CurPC_EX,
      o_O => s_ALUsrcA1MuxOut
  );

  ALUscrA0_mux : mux2t1_N
    generic map (N => 32)
    port map (
      i_S => s_ALUsrcA0_EX,
      i_D0 => s_ALUsrcA1MuxOut,
      i_D1 => (others => '0'),
      o_O => s_ALUinA
  );

  forwardB_mux : mux3t1_N
    generic map (N => 32)
    port map (
      i_S => forwardB,
      i_D0 => s_RegData2_EX,
      i_D1 => s_ALUOut_MEM,
      i_D2 => s_RegWrData,
      o_O => forwardOutB
  );

  ALUsrcB_mux : mux2t1_N
    generic map (N => 32)
    port map (
      i_S => s_ALUsrcB_EX,
      i_D0 => forwardOutB,
      i_D1 => s_Immediate_EX,
      o_O => s_ALUinB
  );


  ALU_inst : ALU
    port map (
      i_A => s_ALUinA, -- TODO change
      i_B => s_ALUinB, -- TODO change
      i_Control => s_ALUop_EX,
      i_Func3 => s_Func3_EX,
      o_Result => s_ALUOut_EX,
      o_Zero => s_Zero_EX,
      o_LessThan => s_LessThan_EX,
      o_CarryOut => s_CarryOut_EX,
      o_BranchCondMet => s_BranchCondMet_EX,
      o_Overflow => s_Ovfl
  );

  EX_MEM_inst : EX_MEM_Reg
    port map (
      i_CLK => iCLK,
      i_RST => iRST OR EX_MEM_Flush,
      i_Halt => s_Halt_EX,
      i_MemWrite => s_DMemWr_EX,
      i_RegWrite => s_RegWr_EX,
      i_Fuct3 => s_Func3_EX,
      i_PCorMemtoReg => s_PCorMemtoReg_EX,
      i_Jump => s_Jump_EX,
      i_Jalr => s_JALR_Select_EX,
      i_Branch => s_Branch_EX,
      i_Branch_cond_met => s_BranchCondMet_EX,
      i_PCPlus4 => s_PC_plus_4_EX,
      i_ALUout => s_ALUOut_EX,
      i_Out2 => forwardOutB,
      i_PCPlusImm => s_BranchImmed_EX,
      i_RegWrAddr => s_RegWrAddr_EX,
      o_Halt => s_Halt_MEM,
      o_MemWrite => s_DMemWr, -- special signal to data memory
      o_RegWrite => s_RegWr_MEM,
      o_Fuct3 => s_Func3_MEM,
      o_PCorMemtoReg => s_PCorMemtoReg_MEM,
      o_Jump => s_Jump_MEM,
      o_Jalr => s_JALR_Select_MEM,
      o_Branch => s_Branch_MEM,
      o_Branch_cond_met => s_BranchCondMet_MEM,
      o_PCPlus4 => s_PC_plus_4_MEM,
      o_ALUout => s_ALUOut_MEM,
      o_Out2 => s_RegData2_MEM,
      o_PCPlusImm => s_BranchImmed_MEM,
      o_RegWrAddr => s_RegWrAddr_MEM
  );
  s_DMemAddr <= s_ALUOut_MEM; -- Data Memory address comes from ALU output
  s_DMemData <= s_RegData2_MEM; -- Data Memory write data comes from source register 2

  MEM_WB_inst : MEM_WB_Reg
    port map (
      i_CLK => iCLK,
      i_RST => iRST,
      i_Halt => s_Halt_MEM,
      i_RegWrite => s_RegWr_MEM,
      i_PCorMemtoReg => s_PCorMemtoReg_MEM,
      i_Fuct3 => s_Func3_MEM,
      i_RegWrAddr => s_RegWrAddr_MEM,
      i_ALUout => s_ALUOut_MEM,
      i_dMemOut => s_DMemOut,
      i_PCPlus4 => s_PC_plus_4_MEM,
      o_Halt => s_Halt_WB,
      o_RegWrite => s_RegWr,
      o_PCorMemtoReg => s_PCorMemtoReg_WB,
      o_ALUout => s_ALUOut_WB,
      o_dMemOut => s_dMemOut_WB,
      o_PCPlus4 => s_PC_plus_4_WB,
      o_Fuct3 => s_Func3_WB,
      o_RegWrAddr => s_RegWrAddr_WB
  );

  DMem_Out_Mux_inst : dMem_Out_Mux
    port map (
      i_dMemOut => s_dMemOut_WB,
      i_Func3 => s_Func3_WB,
      o_dMemOut_Muxed => s_DMemOut_Muxed
  );

  WB_Mux_inst : mux3t1_N
    generic map (N => 32)
    port map (
      i_S => s_PCorMemtoReg_WB,
      i_D0 => s_ALUOut_WB,
      i_D1 => s_DMemOut_Muxed,
      i_D2 => s_PC_plus_4_WB,
      o_O => s_RegWrData
  );
  


  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  s_Halt <= s_Halt_WB;

  s_RegWrAddr <= s_RegWrAddr_WB; -- Destination register address is bits [11:7] of instruction
  --s_RegWrData <= oALUOut; -- For now, write data comes from ALU output (just testing addi currently)
  oALUOut <= s_ALUOut_EX;
  
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 
  

end structure;

