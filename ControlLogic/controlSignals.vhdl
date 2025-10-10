library ieee;
use ieee.std_logic_1164.all;

entity controlSignals is
    port (
        i_Opcode : in std_logic_vector(6 downto 0); -- 7 bit opcode
        i_Funct3 : in std_logic_vector(2 downto 0); -- 3 bit funct3
        i_Funct7 : in std_logic_vector(6 downto 0); -- 7 bit funct7
        o_ALUop : out std_logic_vector(3 downto 0); -- 4 bit ALU operation
        o_Branch : out std_logic; -- Branch signal
        o_ALUsrcA : out std_logic; -- ALU source A select
        o_ALUsrcB : out std_logic; -- ALU source B select
        o_PCorMemtoReg : out std_logic_vector(1 downto 0); -- PC or Memory to Register select
        o_MemWrite : out std_logic; -- Memory write enable
        o_RegWrite : out std_logic; -- Register file write enable
        o_Jump : out std_logic; -- Jump signal
        o_ImmSel : out std_logic_vector(2 downto 0) -- Immediate selection
    );
end entity controlSignals;

architecture behavioral of controlSignals is

    -- Constants so i'm not writing the same binary over and over again

    constant alu_AND : std_logic_vector(3 downto 0) := "0000"; -- AND : 0000
    constant alu_OR  : std_logic_vector(3 downto 0) := "0001"; -- OR  : 0001
    constant alu_ADD : std_logic_vector(3 downto 0) := "0010"; -- ADD : 0010
    constant alu_XOR : std_logic_vector(3 downto 0) := "0011"; -- XOR : 0011
    constant alu_SLL : std_logic_vector(3 downto 0) := "0100"; -- SLL : 0100
    constant alu_SRL : std_logic_vector(3 downto 0) := "0101"; -- SRL : 0101
    constant alu_SUB : std_logic_vector(3 downto 0) := "0110"; -- SUB : 0110
    constant alu_SLT : std_logic_vector(3 downto 0) := "0111"; -- SLT : 0111
    constant alu_SLTU: std_logic_vector(3 downto 0) := "1000"; -- SLTU: 1000
    constant alu_SRA : std_logic_vector(3 downto 0) := "1101"; -- SRA : 1101

    constant imm_I_TYPE : std_logic_vector(2 downto 0) := "000"; -- I type : 000
    constant imm_S_TYPE : std_logic_vector(2 downto 0) := "001"; -- S type : 001
    constant imm_SB_TYPE : std_logic_vector(2 downto 0) := "010"; -- SB type : 010
    constant imm_U_TYPE : std_logic_vector(2 downto 0) := "011"; -- U type : 011
    constant imm_UJ_TYPE: std_logic_vector(2 downto 0) := "100"; -- UJ type: 100

    begin

        -- TODO INCLUDE WFI AND CHECK ON DON'T CARE BITS
        
        o_ALUsrcA <= '1' when (i_Opcode = "0010111") -- auipc
            else '0';

        o_ALUsrcB <= '1' when (i_Opcode = "0010011" and i_Funct3 = "000") or -- addi
            (i_Opcode = "0010011" and i_Funct3 = "111") or -- andi
            (i_Opcode = "0110111") or -- lui
            (i_Opcode = "0000011" and i_Funct3 = "010") or -- lw
            (i_Opcode = "0010011" and i_Funct3 = "100") or -- xori
            (i_Opcode = "0010011" and i_Funct3 = "110") or -- ori
            (i_Opcode = "0010011" and i_Funct3 = "010") or -- slti
            (i_Opcode = "0010011" and i_Funct3 = "011") or -- sltiu
            (i_Opcode = "1101111") or -- jal
            (i_Opcode = "1100111" and i_Funct3 = "000") or -- jalr
            (i_Opcode = "0000011" and i_Funct3 = "000") or -- lb
            (i_Opcode = "0000011" and i_Funct3 = "001") or -- lh
            (i_Opcode = "0000011" and i_Funct3 = "100") or -- lbu
            (i_Opcode = "0000011" and i_Funct3 = "101") or -- lhu
            (i_Opcode = "0010011" and i_Funct3 = "001" and i_Funct7 = "0000000") or -- slli
            (i_Opcode = "0010011" and i_Funct3 = "101" and i_Funct7 = "0000000") or -- srli
            (i_Opcode = "0010011" and i_Funct3 = "101" and i_Funct7 = "0100000") or -- srai
            (i_Opcode = "0010111") -- auipc
            else '0';
        
        o_ALUop <= alu_ADD when (i_Opcode = "0010011" and i_Funct3 = "000") else -- addi
            alu_ADD when (i_Opcode = "0110011" and i_Funct3 = "000" and i_Funct7 = "0000000") else -- add
            alu_ADD when (i_Opcode = "0100011" and i_Funct3 = "000") else -- sw
            alu_ADD when (i_Opcode = "1100111" and i_Funct3 = "000") else -- jalr
            alu_ADD when (i_Opcode = "0000011" and i_Funct3 = "000") else -- lb
            alu_ADD when (i_Opcode = "0000011" and i_Funct3 = "001") else -- lh
            alu_ADD when (i_Opcode = "0000011" and i_Funct3 = "100") else -- lbu
            alu_ADD when (i_Opcode = "0000011" and i_Funct3 = "101") else -- lhu
            alu_ADD when (i_Opcode = "0010111") else -- auipc

            alu_AND when (i_Opcode = "0110011" and i_Funct3 = "111" and i_Funct7 = "0000000") else -- and
            alu_AND when (i_Opcode = "0010011" and i_Funct3 = "111") else -- andi

            alu_OR when (i_Opcode = "0110011" and i_Funct3 = "110" and i_Funct7 = "0000000") else -- or
            alu_OR when (i_Opcode = "0010011" and i_Funct3 = "110") else -- ori

            alu_XOR when (i_Opcode = "0110011" and i_Funct3 = "100" and i_Funct7 = "0000000") else -- xor
            alu_XOR when (i_Opcode = "0010011" and i_Funct3 = "100") else -- xori

            alu_SLL when (i_Opcode = "0110011" and i_Funct3 = "001" and i_Funct7 = "0000000") else -- sll
            alu_SLL when (i_Opcode = "0010011" and i_Funct3 = "001" and i_Funct7 = "0000000") else -- slli

            alu_SRL when (i_Opcode = "0110011" and i_Funct3 = "101" and i_Funct7 = "0000000") else -- srl
            alu_SRL when (i_Opcode = "0010011" and i_Funct3 = "101" and i_Funct7 = "0000000") else -- srli

            alu_SUB when (i_Opcode = "0110011" and i_Funct3 = "000" and i_Funct7 = "0100000") else -- sub
            alu_SUB when (i_Opcode = "1100011" and i_Funct3 = "000") else -- beq
            alu_SUB when (i_Opcode = "1100011" and i_Funct3 = "001") else -- bne

            alu_SLT when (i_Opcode = "0110011" and i_Funct3 = "010" and i_Funct7 = "0000000") else -- slt
            alu_SLT when (i_Opcode = "0010011" and i_Funct3 = "010") else -- slti
            alu_SLT when (i_Opcode = "1100011" and i_Funct3 = "100") else -- blt
            alu_SLT when (i_Opcode = "1100011" and i_Funct3 = "101") else -- bge

            alu_SLTU when (i_Opcode = "0010011" and i_Funct3 = "011" and i_Funct7 = "0000000") else -- sltu
            alu_SLTU when (i_Opcode = "1100011" and i_Funct3 = "110") else -- bltu
            alu_SLTU when (i_Opcode = "1100011" and i_Funct3 = "111") else -- bgeu

            alu_SRA when (i_Opcode = "0110011" and i_Funct3 = "101" and i_Funct7 = "0100000") else -- sra
            alu_SRA when (i_Opcode = "0010011" and i_Funct3 = "101" and i_Funct7 = "0100000") -- srai

            else alu_ADD; -- default to ADD
    
        o_MemWrite <= '1' when (i_Opcode = "0100011" and i_Funct3 = "010") -- sw
            else '0';
        
        o_RegWrite <= '0' when (i_Opcode = "0100011" and i_Funct3 = "010") or -- sw
            (i_Opcode = "1100011" and i_Funct3 = "000") or -- beq
            (i_Opcode = "1100011" and i_Funct3 = "001") or -- bne
            (i_Opcode = "1100011" and i_Funct3 = "100") or -- blt
            (i_Opcode = "1100011" and i_Funct3 = "101") or -- bge
            (i_Opcode = "1100011" and i_Funct3 = "110") or -- bltu
            (i_Opcode = "1100011" and i_Funct3 = "111") -- bgeu
            else '1';
        
        o_PCorMemtoReg <= "01" when (i_Opcode = "0000011" and i_Funct3 = "010") else -- lw
            "01" when (i_Opcode = "0000011" and i_Funct3 = "000") else -- lb
            "01" when (i_Opcode = "0000011" and i_Funct3 = "001") else -- lh
            "01" when (i_Opcode = "0000011" and i_Funct3 = "100") else -- lbu
            "01" when (i_Opcode = "0000011" and i_Funct3 = "101") else -- lhu
            "10" when (i_Opcode = "1101111") else -- jal
            "10" when (i_Opcode = "1100111" and i_Funct3 = "000") -- jalr
            else "00";
        
        o_Branch <= '1' when (i_Opcode = "1100011" and i_Funct3 = "000") or -- beq
            (i_Opcode = "1100011" and i_Funct3 = "001") or -- bne
            (i_Opcode = "1100011" and i_Funct3 = "100") or -- blt
            (i_Opcode = "1100011" and i_Funct3 = "101") or -- bge
            (i_Opcode = "1100011" and i_Funct3 = "110") or -- bltu
            (i_Opcode = "1100011" and i_Funct3 = "111") -- bgeu
            else '0';

        o_Jump <= '1' when (i_Opcode = "1101111") or -- jal
            (i_Opcode = "1100111" and i_Funct3 = "000") -- jalr
            else '0';

        o_ImmSel <= imm_S_TYPE when (i_Opcode = "0100011" and i_Funct3 = "010") else -- sw
            imm_SB_TYPE when (i_Opcode = "1100011" and i_Funct3 = "000") else -- beq
            imm_SB_TYPE when (i_Opcode = "1100011" and i_Funct3 = "001") else -- bne
            imm_SB_TYPE when (i_Opcode = "1100011" and i_Funct3 = "100") else -- blt
            imm_SB_TYPE when (i_Opcode = "1100011" and i_Funct3 = "101") else -- bge
            imm_SB_TYPE when (i_Opcode = "1100011" and i_Funct3 = "110") else -- bltu
            imm_SB_TYPE when (i_Opcode = "1100011" and i_Funct3 = "111") else -- bgeu
            imm_U_TYPE when (i_Opcode = "0110111") else -- lui
            imm_U_TYPE when (i_Opcode = "0010111") else -- auipc
            imm_UJ_TYPE when (i_Opcode = "1101111") else -- jal
            else imm_I_TYPE; -- default to I type

end architecture behavioral;

