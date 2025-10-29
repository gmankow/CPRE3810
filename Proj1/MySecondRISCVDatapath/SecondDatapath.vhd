library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SecondDatapath is 
    port (
        Source1 : in std_logic_vector(4 downto 0); -- Read register 1 address
        Source2 : in std_logic_vector(4 downto 0); -- Read register 2 address
        WriteReg : in std_logic_vector(4 downto 0); -- Write register address
        Imm : in std_logic_vector(11 downto 0); -- 12 Bit immediate value

        RegWriteEn : in std_logic; -- Register file write enable
        MemWriteEn : in std_logic; -- Memory write enable

        ALUSrc : in std_logic; -- '1' to select immediate, '0' to select register
        nAdd_Sub : in std_logic; -- '1' for subtract, '0' for add
        MemToReg : in std_logic; -- '1' to select memory data, '0' to select ALU result
        SignExt : in std_logic; -- '1' for sign extension, '0' for zero extension

        CLK : in std_logic; -- Clock
        RST : in std_logic -- Reset all registers to 0
    );
end entity SecondDatapath;

architecture structural of SecondDatapath is 

    signal s_regfile_out1 : std_logic_vector(31 downto 0); -- Output from source 1
    signal s_regfile_out2 : std_logic_vector(31 downto 0); -- Output from source 2
    signal s_imm_ext : std_logic_vector(31 downto 0); -- Sign-extended immediate value
    signal s_alu_result : std_logic_vector(31 downto 0); -- ALU result
    signal s_mem_data : std_logic_vector(31 downto 0); -- Data read from memory
    signal s_mem_mux_out : std_logic_vector(31 downto 0); -- Output from MemToReg mux

    component register_file is 
        port (
            CLK : in std_logic;
            RST : in std_logic;
            WriteEnable : in std_logic;
            Source1 : in std_logic_vector(4 downto 0); -- read s1 address
            Source2 : in std_logic_vector(4 downto 0); -- read s2 address
            WriteReg : in std_logic_vector(4 downto 0); -- write register address
            DIN : in std_logic_vector(31 downto 0);
            Source1Out : out std_logic_vector(31 downto 0); -- output of read s1
            Source2Out : out std_logic_vector(31 downto 0) -- output of read s2
        );
    end component;

    component extender_12t32 is
        port(
            i_in    : in  std_logic_vector(11 downto 0); -- 12 bit immediate value
            i_sign  : in  std_logic; -- '1' for sign extension, '0' for zero extension
            o_out   : out std_logic_vector(31 downto 0)
        );
    end component;

    component add_sub_Nbit is
        generic (N : integer := 32);
        port(
            i_A          : in std_logic_vector(N-1 downto 0); -- from register file output 1
            i_B          : in std_logic_vector(N-1 downto 0); -- from register file output 2 or immediate value
            i_imm        : in std_logic_vector(N-1 downto 0); -- immediate value input
            i_nAdd_Sub   : in std_logic;  -- 0 for add, 1 for subtract
            i_ALUSrc     : in std_logic; -- 0 for choosing B, 1 for using immediate value
            o_SUM        : out std_logic_vector(N-1 downto 0) -- ALU result
        );
    end component;

    component mux2t1_N is
      generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
      port(i_S          : in std_logic;
           i_D0         : in std_logic_vector(N-1 downto 0);
           i_D1         : in std_logic_vector(N-1 downto 0);
           o_O          : out std_logic_vector(N-1 downto 0));
    end component;

    component mem is 
        generic(
            DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 10
        );

        port(
            clk		: in std_logic;
            addr	        : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data	        : in std_logic_vector((DATA_WIDTH-1) downto 0);
            we		: in std_logic := '1';
            q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

begin

    RegFile: register_file
        port map(
            CLK => CLK,
            RST => RST,
            WriteEnable => RegWriteEn,
            Source1 => Source1,
            Source2 => Source2,
            WriteReg => WriteReg,
            DIN => s_mem_mux_out,  -- Data to write comes from mux (ALU or Memory)
            Source1Out => s_regfile_out1,
            Source2Out => s_regfile_out2
        );

    ImmExt: extender_12t32
        port map(
            i_in => Imm,
            i_sign => SignExt,
            o_out => s_imm_ext
        );

    ALU: add_sub_Nbit
        generic map(N => 32)
        port map(
            i_A => s_regfile_out1,
            i_B => s_regfile_out2,
            i_imm => s_imm_ext,
            i_nAdd_Sub => nAdd_Sub,
            i_ALUSrc => ALUSrc,
            o_SUM => s_alu_result
        );

    Memory: mem
        generic map(
            DATA_WIDTH => 32,
            ADDR_WIDTH => 10
        )
        port map(
            clk => CLK,
            addr => s_alu_result(11 downto 2), -- Since word addressable, use bits [11:2] for 10-bit address
            data => s_regfile_out2, -- Data to write comes from register file output 2
            we => MemWriteEn,
            q => s_mem_data
        );

    MemToRegMux: mux2t1_N
        generic map(N => 32)
        port map(
            i_S => MemToReg,
            i_D0 => s_alu_result, -- ALU result (0)
            i_D1 => s_mem_data,   -- Data read from memory (1)
            o_O => s_mem_mux_out     -- Output to write back to register file
        );

end architecture structural;

