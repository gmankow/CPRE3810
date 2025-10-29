library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub_Nbit is
    generic (N : integer := 32);
    port(i_A : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         i_imm : in std_logic_vector(N-1 downto 0); -- immediate value input
         i_nAdd_Sub : in std_logic;  -- 0 for add, 1 for subtract
         i_ALUSrc : in std_logic; -- 0 for choosing B, 1 for using immediate value
         o_SUM : out std_logic_vector(N-1 downto 0);
         o_CARRY : out std_logic); -- carry out
end add_sub_Nbit;

architecture structural of add_sub_Nbit is 
    signal B_invert : std_logic_vector(N-1 downto 0); -- B inverted if subtracting
    signal imm_invert : std_logic_vector(N-1 downto 0); -- immediate inverted if subtracting
    signal B_final : std_logic_vector(N-1 downto 0); -- B after add/sub mux (either original B or inverted B)
    signal imm_final : std_logic_vector(N-1 downto 0); -- immediate after add/sub mux (either original or inverted)
    signal ALU_mux_out : std_logic_vector(N-1 downto 0); -- Output of ALUSrc mux: B_final or imm_final

    component ripple_adder_Nbit is
        generic (N : integer := 32);
        port(i_A : in std_logic_vector(N-1 downto 0);
             i_B : in std_logic_vector(N-1 downto 0);
             i_CIN : in std_logic;
             o_SUM : out std_logic_vector(N-1 downto 0);
             o_CARRY : out std_logic);
    end component;

    component mux2t1_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
      port(i_S : in std_logic;
           i_D0 : in std_logic_vector(N-1 downto 0);
           i_D1 : in std_logic_vector(N-1 downto 0);
           o_O : out std_logic_vector(N-1 downto 0));
    end component;

    component ones_comp is
        generic (N : integer := 32);
        port(i_A : in  std_logic_vector(N-1 downto 0);
             o_F : out std_logic_vector(N-1 downto 0));
    end component;

begin

    -- Invert B and immediate for subtraction
    ones_comp_B: ones_comp
    generic map(N => N)
        port map(i_A => i_B,
                 o_F => B_invert);

    ones_comp_imm: ones_comp
    generic map(N => N)
        port map(i_A => i_imm,
                 o_F => imm_invert);

    -- Mux to select B or B_invert (add/sub)
    mux2t1_N_B: mux2t1_N
    generic map(N => N)
        port map(i_S => i_nAdd_Sub,
                 i_D0 => i_B,
                 i_D1 => B_invert,
                 o_O => B_final);

    -- Mux to select imm or imm_invert (add/sub)
    mux2t1_N_imm: mux2t1_N
    generic map(N => N)
        port map(i_S => i_nAdd_Sub,
                 i_D0 => i_imm,
                 i_D1 => imm_invert,
                 o_O => imm_final);

    -- Mux to select between B path and immediate path (ALUSrc)
    mux2t1_N_ALUSrc: mux2t1_N
    generic map(N => N)
        port map(i_S => i_ALUSrc,
                 i_D0 => B_final,
                 i_D1 => imm_final,
                 o_O => ALU_mux_out);

    ripple_adder_inst: ripple_adder_Nbit
    generic map(N => N)
        port map(i_A => i_A,
                 i_B => ALU_mux_out,
                 i_CIN => i_nAdd_Sub,
                 o_SUM => o_SUM,
                 o_CARRY => o_CARRY); -- final carry out

end structural;