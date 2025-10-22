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

  signal s_Immediate : std_logic_vector(31 downto 0); -- Immediate value from immediate generator
  signal s_Jump : std_logic; -- Jump control signal from control unit
  signal s_Branch : std_logic; -- Branch control signal from control unit
  signal s_BranchCondMet : std_logic; -- Branch condition met signal from ALU

  signal s_PC_plus_4 : std_logic_vector(31 downto 0); -- PC + 4 output from fetch

  signal s_ALUop : std_logic_vector(3 downto 0); -- ALU operation control signal from control unit
  signal s_ALUsrcA : std_logic; -- ALU source A select from control
  signal s_ALUsrcB : std_logic; -- ALU source B select from control
  signal s_PCorMemtoReg : std_logic_vector(1 downto 0); -- PC or Memory to Register select from control
  signal s_ImmSel : std_logic_vector(2 downto 0); -- Immediate selection from control

  signal s_RegData1 : std_logic_vector(31 downto 0); -- Data from source register 1
  signal s_RegData2 : std_logic_vector(31 downto 0); -- Data from source register 2

  signal s_PC_Out : std_logic_vector(31 downto 0) := (others => '0'); -- Current PC value from fetch
  signal s_ALUinA : std_logic_vector(31 downto 0); -- ALU input A

  signal s_ALUinB : std_logic_vector(31 downto 0); -- ALU input B

  signal s_Zero : std_logic; -- Zero flag from ALU
  signal s_LessThan : std_logic; -- Less than flag from ALU
  signal s_CarryOut : std_logic; -- Carry out from ALU

  signal s_DMemOut_Muxed : std_logic_vector(31 downto 0); -- Muxed Data Memory Output
  signal s_ALUsrcA1MuxOut : std_logic_vector(31 downto 0); -- ALU source A after mux1

  signal s_JALR_Select : std_logic; -- JALR select signal from control unit
  signal s_ALUsrcA0 : std_logic; -- ALU source A0 select (for LUI)

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
        i_Immediate : in std_logic_vector(31 downto 0);
        i_CLK : in std_logic;
        i_RST             : in  std_logic;
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

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  s_RegWrAddr <= s_Inst(11 downto 7); -- Destination register address is bits [11:7] of instruction
  --s_RegWrData <= oALUOut; -- For now, write data comes from ALU output (just testing addi currently)


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
  
  dMemOutMux_inst : dMem_Out_Mux
    port map (
        i_dMemOut => s_DMemOut,
        i_Func3 => s_Inst(14 downto 12),
        o_dMemOut_Muxed => s_DMemOut_Muxed
    );
            
  fetch_inst : Fetch
    port map (
        i_Immediate => s_Immediate,
        i_CLK => iCLK,
        i_RST => iRST,
        i_ALUout => oALUOut,
        c_jump => s_Jump,
        c_branch => s_Branch,
        c_branch_cond_met => s_BranchCondMet,
        c_jalr => s_JALR_Select,
        o_PC_out => s_NextInstAddr,
        o_PC_plus_4_out => s_PC_plus_4,
        o_PC_final => s_PC_Out
    );

  control_inst : controlSignals
    port map (
        i_Opcode => s_Inst(6 downto 0),
        i_Funct3 => s_Inst(14 downto 12),
        i_Funct7 => s_Inst(31 downto 25),
        o_ALUop => s_ALUop,
        o_Branch => s_Branch,
        o_ALUsrcA => s_ALUsrcA,
        o_ALUsrcB => s_ALUsrcB,
        o_PCorMemtoReg => s_PCorMemtoReg,
        o_MemWrite => s_DMemWr,
        o_RegWrite => s_RegWr,
        o_Jump => s_Jump,
        o_ImmSel => s_ImmSel,
        o_WFI => s_Halt,
        o_JALR_Select => s_JALR_Select,
        o_ALUsrcA0 => s_ALUsrcA0
    );

  regfile_inst : register_file
    port map (
        CLK => iCLK,
        RST => iRST,
        WriteEnable => s_RegWr,
        i_Source1 => s_Inst(19 downto 15),
        i_Source2 => s_Inst(24 downto 20),
        i_WriteReg => s_RegWrAddr,
        DIN => s_RegWrData,
        Source1Out => s_RegData1,
        Source2Out => s_RegData2
    );
  
  immGen_inst : immediateGenerate
    port map (
        i_ImmType => s_ImmSel,
        i_Instruction => s_Inst,
        o_Immediate => s_Immediate
    );
  
  scrA_mux : mux2t1_N
    generic map (N => 32)
    port map (
        i_S => s_ALUsrcA,
        i_D0 => s_RegData1,
        i_D1 => s_NextInstAddr,
        o_O => s_ALUsrcA1MuxOut
    );

  srcA2_mux : mux2t1_N
    generic map (N => 32)
    port map (
        i_S => s_ALUsrcA0,
        i_D0 => s_ALUsrcA1MuxOut,
        i_D1 => (31 downto 0 => '0'),
        o_O => s_ALUinA
    );
    
  scrB_mux : mux2t1_N
    generic map (N => 32)
    port map (
        i_S => s_ALUsrcB,
        i_D0 => s_RegData2,
        i_D1 => s_Immediate,
        o_O => s_ALUinB
    );
  
  ALU_inst : ALU
    port map (
        i_A => s_ALUinA,
        i_B => s_ALUinB,
        i_Control => s_ALUop,
        i_Func3 => s_Inst(14 downto 12),
        o_Result => oALUOut,
        o_Zero => s_Zero,
        o_LessThan => s_LessThan,
        o_CarryOut => s_CarryOut,
        o_BranchCondMet => s_BranchCondMet,
        o_Overflow => s_Ovfl
    );
    s_DMemAddr <= oALUOut; -- Data memory address comes from ALU output
    s_DMemData <= s_RegData2; -- Data memory data input comes from source register 2

  Mux_PC4_Mem_Reg : mux3t1_N
    generic map (N => 32)
    port map (
        i_S => s_PCorMemtoReg,
        i_D0 => oALUOut,
        i_D1 => s_DMemOut_Muxed,
        i_D2 => s_PC_plus_4,
        o_O => s_RegWrData
    ); 

    
  

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 
  

end structure;

