library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity addSub_32bit is
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
end entity addSub_32bit;

architecture behavioral of addSub_32bit is
    signal s_Result : std_logic_vector(31 downto 0);
    signal s_B : std_logic_vector(31 downto 0);  -- B or its complement based on operation

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
    -- For subtraction, invert B
    s_B <= i_B when i_Cin = '0' else
           not i_B;

    C(0) <= i_Cin; -- initial carry-in (serves as +1 for 2's complement in subtraction)

    gen_blocks: for i in 0 to 7 generate
        cla_inst: cla_4bit
            port map(
                i_A => i_A((i*4)+3 downto i*4),
                i_B => s_B((i*4)+3 downto i*4),
                i_Cin => C(i),
                o_Sum => s_Result((i*4)+3 downto i*4),
                o_Cout => C(i+1)
            );
    end generate;

    o_Sum <= s_Result;
    o_Cout <= C(8);

    -- Zero flag: set when all bits of result are 0
    o_Zero <= '1' when s_Result = x"00000000" else '0';

    o_Overflow <= (i_A(31) xnor s_B(31)) and (i_A(31) xor s_Result(31));

    -- Less than flag (SLT):
    -- For RISC-V, SLT is set if (signed(A) < signed(B)), which is true if the result is negative after subtraction
    o_LessThan <= s_Result(31);

end architecture behavioral;