library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder is
    -- 1-bit full adder
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         i_CIN        : in std_logic;
         o_SUM        : out std_logic;
         o_CARRY      : out std_logic);
    
end full_adder;

architecture structural of full_adder is 
    signal xor1, and1, and2 : std_logic;

    -- and gate
    component andg2
        port(i_A      : in std_logic;
             i_B      : in std_logic;
             o_F      : out std_logic);
    end component;

    -- or gate
    component org2
        port(i_A      : in std_logic;
            i_B      : in std_logic;
            o_F      : out std_logic);
    end component;

    -- xor gate
    component xorg2
        port(i_A          : in std_logic;
            i_B          : in std_logic;
             o_F          : out std_logic);
    end component;

begin 

    xorg1_inst : xorg2
        port map(i_A => i_A,
                 i_B => i_B,
                 o_F => xor1);
    
    andg1_inst : andg2
        port map(i_A => i_A,
                 i_B => i_B,
                 o_F => and1);

    xorg2_inst : xorg2
        port map(i_A => xor1,
                 i_B => i_CIN,
                 o_F => o_SUM);

    andg2_inst : andg2
        port map(i_A => xor1,
                 i_B => i_CIN,
                 o_F => and2);
    
    org_inst : org2
        port map(i_A => and1,
                 i_B => and2,
                 o_F => o_CARRY);

end structural;