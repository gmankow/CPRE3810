-- MEM/WB Register
-- This is the fourth and final pipeline register.
-- It latches the results from the Memory (MEM) stage and passes
-- them to the Write-Back (WB) stage.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- This entity has been updated with the final
-- control signals (RegWrite, RegWrAddr, etc.)
entity MEM_WB_Reg is
    port (
        i_CLK           : in std_logic; -- Clock
        i_RST           : in std_logic; -- Reset
        
        -- Control Signals from MEM stage
        i_Halt          : in std_logic; -- Halt signal
        i_RegWrite      : in std_logic; -- Write enable for Register File
        i_PCorMemtoReg  : in std_logic_vector(1 downto 0); -- Mux select for WB data
        i_Fuct3         : in std_logic_vector(2 downto 0); -- funct3 (for load sign-extension)
        i_RegWrAddr     : in std_logic_vector(4 downto 0); -- Destination register address (rd)

        -- Data Signals from MEM stage
        i_ALUout        : in std_logic_vector(31 downto 0); -- Result from ALU
        i_dMemOut       : in std_logic_vector(31 downto 0); -- Data read from memory
        i_PCPlus4       : in std_logic_vector(31 downto 0); -- PC+4 (for JAL/JALR)
        
        -- Corresponding Outputs to WB stage
        o_Halt          : out std_logic;
        o_RegWrite      : out std_logic;
        o_PCorMemtoReg  : out std_logic_vector(1 downto 0);
        o_ALUout        : out std_logic_vector(31 downto 0);
        o_dMemOut       : out std_logic_vector(31 downto 0);
        o_PCPlus4       : out std_logic_vector(31 downto 0);
        o_Fuct3         : out std_logic_vector(2 downto 0);
        o_RegWrAddr     : out std_logic_vector(4 downto 0)
    );
end entity MEM_WB_Reg;

architecture structural of MEM_WB_Reg is

    -- Component for a generic N-bit register
    component register_N
        generic (
            N : integer := 32;
            INIT_VALUE : std_logic_vector(N-1 downto 0) := (others => '0')
        );
        port(
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE  : in std_logic; -- Write Enable
            i_D   : in std_logic_vector(N-1 downto 0); -- Data In
            o_Q   : out std_logic_vector(N-1 downto 0) -- Data Out
        );
    end component;

    -- Internal signals to hold the register outputs
    signal Halt_reg         : std_logic_vector(0 downto 0);
    signal RegWrite_reg     : std_logic_vector(0 downto 0);
    signal PCorMemtoReg_reg : std_logic_vector(1 downto 0);
    signal Fuct3_reg        : std_logic_vector(2 downto 0);
    signal ALUout_reg       : std_logic_vector(31 downto 0);
    signal dMemOut_reg      : std_logic_vector(31 downto 0);
    signal PCPlus4_reg      : std_logic_vector(31 downto 0);
    signal RegWrAddr_reg    : std_logic_vector(4 downto 0);

begin
    
    -- Instantiate registers for each output signal.
    -- For this "dumb" pipeline, i_WE is always '1'.
    -- The register will update every clock cycle unless the clock is gated (not done here).
    -- A real implementation would add i_Stall logic to control i_WE.
    
    Halt_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D(0) => i_Halt,
            o_Q   => Halt_reg
        );

    RegWrite_reg_inst : register_N
        generic map (N => 1)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D(0) => i_RegWrite,
            o_Q   => RegWrite_reg
        );

    PCorMemtoReg_reg_inst : register_N
        generic map (N => 2) -- 2 bits
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D   => i_PCorMemtoReg,
            o_Q   => PCorMemtoReg_reg
        );

    Fuct3_reg_inst : register_N
        generic map (N => 3)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D   => i_Fuct3,
            o_Q   => Fuct3_reg
        );

    ALUout_reg_inst : register_N
        generic map (N => 32)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D   => i_ALUout,
            o_Q   => ALUout_reg
        );

    dMemOut_reg_inst : register_N
        generic map (N => 32)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D   => i_dMemOut,
            o_Q   => dMemOut_reg
        );

    PCPlus4_reg_inst : register_N
        generic map (N => 32)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D   => i_PCPlus4,
            o_Q   => PCPlus4_reg
        );

    RegWrAddr_reg_inst : register_N
        generic map (N => 5)
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => '1',
            i_D   => i_RegWrAddr,
            o_Q   => RegWrAddr_reg
        );

    -- Connect internal register outputs to the entity's outputs
    o_Halt         <= Halt_reg(0);
    o_RegWrite     <= RegWrite_reg(0);
    o_PCorMemtoReg <= PCorMemtoReg_reg;
    o_Fuct3        <= Fuct3_reg;
    o_ALUout       <= ALUout_reg;
    o_dMemOut      <= dMemOut_reg;
    o_PCPlus4      <= PCPlus4_reg;
    o_RegWrAddr    <= RegWrAddr_reg;

end architecture structural;