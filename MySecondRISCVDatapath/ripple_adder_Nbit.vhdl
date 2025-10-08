library IEEE;
use IEEE.std_logic_1164.all;

-- N-bit ripple carry adder
entity ripple_adder_Nbit is
    generic (N : integer := 32);  -- 32 bit ripple carry adder
    port(i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         i_CIN        : in std_logic;
         o_SUM        : out std_logic_vector(N-1 downto 0);
         o_CARRY      : out std_logic);
end ripple_adder_Nbit;

architecture structural of ripple_adder_Nbit is 
    signal C : std_logic_vector(N downto 0); -- carry signals for in between full adders (N to 0 since initial carry in is C(0) and final carry out is C(N))

    component full_adder is
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             i_CIN        : in std_logic;
             o_SUM        : out std_logic;
             o_CARRY      : out std_logic);
    end component;

begin

    C(0) <= i_CIN;  -- initial carry in

    gen_full_adders: for i in 0 to N-1 generate
        full_adder_inst: full_adder
            port map(i_A => i_A(i),
                     i_B => i_B(i),
                     i_CIN => C(i),
                     o_SUM => o_SUM(i),
                     o_CARRY => C(i+1));
    end generate;

    o_CARRY <= C(N);  -- final carry out

end structural;