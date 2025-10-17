library ieee;
use ieee.std_logic_1164.all;

entity immediateGenerate is
    port (
        i_ImmType : in std_logic_vector(2 downto 0); -- 3 bit immediate type
        i_Instruction : in std_logic_vector(31 downto 0); -- 32 bit instruction
        o_Immediate : out std_logic_vector(31 downto 0) -- 32 bit immediate
    );
end entity immediateGenerate;

architecture behavioral of immediateGenerate is

    signal imm_I : std_logic_vector(31 downto 0);
    signal imm_S : std_logic_vector(31 downto 0);
    signal imm_SB : std_logic_vector(31 downto 0);
    signal imm_U : std_logic_vector(31 downto 0);
    signal imm_UJ : std_logic_vector(31 downto 0);

begin

    -- I-type: 12-bit immediate (bits 31-20), sign-extended to 32 bits
    imm_I <= (31 downto 12 => i_Instruction(31)) & i_Instruction(31 downto 20);

    -- S-type: 12-bit immediate (bits 31-25, 11-7), sign-extended to 32 bits  
    imm_S <= (31 downto 12 => i_Instruction(31)) & i_Instruction(31 downto 25) & i_Instruction(11 downto 7);

    -- SB-type: 12-bit immediate (bit 31, 7, 30-25, 11-8, 0), sign-extended to 32 bits
    imm_SB <= (31 downto 12 => i_Instruction(31)) & i_Instruction(7) & i_Instruction(30 downto 25) & i_Instruction(11 downto 8) & '0';

    -- U-type: 20-bit immediate (bits 31-12) in upper 20 bits, lower 12 bits zero
    imm_U <= i_Instruction(31 downto 12) & (11 downto 0 => '0');

    -- UJ-type: 20-bit immediate (bit 31, 19-12, 20, 30-21, 0), sign-extended to 32 bits
    imm_UJ <= (31 downto 20 => i_Instruction(31)) & i_Instruction(19 downto 12) & i_Instruction(20) & i_Instruction(30 downto 21) & '0';

    -- chose which imm based off i_ImmType
    with i_ImmType select
        o_Immediate <= imm_I when "000", -- I-type
                       imm_S when "001", -- S-type
                       imm_SB when "010", -- SB-type
                       imm_U when "011", -- U-type
                       imm_UJ when "100", -- UJ-type
                       (others => '0') when others; -- default to 0

end architecture behavioral;