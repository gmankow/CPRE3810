library ieee;
use ieee.std_logic_1164.all;

entity addSub_32bit is
    port (
        i_A      : in  std_logic_vector(31 downto 0);
        i_B      : in  std_logic_vector(31 downto 0);
        i_Cin     : in  std_logic; -- 0 for add, 1 for subtract
        o_Sum : out std_logic_vector(31 downto 0);
        o_Cout  : out std_logic;
        o_LessThan : out std_logic -- 1 if A < B, else 0
        o_Zero : out std_logic -- 1 if result is 0, else 0
    );
end entity addSub_32bit;

architecture behavioral of addSub_32bit is

    component cla_4bit
        port (
            i_A    : in  std_logic_vector(3 downto 0);
            i_B    : in  std_logic_vector(3 downto 0);
            i_Cin  : in  std_logic;
            o_Sum  : out std_logic_vector(3 downto 0);
            o_Cout : out std_logic
        );
    end component;

    signal C : std_logic_vector(8 downto 0); -- carry signals between the 8 blocks

    begin
        C(0) <= i_Cin; -- initial carry-in

        gen_blocks: for i in 0 to 7 generate
            cla_inst: cla_4bit
                port map(
                    i_A => i_A((i*4)+3 downto i*4), -- 4 bits of A
                    i_B => i_B((i*4)+3 downto i*4), -- 4 bits of B
                    i_Cin => C(i), -- carry-in from previous block
                    o_Sum => o_Sum((i*4)+3 downto i*4), -- 4 bits of sum output
                    o_Cout => C(i+1) -- carry-out to next block
                );
        end generate;

        o_Cout <= C(8); -- final carry-out
        o_LessThan <= '1' when signed(i_A) < signed(i_B) else '0'; -- if the result is negative, A < B
        o_Zero <= '1' when o_Sum = (others => '0') else '0'; -- if the result is 0
        
end architecture behavioral;