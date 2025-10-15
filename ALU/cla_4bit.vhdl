library ieee;
use ieee.std_logic_1164.all;

entity cla_4bit is
    port (
        i_A : in  std_logic_vector(3 downto 0);
        i_B : in  std_logic_vector(3 downto 0);
        i_Cin : in  std_logic;
        o_Sum : out std_logic_vector(3 downto 0);
        o_Cout : out std_logic
    );
end entity cla_4bit;

architecture behavioral of cla_4bit is
    -- Propagate and Generate
    signal P : std_logic_vector(3 downto 0);
    signal G : std_logic_vector(3 downto 0);
    
    -- Full adder stuff
    signal C : std_logic_vector(4 downto 0);

begin
    -- P and G for each bit
    P <= i_A xor i_B;
    G <= i_A and i_B;

    --- initial carry-in
    C(0) <= i_Cin;

    -- lookahead logic (thank Stoychev's 2024 digital logic slides)
    C(1) <= G(0) or (P(0) and C(0));
    C(2) <= G(1) or (P(1) and G(0)) or (P(1) and P(0) and C(0));
    C(3) <= G(2) or (P(2) and G(1)) or (P(2) and P(1) and G(0)) or (P(2) and P(1) and P(0) and C(0));
    C(4) <= G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or (P(3) and P(2) and P(1) and G(0)) or (P(3) and P(2) and P(1) and P(0) and C(0));

    -- final sum
    o_Sum <= P xor C(3 downto 0);

    -- final carry-out
    o_Cout <= C(4);

end architecture behavioral;