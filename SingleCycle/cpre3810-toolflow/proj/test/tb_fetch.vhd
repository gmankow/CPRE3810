-- Simplified VHDL Testbench for the RISC-V Fetch Stage
-- This testbench *must* use a clock as Fetch is sequential.
-- Inputs are set, and the clock is allowed to run.
-- Comments indicate the state at each clock cycle.
--
-- UPDATED: To match new Fetch.vhd entity (JALR, new start address)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fetch is
end tb_fetch;

architecture testbench of tb_fetch is

    -- Component declaration for the unit under test (UUT)
    -- UPDATED to match Fetch.vhd
    component fetch is
        port(
            i_Immediate       : in  std_logic_vector(31 downto 0);
            i_CLK             : in  std_logic;
            i_RST             : in  std_logic;
            i_ALUout          : in  std_logic_vector(31 downto 0); -- New
            c_jump            : in  std_logic;
            c_branch          : in  std_logic;
            c_branch_cond_met : in  std_logic;
            c_jalr            : in  std_logic;                     -- New
            o_PC_out          : out std_logic_vector(31 downto 0);
            o_PC_plus_4_out   : out std_logic_vector(31 downto 0);
            o_PC_final        : out std_logic_vector(31 downto 0)  -- New
        );
    end component;

    -- Testbench signals
    signal s_Immediate       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_CLK             : std_logic                     := '0';
    signal s_RST             : std_logic                     := '0';
    signal s_ALUout          : std_logic_vector(31 downto 0) := (others => '0'); -- New
    signal s_jump            : std_logic                     := '0';
    signal s_branch          : std_logic                     := '0';
    signal s_branch_cond_met : std_logic                     := '0';
    signal s_jalr            : std_logic                     := '0'; -- New
    signal s_PC_out          : std_logic_vector(31 downto 0);
    signal s_PC_plus_4_out   : std_logic_vector(31 downto 0);
    signal s_PC_final        : std_logic_vector(31 downto 0); -- New

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT : fetch
        port map(
            i_Immediate       => s_Immediate,
            i_CLK             => s_CLK,
            i_RST             => s_RST,
            i_ALUout          => s_ALUout,
            c_jump            => s_jump,
            c_branch          => s_branch,
            c_branch_cond_met => s_branch_cond_met,
            c_jalr            => s_jalr,
            o_PC_out          => s_PC_out,
            o_PC_plus_4_out   => s_PC_plus_4_out,
            o_PC_final        => s_PC_final
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
        -- Apply reset to initialize PC
        -- DUT register has INIT_VALUE => x"00400000"
        s_RST <= '1';
        wait for CLK_PERIOD;
        s_RST <= '0';
        s_jalr <= '0';
        s_ALUout <= (others => '0');
        wait for CLK_PERIOD;
        -- On this rising edge:
        -- Expected: o_PC_out = x"00400000", o_PC_plus_4_out = x"00400004"


        -- Test Case 1: Sequential PC increment (PC+4)
        s_branch          <= '0';
        s_jump            <= '0';
        s_branch_cond_met <= '0';
        s_Immediate       <= (others => '0');
        wait for CLK_PERIOD;
        -- On this rising edge:
        -- Expected: o_PC_out = x"00400004", o_PC_plus_4_out = x"00400008"

        wait for CLK_PERIOD;
        -- On this rising edge:
        -- Expected: o_PC_out = x"00400008", o_PC_plus_4_out = x"0040000C"


        -- Test Case 2: Branch instruction, condition NOT met
        s_branch          <= '1';
        s_branch_cond_met <= '0';
        s_Immediate       <= std_logic_vector(to_signed(20, 32)); -- Branch offset of 20
        wait for CLK_PERIOD;
        -- On this rising edge (Branch not taken):
        -- Expected: o_PC_out = x"0040000C", o_PC_plus_4_out = x"00400010"


        -- Test Case 3: Branch instruction, condition IS met
        s_branch          <= '1';
        s_branch_cond_met <= '1';
        s_Immediate       <= std_logic_vector(to_signed(16, 32)); -- Branch offset of 16 bytes
        wait for CLK_PERIOD;
        -- On this rising edge (Branch taken):
        -- Current PC is x"00400010". Branch target = PC + Imm = x"00400010" + 16 = x"00400020"
        -- Expected: o_PC_out = x"00400020", o_PC_plus_4_out = x"00400024"


        -- Test Case 4: Unconditional Jump (JAL)
        s_branch          <= '0';
        s_jump            <= '1';
        s_Immediate       <= std_logic_vector(to_signed(100, 32)); -- Jump to PC + 100
        wait for CLK_PERIOD;
        -- On this rising edge (Jump taken):
        -- Current PC is x"00400020". Jump target = PC + Imm = x"00400020" + 100 = x"00400084"
        -- Expected: o_PC_out = x"00400084", o_PC_plus_4_out = x"00400088"
        
        -- Test Case 5: Unconditional Jump (JALR)
        s_jump  <= '0';
        s_jalr  <= '1';
        s_ALUout <= x"12345678"; -- Set JALR target address
        wait for CLK_PERIOD;
        -- On this rising edge (JALR taken):
        -- Current PC is x"00400084". JALR Mux selects s_ALUout.
        -- Expected: o_PC_out = x"12345678", o_PC_plus_4_out = x"1234567C"

        -- Let it run one more cycle
        s_jalr <= '0';
        wait for CLK_PERIOD;
        -- On this rising edge:
        -- Expected: o_PC_out = x"1234567C", o_PC_plus_4_out = x"12345680"

        wait;
    end process;

end testbench;