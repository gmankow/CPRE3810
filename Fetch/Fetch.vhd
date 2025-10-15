library ieee;
use ieee.std_logic_1164.all;

entity fetch is 
    port(
        i_Immediate : in std_logic_vector(31 downto 0);
        i_CLK : in std_logic
        c_jump : in std_logic;
        c_branch : in std_logic;
        c_branch_cond_met : in std_logic
        o_PC_out : out std_logic_vector(31 downto 0);
        o_PC+4_out : out std_logic_vector(31 downto 0)
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
        generic (N : integer := 32);
        port (
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(N-1 downto 0);
            o_Q : out std_logic_vector(N-1 downto 0)
        );
    end component;

  --32 bit adder "plus_4" and "plus_imm"
    component addSub_32bit is
        generic (N : integer := 32);
        port (
            i_A      : in  std_logic_vector(31 downto 0);
            i_B      : in  std_logic_vector(31 downto 0);
            i_Cin     : in  std_logic; -- 0 for add, 1 for subtract
            o_Sum : out std_logic_vector(31 downto 0);
            o_Cout  : out std_logic;
            o_LessThan : out std_logic -- 1 if A < B, else 0
            o_Zero : out std_logic -- 1 if result is 0, else 0
        );
    end component;

    signal s_PC_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Plus_4_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Plus_Imm_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Jump_Out : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Imm_Shift : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Jump_Select: std_logic;

begin

    s_Jump_Select <= (c_branch and c_branch_cond_met) or c_jump

    gen_shift_in: for i in 0 to 30 generate
        s_Imm_Shift(i+1) <= i_Immediate(i);
    end generate gen_shift_in;

    --Create the PC, a 32 bit register
    --Outputs to signal line
    --Input is the output of jump Mux
    PC : component register_N
        port map (
            i_CLK => i_CLK,
            i_WE => '1',
            i_RST => '0',
            i_D => s_Jump_Out,
            o_O => s_PC_Out
        );

    --Creates an adder that adds 4 to the PC
    plus_4 : component add_sub_Nbit
        port map (
            i_A => s_PC_Out,
            i_B => "0100",
            i_Cin => '0',
            o_Sum => s_Plus_4_Out
        );

    --Creates an adder that adds the shifted Immediate value to the PC
    plus_imm : component add_sub_Nbit
        port map (
            i_A => s_PC_Out,
            i_B => s_Imm_Shift,
            i_Cin => '0',
            o_Sum => s_Plus_Imm_Out
        );

    --Creates a 32 bit 2t1 bus mux, that switches between the two adders
    jump_Mux : component mux2t1_N
        port map (
            i_S  => s_Jump_Select
            i_D0 => s_Plus_4_Out
            i_D1 => s_Plus_Imm_Out
            o_O  => s_Jump_Out
        );
end;
