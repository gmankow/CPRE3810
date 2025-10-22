library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is 
    port(
        i_Immediate : in std_logic_vector(31 downto 0);
        i_CLK : in std_logic;
        i_RST             : in  std_logic;
        i_ALUout : in std_logic_vector(31 downto 0); -- ALU output for JALR target
        c_jump : in std_logic := '0';
        c_branch : in std_logic := '0';
        c_branch_cond_met : in std_logic := '0';
        c_jalr : in std_logic := '0';
        o_PC_out : out std_logic_vector(31 downto 0);
        o_PC_plus_4_out : out std_logic_vector(31 downto 0);
        o_PC_final : out std_logic_vector(31 downto 0)
    );
end entity fetch;

architecture structural of fetch is

    --32 bit "jump mux"
    component mux2t1_N is
        generic(N : integer := 32);
        port(
        i_S  : in  std_logic;
        i_D0 : in  std_logic_vector(N-1 downto 0);
        i_D1 : in  std_logic_vector(N-1 downto 0);
        o_O  : out std_logic_vector(N-1 downto 0)
        );
    end component mux2t1_N;

  --32 bit register "program counter"
    component register_N
        generic (
            N : integer := 32;
            INIT_VALUE : std_logic_vector(N-1 downto 0) := (others => '0')
        );
        port (
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(N-1 downto 0);
            o_Q : out std_logic_vector(N-1 downto 0)
        );
    end component;

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

    --32 bit adder "plus_4" and "plus_imm" will be instantiated directly from the
    -- compiled entity to avoid component binding issues (use direct entity instantiation).
    
    signal s_Plus_4_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Plus_Imm_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Jump_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_imm_shifted : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Jump_Select: std_logic;
    signal s_PC_Current : std_logic_vector(31 downto 0) := (others => '0');
    signal s_PC_Next : std_logic_vector(31 downto 0) := (others => '0');
    signal s_JALR_Select : std_logic := '0'; -- '1' to select JALR target
    signal s_JALR_Target : std_logic_vector(31 downto 0) := (others => '0'); -- ALU output for JALR target
    signal s_MuxOut1 : std_logic_vector(31 downto 0) := (others => '0');

begin

    s_Jump_Select <= (c_branch and c_branch_cond_met) or c_jump;
    o_PC_plus_4_out <= s_Plus_4_Out;
    o_PC_out <= s_PC_Current;
    o_PC_final <= s_PC_Next;

    s_JALR_Target <= i_ALUout;
    s_JALR_Select <= c_jalr;

    --s_imm_shifted <= i_Immediate(30 downto 0) & '0';

    --Create the PC, a 32 bit register
    --Outputs to signal line
    --Input is the output of jump Mux
    PC :  register_N
        generic map (INIT_VALUE => x"00400000")
        port map (
            i_CLK => i_CLK,
            i_WE => '1',
            i_RST => i_RST,
            i_D => s_PC_Next,
            o_Q => s_PC_Current
        );

    -- Creates an adder that adds 4 to the PC (direct entity instantiation)
    plus_4 : addSub_32bit
        port map (
              i_A => s_PC_Current,
              i_B      => x"00000004",
              i_Cin => '0',
              o_Sum => s_Plus_4_Out,
              o_Cout => open,
              o_LessThan => open,
              o_Zero => open,
              o_Overflow => open
        );

    --Creates an adder that adds the shifted Immediate value to the PC
    plus_imm : addSub_32bit
        port map (
            i_A => s_PC_Current,
            i_B => i_Immediate,
            i_Cin => '0',
            o_Sum => s_Plus_Imm_Out,
            o_Cout => open,
            o_LessThan => open,
            o_Zero => open,
            o_Overflow => open
        );

    --Creates a 32 bit 2t1 bus mux, that switches between the two adders
    jump_Mux :  mux2t1_N
        port map (
            i_S  => s_Jump_Select,
            i_D0 => s_Plus_4_Out,
            i_D1 => s_Plus_Imm_Out,
            o_O  => s_MuxOut1
        );

    
    jalr_Mux : mux2t1_N
        port map(
            i_S => s_JALR_Select,
            i_D0 => s_MuxOut1,
            i_D1 => s_JALR_Target,
            o_O => s_PC_Next
        );
end;
