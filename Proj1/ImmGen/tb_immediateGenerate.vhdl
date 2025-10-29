library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_immediateGenerate is
end entity tb_immediateGenerate;

architecture behavioral of tb_immediateGenerate is

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

    -- Function to convert std_logic_vector to hexadecimal string
    function to_hex_string(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length/4);
        variable temp : std_logic_vector(3 downto 0);
    begin
        for i in 0 to (slv'length/4 - 1) loop
            temp := slv((i+1)*4-1 downto i*4);
            case temp is
                when "0000" => result(slv'length/4 - i) := '0';
                when "0001" => result(slv'length/4 - i) := '1';
                when "0010" => result(slv'length/4 - i) := '2';
                when "0011" => result(slv'length/4 - i) := '3';
                when "0100" => result(slv'length/4 - i) := '4';
                when "0101" => result(slv'length/4 - i) := '5';
                when "0110" => result(slv'length/4 - i) := '6';
                when "0111" => result(slv'length/4 - i) := '7';
                when "1000" => result(slv'length/4 - i) := '8';
                when "1001" => result(slv'length/4 - i) := '9';
                when "1010" => result(slv'length/4 - i) := 'A';
                when "1011" => result(slv'length/4 - i) := 'B';
                when "1100" => result(slv'length/4 - i) := 'C';
                when "1101" => result(slv'length/4 - i) := 'D';
                when "1110" => result(slv'length/4 - i) := 'E';
                when "1111" => result(slv'length/4 - i) := 'F';
                when others => result(slv'length/4 - i) := 'X';
            end case;
        end loop;
        return result;
    end function;

    signal i_ImmType : std_logic_vector(2 downto 0) := (others => '0');
    signal i_Instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal o_Immediate : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

    -- helper type for test vectors
    type tv_rec is record
        imm_type : std_logic_vector(2 downto 0);
        instruction : std_logic_vector(31 downto 0);
        expected : std_logic_vector(31 downto 0);
        desc : string(1 to 15);
    end record;

    -- array type declaration
    type tv_array is array (natural range <>) of tv_rec;

    -- Test vectors for different immediate types
    constant tvs : tv_array := (
        -- I-type immediates (bits 31-20)
        (imm_type => "000", instruction => x"00C58593", expected => x"0000000C", desc => "I-type +12     "), -- addi x11, x11, 12
        (imm_type => "000", instruction => x"FFF58593", expected => x"FFFFFFFF", desc => "I-type -1      "), -- addi x11, x11, -1
        (imm_type => "000", instruction => x"80058593", expected => x"FFFFF800", desc => "I-type -2048   "), -- addi x11, x11, -2048
        (imm_type => "000", instruction => x"7FF58593", expected => x"000007FF", desc => "I-type +2047   "), -- addi x11, x11, 2047
        
        -- S-type immediates (bits 31-25, 11-7)
        (imm_type => "001", instruction => x"00B62023", expected => x"00000000", desc => "S-type offset 0"), -- sw x11, 0(x12)
        (imm_type => "001", instruction => x"00B62223", expected => x"00000004", desc => "S-type offset 4"), -- sw x11, 4(x12)
        (imm_type => "001", instruction => x"FEB62E23", expected => x"FFFFFFFC", desc => "S-type offset-4"), -- sw x11, -4(x12)
        
        -- SB-type immediates (branch offsets)
        (imm_type => "010", instruction => x"00B60463", expected => x"00000008", desc => "SB-type +8     "), -- beq x12, x11, 8
        (imm_type => "010", instruction => x"FEB616E3", expected => x"FFFFFFEC", desc => "SB-type -4     "), -- bne x12, x11, -4
        (imm_type => "010", instruction => x"00B61063", expected => x"00000000", desc => "SB-type 0      "), -- beq x12, x11, 0
        
        -- U-type immediates (upper 20 bits)
        (imm_type => "011", instruction => x"123455B7", expected => x"12345000", desc => "U-type upper   "), -- lui x11, 0x12345
        (imm_type => "011", instruction => x"FFFFF5B7", expected => x"FFFFF000", desc => "U-type neg     "), -- lui x11, 0xFFFFF
        (imm_type => "011", instruction => x"000015B7", expected => x"00001000", desc => "U-type small   "), -- lui x11, 1
        
        -- UJ-type immediates (jump offsets)
        (imm_type => "100", instruction => x"008000EF", expected => x"00000008", desc => "UJ-type +8     "), -- jal x1, 8
        (imm_type => "100", instruction => x"FF8000EF", expected => x"FFF007F8", desc => "UJ-type -8     "), -- jal x1, -8
        (imm_type => "100", instruction => x"000000EF", expected => x"00000000", desc => "UJ-type 0      ")  -- jal x1, 0
    );

begin

    dut: entity work.immediateGenerate
        port map(
            i_ImmType => i_ImmType,
            i_Instruction => i_Instruction,
            o_Immediate => o_Immediate
        );

    stimulus: process
        variable error_count : integer := 0;
    begin
        report "Starting immediateGenerate testbench";

        for i in tvs'range loop
            i_ImmType <= tvs(i).imm_type;
            i_Instruction <= tvs(i).instruction;

            wait for clk_period; -- allow outputs to settle

            report "Test " & integer'image(i+1) & ": " & tvs(i).desc severity note;
            report "  Input:    ImmType=" & to_string(tvs(i).imm_type) & " Instruction=0x" & to_hex_string(tvs(i).instruction) severity note;
            report "  Expected: 0x" & to_hex_string(tvs(i).expected) & " (" & integer'image(to_integer(signed(tvs(i).expected))) & ")" severity note;
            report "  Actual:   0x" & to_hex_string(o_Immediate) & " (" & integer'image(to_integer(signed(o_Immediate))) & ")" severity note;

            -- Check if output matches expected value
            if o_Immediate /= tvs(i).expected then
                report "ERROR: Immediate value mismatch!" severity error;
                error_count := error_count + 1;
            else
                report "PASS: Immediate value correct" severity note;
            end if;

            report " " severity note; -- blank line for readability
            wait for clk_period;
        end loop;

        -- Test invalid immediate type
        i_ImmType <= "111"; -- Invalid type
        i_Instruction <= x"12345678";
        wait for clk_period;
        
        report "Test " & integer'image(tvs'length + 1) & ": Invalid ImmType" severity note;
        if o_Immediate = x"00000000" then
            report "PASS: Invalid type correctly outputs zero" severity note;
        else
            report "ERROR: Invalid type should output zero" severity error;
            error_count := error_count + 1;
        end if;

        if error_count = 0 then
            report "immediateGenerate testbench PASSED - All " & integer'image(tvs'length + 1) & " tests completed successfully!" severity note;
        else
            report "immediateGenerate testbench FAILED - " & integer'image(error_count) & " errors found" severity failure;
        end if;
        wait;
    end process stimulus;

end architecture behavioral;

-- Created with VSCode Copilot 

