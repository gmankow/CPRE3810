-- VHDL Testbench for the RISC-V Fetch Stage
-- This testbench verifies the functionality of the fetch unit, including
-- sequential instruction fetching, conditional branches (taken and not taken),
-- and unconditional jumps.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fetch is
end tb_fetch;

architecture testbench of tb_fetch is

    -- Component declaration for the unit under test (UUT)
    component fetch is
        port(
            i_Immediate       : in  std_logic_vector(31 downto 0);
            i_CLK             : in  std_logic;
            i_RST             : in  std_logic; -- Added reset port
            c_jump            : in  std_logic;
            c_branch          : in  std_logic;
            c_branch_cond_met : in  std_logic;
            o_PC_out          : out std_logic_vector(31 downto 0);
            o_PC_plus_4_out   : out std_logic_vector(31 downto 0) -- Matched new name
        );
    end component;

    -- Testbench signals
    signal s_Immediate       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_CLK             : std_logic                     := '0';
    signal s_RST             : std_logic                     := '0'; -- Reset signal
    signal s_jump            : std_logic                     := '0';
    signal s_branch          : std_logic                     := '0';
    signal s_branch_cond_met : std_logic                     := '0';
    signal s_PC_out          : std_logic_vector(31 downto 0);
    signal s_PC_plus_4_out   : std_logic_vector(31 downto 0);

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT : fetch
        port map(
            i_Immediate       => s_Immediate,
            i_CLK             => s_CLK,
            i_RST             => s_RST, -- Connect reset
            c_jump            => s_jump,
            c_branch          => s_branch,
            c_branch_cond_met => s_branch_cond_met,
            o_PC_out          => s_PC_out,
            o_PC_plus_4_out   => s_PC_plus_4_out
        );

    -- Clock generation process
    clk_process : process
    begin
        loop
            s_CLK <= '0';
            wait for CLK_PERIOD / 2;
            s_CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        report "Starting Fetch Stage Testbench";

        -- Apply reset at the beginning to initialize the PC
        s_RST <= '1';
        wait for CLK_PERIOD;
        s_RST <= '0';
        wait for CLK_PERIOD;

        -- After reset is released, on the next rising clock edge, PC becomes 4.
        assert (s_PC_out = x"00000004")
            report "Test Case 0 FAILED: PC should be x00000004 after first cycle but is " & to_hstring(s_PC_out)
            severity error;

        -- Test Case 1: Sequential PC increment (PC+4)
        report "Test Case 1: Sequential Execution (PC+4)";
        s_branch          <= '0';
        s_jump            <= '0';
        s_branch_cond_met <= '0';
        s_Immediate       <= (others => '0');

        wait for CLK_PERIOD; -- Wait one more cycle

        -- Expected PC after 2nd active cycle is x"00000008"
        assert (s_PC_out = x"00000008")
            report "Test Case 1 FAILED: PC should be x00000008 but is " & to_hstring(s_PC_out)
            severity error;
        assert (s_PC_plus_4_out = x"0000000C")
            report "Test Case 1 FAILED: PC+4 should be x0000000C but is " & to_hstring(s_PC_plus_4_out)
            severity error;


        -- Test Case 2: Branch instruction, condition NOT met
        report "Test Case 2: Branch Not Taken";
        s_branch          <= '1';
        s_branch_cond_met <= '0';
        s_Immediate       <= std_logic_vector(to_signed(20, 32)); -- Branch offset of 20
        wait for CLK_PERIOD; -- PC should still increment by 4

        -- Expected PC is x"0000000C"
        assert (s_PC_out = x"0000000C")
            report "Test Case 2 FAILED: PC should be x0000000C but is " & to_hstring(s_PC_out)
            severity error;


        -- Test Case 3: Branch instruction, condition IS met
        report "Test Case 3: Branch Taken";
        s_branch          <= '1';
        s_branch_cond_met <= '1';
        s_Immediate       <= std_logic_vector(to_signed(16, 32)); -- Branch offset of 16 bytes
        wait for CLK_PERIOD;

        -- PC was x"0000000C", branch target is PC + (16 << 1) = 12 + 32 = 44 (x"0000002C")
        assert (s_PC_out = x"0000002C")
            report "Test Case 3 FAILED: PC should be x0000002C but is " & to_hstring(s_PC_out)
            severity error;


        -- Test Case 4: Unconditional Jump
        report "Test Case 4: Unconditional Jump";
        s_branch          <= '0';
        s_jump            <= '1';
        s_Immediate       <= std_logic_vector(to_signed(100, 32)); -- Jump to address PC + 100<<1
        wait for CLK_PERIOD;
        
        -- PC was x"0000002C", jump target is PC + (100 << 1) = 44 + 200 = 244 (x"000000F4")
        assert (s_PC_out = x"000000F4")
            report "Test Case 4 FAILED: PC should be x000000F4 but is " & to_hstring(s_PC_out)
            severity error;


        report "All test cases passed!";
        wait; -- End of simulation
    end process;

end testbench;


