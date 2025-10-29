library IEEE;
use IEEE.std_logic_1164.all;

entity Datapath is 
    generic (N: integer := 32);  -- Number of bits in each register
    port (
        CLK : in std_logic; -- Clock
        RST : in std_logic; -- Reset all registers to 0

        i_immediate : in std_logic_vector(N-1 downto 0);
        i_nAdd_Sub : in std_logic;  -- 0 for add, 1 for sub
        i_ALUSrc : in std_logic;    -- 0 for choosing B, 1 for using immediate value

        i_dataIn : in std_logic_vector(N-1 downto 0); -- Data input to register file
        i_readSrc1 : in std_logic_vector(4 downto 0); -- Source register 1 address
        i_readSrc2 : in std_logic_vector(4 downto 0); -- Source register 2 address
        i_writeReg : in std_logic_vector(4 downto 0); -- Destination register address
        i_writeEnable : in std_logic -- Write enable
    );
end entity Datapath;

architecture structural of Datapath is

    signal s_regfile_out1 : std_logic_vector(N-1 downto 0); -- Output from source register 1
    signal s_regfile_out2 : std_logic_vector(N-1 downto 0); -- Output from source register 2
    signal s_alu_out : std_logic_vector(N-1 downto 0);      -- Output from ALU
    signal s_carry_out : std_logic;                          -- Carry out from ALU

    component register_file is
        generic (N : integer := 32);  -- Number of bits in each register
        port (
            CLK : in std_logic;
            RST : in std_logic;
            WriteEnable : in std_logic;
            Source1 : in std_logic_vector(4 downto 0); -- read s1 address
            Source2 : in std_logic_vector(4 downto 0); -- read s2 address
            WriteReg : in std_logic_vector(4 downto 0); -- write register address
            DIN : in std_logic_vector(N-1 downto 0);
            Source1Out : out std_logic_vector(N-1 downto 0); -- output of read s1
            Source2Out : out std_logic_vector(N-1 downto 0) -- output of read s2
        );
    end component;

    component add_sub_Nbit is
        generic (N : integer := 32);
        port(i_A          : in std_logic_vector(N-1 downto 0); -- from register file output 1
             i_B          : in std_logic_vector(N-1 downto 0); -- from register file output 2
             i_imm        : in std_logic_vector(N-1 downto 0); -- immediate value input
             i_nAdd_Sub   : in std_logic;  -- 0 for add, 1 for subtract
             i_ALUSrc     : in std_logic; -- 0 for choosing B, 1 for using immediate value
             o_SUM        : out std_logic_vector(N-1 downto 0);
             o_CARRY      : out std_logic); -- carry out 
    end component;

begin

    RegFile: register_file
        generic map(N => N)
        port map(
            CLK => CLK,
            RST => RST,
            WriteEnable => i_writeEnable,
            Source1 => i_readSrc1,
            Source2 => i_readSrc2,
            WriteReg => i_writeReg,
            -- DIN => i_dataIn  -- Data to write comes from input port (needed?????)
            DIN => s_alu_out,  -- Data to write comes from ALU output
            Source1Out => s_regfile_out1,
            Source2Out => s_regfile_out2
        );

    ALU: add_sub_Nbit
        generic map(N => N)
        port map(
            i_A => s_regfile_out1,
            i_B => s_regfile_out2,
            i_imm => i_immediate,
            i_nAdd_Sub => i_nAdd_Sub,
            i_ALUSrc => i_ALUSrc,
            o_SUM => s_alu_out,
            o_CARRY => s_carry_out
        );

end architecture structural;