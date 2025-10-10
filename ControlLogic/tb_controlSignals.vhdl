library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_controlSignals is
end entity tb_controlSignals;

architecture behavioral of tb_controlSignals is

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

    constant clk_period : time := 10 ns;

    -- helper type for test vectors
    type tv_rec is record
        opcode : std_logic_vector(6 downto 0);
        funct3 : std_logic_vector(2 downto 0);
        funct7 : std_logic_vector(6 downto 0);
        desc   : string(1 to 40);
    end record;

    -- list of test vectors covering opcodes and funct fields used in controlSignals
    constant tvs : array (natural range <>) of tv_rec := (
        -- I-type ALU immediates
        (opcode => "0010011", funct3 => "000", funct7 => (others => '0'), desc => "addi" & (others => ' ')),
        (opcode => "0010011", funct3 => "111", funct7 => (others => '0'), desc => "andi" & (others => ' ')),
        (opcode => "0010011", funct3 => "100", funct7 => (others => '0'), desc => "xori" & (others => ' ')),
        (opcode => "0010011", funct3 => "110", funct7 => (others => '0'), desc => "ori" & (others => ' ')),
        (opcode => "0010011", funct3 => "010", funct7 => (others => '0'), desc => "slti" & (others => ' ')),
        (opcode => "0010011", funct3 => "011", funct7 => (others => '0'), desc => "sltiu" & (others => ' ')),
        (opcode => "0010011", funct3 => "001", funct7 => "0000000", desc => "slli" & (others => ' ')),
        (opcode => "0010011", funct3 => "101", funct7 => "0000000", desc => "srli" & (others => ' ')),
        (opcode => "0010011", funct3 => "101", funct7 => "0100000", desc => "srai" & (others => ' ')),

        -- R-type ALU ops
        (opcode => "0110011", funct3 => "000", funct7 => "0000000", desc => "add" & (others => ' ')),
        (opcode => "0110011", funct3 => "000", funct7 => "0100000", desc => "sub" & (others => ' ')),
        (opcode => "0110011", funct3 => "111", funct7 => "0000000", desc => "and" & (others => ' ')),
        (opcode => "0110011", funct3 => "110", funct7 => "0000000", desc => "or" & (others => ' ')),
        (opcode => "0110011", funct3 => "100", funct7 => "0000000", desc => "xor" & (others => ' ')),
        (opcode => "0110011", funct3 => "001", funct7 => "0000000", desc => "sll" & (others => ' ')),
        (opcode => "0110011", funct3 => "101", funct7 => "0000000", desc => "srl" & (others => ' ')),
        (opcode => "0110011", funct3 => "101", funct7 => "0100000", desc => "sra" & (others => ' ')),
        (opcode => "0110011", funct3 => "010", funct7 => "0000000", desc => "slt" & (others => ' ')),
        (opcode => "0110011", funct3 => "011", funct7 => "0000000", desc => "sltu" & (others => ' ')),

        -- loads
        (opcode => "0000011", funct3 => "010", funct7 => (others => '0'), desc => "lw" & (others => ' ')),
        (opcode => "0000011", funct3 => "000", funct7 => (others => '0'), desc => "lb" & (others => ' ')),
        (opcode => "0000011", funct3 => "001", funct7 => (others => '0'), desc => "lh" & (others => ' ')),
        (opcode => "0000011", funct3 => "100", funct7 => (others => '0'), desc => "lbu" & (others => ' ')),
        (opcode => "0000011", funct3 => "101", funct7 => (others => '0'), desc => "lhu" & (others => ' ')),

        -- stores
        (opcode => "0100011", funct3 => "010", funct7 => (others => '0'), desc => "sw" & (others => ' ')),
        (opcode => "0100011", funct3 => "000", funct7 => (others => '0'), desc => "sb" & (others => ' ')),
        (opcode => "0100011", funct3 => "001", funct7 => (others => '0'), desc => "sh" & (others => ' ')),

        -- branches
        (opcode => "1100011", funct3 => "000", funct7 => (others => '0'), desc => "beq" & (others => ' ')),
        (opcode => "1100011", funct3 => "001", funct7 => (others => '0'), desc => "bne" & (others => ' ')),
        (opcode => "1100011", funct3 => "100", funct7 => (others => '0'), desc => "blt" & (others => ' ')),
        (opcode => "1100011", funct3 => "101", funct7 => (others => '0'), desc => "bge" & (others => ' ')),
        (opcode => "1100011", funct3 => "110", funct7 => (others => '0'), desc => "bltu" & (others => ' ')),
        (opcode => "1100011", funct3 => "111", funct7 => (others => '0'), desc => "bgeu" & (others => ' ')),

        -- jumps and others
        (opcode => "1101111", funct3 => (others => '0'), funct7 => (others => '0'), desc => "jal" & (others => ' ')),
        (opcode => "1100111", funct3 => "000", funct7 => (others => '0'), desc => "jalr" & (others => ' ')),
        (opcode => "0010111", funct3 => (others => '0'), funct7 => (others => '0'), desc => "auipc" & (others => ' ')),
        (opcode => "0110111", funct3 => (others => '0'), funct7 => (others => '0'), desc => "lui" & (others => ' '))
    );

begin

    dut: entity work.controlSignals
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
        report "Starting controlSignals testbench";

        for i in tvs'range loop
            i_Opcode <= tvs(i).opcode;
            i_Funct3 <= tvs(i).funct3;
            i_Funct7 <= tvs(i).funct7;

            wait for clk_period; -- allow outputs to settle

            report "Test: " & tvs(i).desc & " -- opcode=" & tvs(i).opcode & " funct3=" & tvs(i).funct3 & " funct7=" & tvs(i).funct7 severity note;
            report "  -> o_ALUop=" & o_ALUop & " o_ALUsrcA=" & o_ALUsrcA & " o_ALUsrcB=" & o_ALUsrcB & " o_MemWrite=" & o_MemWrite & " o_RegWrite=" & o_RegWrite & " o_Branch=" & o_Branch & " o_Jump=" & o_Jump & " o_PCorMemtoReg=" & o_PCorMemtoReg & " o_ImmSel=" & o_ImmSel severity note;

            wait for clk_period;
        end loop;

        report "controlSignals testbench finished";
        wait;
    end process stimulus;

end architecture behavioral;

-- Created with VSCode Copilot GPT-5 mini
