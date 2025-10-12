library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_controlSignals is
end entity tb_controlSignals;

architecture behavioral of tb_controlSignals is

    -- Function to convert std_logic_vector to string for reporting
    function to_string(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            if slv(i) = '1' then
                result(slv'length - i) := '1';
            else
                result(slv'length - i) := '0';
            end if;
        end loop;
        return result;
    end function;

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
        desc   : string(1 to 10);
    end record;

    -- array type declaration
    type tv_array is array (natural range <>) of tv_rec;

    -- list of test vectors covering opcodes and funct fields used in controlSignals
    constant tvs : tv_array := (
        -- I-type ALU immediates
        (opcode => "0010011", funct3 => "000", funct7 => "0000000", desc => "addi      "),
        (opcode => "0010011", funct3 => "111", funct7 => "0000000", desc => "andi      "),
        (opcode => "0010011", funct3 => "100", funct7 => "0000000", desc => "xori      "),
        (opcode => "0010011", funct3 => "110", funct7 => "0000000", desc => "ori       "),
        (opcode => "0010011", funct3 => "010", funct7 => "0000000", desc => "slti      "),
        (opcode => "0010011", funct3 => "011", funct7 => "0000000", desc => "sltiu     "),
        (opcode => "0010011", funct3 => "001", funct7 => "0000000", desc => "slli      "),
        (opcode => "0010011", funct3 => "101", funct7 => "0000000", desc => "srli      "),
        (opcode => "0010011", funct3 => "101", funct7 => "0100000", desc => "srai      "),

        -- R-type ALU ops
        (opcode => "0110011", funct3 => "000", funct7 => "0000000", desc => "add       "),
        (opcode => "0110011", funct3 => "000", funct7 => "0100000", desc => "sub       "),
        (opcode => "0110011", funct3 => "111", funct7 => "0000000", desc => "and       "),
        (opcode => "0110011", funct3 => "110", funct7 => "0000000", desc => "or        "),
        (opcode => "0110011", funct3 => "100", funct7 => "0000000", desc => "xor       "),
        (opcode => "0110011", funct3 => "001", funct7 => "0000000", desc => "sll       "),
        (opcode => "0110011", funct3 => "101", funct7 => "0000000", desc => "srl       "),
        (opcode => "0110011", funct3 => "101", funct7 => "0100000", desc => "sra       "),
        (opcode => "0110011", funct3 => "010", funct7 => "0000000", desc => "slt       "),
        (opcode => "0110011", funct3 => "011", funct7 => "0000000", desc => "sltu      "),

        -- loads
        (opcode => "0000011", funct3 => "010", funct7 => "0000000", desc => "lw        "),
        (opcode => "0000011", funct3 => "000", funct7 => "0000000", desc => "lb        "),
        (opcode => "0000011", funct3 => "001", funct7 => "0000000", desc => "lh        "),
        (opcode => "0000011", funct3 => "100", funct7 => "0000000", desc => "lbu       "),
        (opcode => "0000011", funct3 => "101", funct7 => "0000000", desc => "lhu       "),

        -- stores
        (opcode => "0100011", funct3 => "010", funct7 => "0000000", desc => "sw        "),

        -- branches
        (opcode => "1100011", funct3 => "000", funct7 => "0000000", desc => "beq       "),
        (opcode => "1100011", funct3 => "001", funct7 => "0000000", desc => "bne       "),
        (opcode => "1100011", funct3 => "100", funct7 => "0000000", desc => "blt       "),
        (opcode => "1100011", funct3 => "101", funct7 => "0000000", desc => "bge       "),
        (opcode => "1100011", funct3 => "110", funct7 => "0000000", desc => "bltu      "),
        (opcode => "1100011", funct3 => "111", funct7 => "0000000", desc => "bgeu      "),

        -- jumps and others
        (opcode => "1101111", funct3 => "000", funct7 => "0000000", desc => "jal       "),
        (opcode => "1100111", funct3 => "000", funct7 => "0000000", desc => "jalr      "),
        (opcode => "0010111", funct3 => "000", funct7 => "0000000", desc => "auipc     "),
        (opcode => "0110111", funct3 => "000", funct7 => "0000000", desc => "lui       ")
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
        variable error_count : integer := 0;
    begin
        report "Starting controlSignals testbench";

        for i in tvs'range loop
            i_Opcode <= tvs(i).opcode;
            i_Funct3 <= tvs(i).funct3;
            i_Funct7 <= tvs(i).funct7;

            wait for clk_period; -- allow outputs to settle

            report "Test " & integer'image(i+1) & ": " & tvs(i).desc severity note;
            report "  Input:  opcode=" & to_string(tvs(i).opcode) & " funct3=" & to_string(tvs(i).funct3) & " funct7=" & to_string(tvs(i).funct7) severity note;
            report "  Output: ALUop=" & to_string(o_ALUop) & " ALUsrcA=" & std_logic'image(o_ALUsrcA) & " ALUsrcB=" & std_logic'image(o_ALUsrcB) severity note;
            report "          MemWr=" & std_logic'image(o_MemWrite) & " RegWr=" & std_logic'image(o_RegWrite) & " Branch=" & std_logic'image(o_Branch) & " Jump=" & std_logic'image(o_Jump) severity note;
            report "          PCMemReg=" & to_string(o_PCorMemtoReg) & " ImmSel=" & to_string(o_ImmSel) severity note;

            -- Basic sanity checks
            if (tvs(i).opcode = "0100011") then -- Store instructions
                if o_MemWrite /= '1' then
                    report "ERROR: Store instruction should have MemWrite=1" severity error;
                    error_count := error_count + 1;
                end if;
                if o_RegWrite /= '0' then
                    report "ERROR: Store instruction should have RegWrite=0" severity error;
                    error_count := error_count + 1;
                end if;
            elsif (tvs(i).opcode = "1100011") then -- Branch instructions
                if o_Branch /= '1' then
                    report "ERROR: Branch instruction should have Branch=1" severity error;
                    error_count := error_count + 1;
                end if;
                if o_RegWrite /= '0' then
                    report "ERROR: Branch instruction should have RegWrite=0" severity error;
                    error_count := error_count + 1;
                end if;
            elsif (tvs(i).opcode = "1101111") or (tvs(i).opcode = "1100111") then -- Jump instructions
                if o_Jump /= '1' then
                    report "ERROR: Jump instruction should have Jump=1" severity error;
                    error_count := error_count + 1;
                end if;
            end if;

            report " " severity note; -- blank line for readability
            wait for clk_period;
        end loop;

        if error_count = 0 then
            report "controlSignals testbench PASSED - All " & integer'image(tvs'length) & " tests completed successfully!" severity note;
        else
            report "controlSignals testbench FAILED - " & integer'image(error_count) & " errors found" severity failure;
        end if;
        wait;
    end process stimulus;

end architecture behavioral;

-- Created with VSCode Claude Sonnet 4
