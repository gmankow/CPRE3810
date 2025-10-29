library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is 
	port(i_D0: in std_logic;
	    i_D1: in std_logic;
        i_S: in std_logic;
        o_O: out std_logic);
end mux2t1;

architecture structual of mux2t1 is
	signal not_s, and1_out, and2_out: std_logic;

	-- Not gate
	component invg is 
		port(
			i_A : in std_logic;
       		o_F : out std_logic);
	end component;

	-- And gate
	component andg2 is 
		port(
			i_A : in std_logic;
       		i_B : in std_logic;
       		o_F : out std_logic);
	end component;

	-- Or Gate
	component org2 is 
	port(
		i_A : in std_logic;
       	i_B : in std_logic;
       	o_F : out std_logic);
	end component;

begin

	not_gate : invg
	port map(
		i_A => i_S,
		o_F => not_s);

	and_gate1 : andg2
	port map(
		i_A => i_D0,
		i_B => not_s,
		o_F => and1_out);

	and_gate2 : andg2
	port map(
		i_A => i_D1,
		i_B => i_S,
		o_F => and2_out);

	or_gate : org2
	port map(
		i_A => and1_out,
		i_B => and2_out,
		o_F => o_O);

end;