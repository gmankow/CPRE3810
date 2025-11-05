-- Simplified VHDL Testbench for controlSignals
-- Sets inputs sequentially.
-- Added 'wait for 10 ns;' between tests to see each in a waveform.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_controlSignals is
end entity tb_controlSignals;

architecture behavioral of tb_controlSignals is

    -- DUT component
    component controlSignals is
        port(
            i_Opcode       : in  std_logic_vector(6 downto 0);
            i_Funct3       : in  std_logic_vector(2 downto 0);
            i_Funct7       : in  std_logic_vector(6 downto 0);
            o_ALUop        : out std_logic_vector(3 downto 0);
            o_Branch       : out std_logic;
            o_ALUsrcA      : out std_logic;
            o_ALUsrcB      : out std_logic;
            o_PCorMemtoReg : out std_logic_vector(1 downto 0);
            o_MemWrite     : out std_logic;
            o_RegWrite     : out std_logic;
            o_Jump         : out std_logic;
            o_ImmSel       : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Signals
    signal i_Opcode : std_logic_vector(6 downto 0) := (others => '0');
    signal i_Funct3 : std_logic_vector(2 downto 0) := (others => '0');
    signal i_Funct7 : std_logic_vector(6 downto 0) := (others => '0');

    signal o_ALUop : std_logic_vector(3 downto 0);
    signal o_Branch : std_logic;
    signal o_ALUsrcA : std_logic;
    signal o_ALUsrcB : std_logic;
    signal o_PCorMemtoReg : std_logic_vector(1 downto 0);
    signal o_MemWrite : std_logic;
    signal o_RegWrite : std_logic;
    signal o_Jump : std_logic;
    signal o_ImmSel : std_logic_vector(2 downto 0);

begin

    dut: component controlSignals
        port map(
            i_Opcode => i_Opcode,
            i_Funct3 => i_Funct3,
            i_Funct7 => i_Funct7,
            o_ALUop => o_ALUop,
            o_Branch => o_Branch,
            o_ALUsrcA => o_ALUsrcA,
            o_ALUsrcB => o_ALUsrcB,
            o_PCorMemtoReg => o_PCorMemtoReg,
            o_MemWrite => o_MemWrite,
            o_RegWrite => o_RegWrite,
            o_Jump => o_Jump,
            o_ImmSel => o_ImmSel
        );

    stimulus: process
    begin
        -- Test: addi
        i_Opcode <= "0010011"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: andi
        i_Opcode <= "0010011"; i_Funct3 <= "111"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: xori
        i_Opcode <= "0010011"; i_Funct3 <= "100"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: ori
        i_Opcode <= "0010011"; i_Funct3 <= "110"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: slti
        i_Opcode <= "0010011"; i_Funct3 <= "010"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: sltiu
        i_Opcode <= "0010011"; i_Funct3 <= "011"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: slli
        i_Opcode <= "0010011"; i_Funct3 <= "001"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: srli
        i_Opcode <= "0010011"; i_Funct3 <= "101"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: srai
        i_Opcode <= "0010011"; i_Funct3 <= "101"; i_Funct7 <= "0100000";
        wait for 10 ns;

        -- Test: add
        i_Opcode <= "0110011"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: sub
        i_Opcode <= "0110011"; i_Funct3 <= "000"; i_Funct7 <= "0100000";
        wait for 10 ns;

        -- Test: and
        i_Opcode <= "0110011"; i_Funct3 <= "111"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: or
        i_Opcode <= "0110011"; i_Funct3 <= "110"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: xor
        i_Opcode <= "0110011"; i_Funct3 <= "100"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: sll
        i_Opcode <= "0110011"; i_Funct3 <= "001"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: srl
        i_Opcode <= "0110011"; i_Funct3 <= "101"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: sra
        i_Opcode <= "0110011"; i_Funct3 <= "101"; i_Funct7 <= "0100000";
        wait for 10 ns;

        -- Test: slt
        i_Opcode <= "0110011"; i_Funct3 <= "010"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: sltu
        i_Opcode <= "0110011"; i_Funct3 <= "011"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: lw
        i_Opcode <= "0000011"; i_Funct3 <= "010"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: lb
        i_Opcode <= "0000011"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: lh
        i_Opcode <= "0000011"; i_Funct3 <= "001"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: lbu
        i_Opcode <= "0000011"; i_Funct3 <= "100"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: lhu
        i_Opcode <= "0000011"; i_Funct3 <= "101"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: sw
        i_Opcode <= "0100011"; i_Funct3 <= "010"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: beq
        i_Opcode <= "1100011"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: bne
        i_Opcode <= "1100011"; i_Funct3 <= "001"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: blt
        i_Opcode <= "1100011"; i_Funct3 <= "100"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: bge
        i_Opcode <= "1100011"; i_Funct3 <= "101"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: bltu
        i_Opcode <= "1100011"; i_Funct3 <= "110"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: bgeu
        i_Opcode <= "1100011"; i_Funct3 <= "111"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: jal
        i_Opcode <= "1101111"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: jalr
        i_Opcode <= "1100111"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: auipc
        i_Opcode <= "0010111"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        -- Test: lui
        i_Opcode <= "0110111"; i_Funct3 <= "000"; i_Funct7 <= "0000000";
        wait for 10 ns;

        wait;
    end process stimulus;

end architecture behavioral;