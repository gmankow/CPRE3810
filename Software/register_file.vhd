library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV_types.all;

entity register_file is
    generic (
        N : integer := 32  -- Number of bits in each register
        );
    port (
        CLK : in std_logic;
        RST : in std_logic;
        WriteEnable : in std_logic;
        i_Source1 : in std_logic_vector(4 downto 0);
        i_Source2 : in std_logic_vector(4 downto 0);
        i_WriteReg : in std_logic_vector(4 downto 0);
        DIN : in std_logic_vector(N-1 downto 0);
        Source1Out : out std_logic_vector(N-1 downto 0);
        Source2Out : out std_logic_vector(N-1 downto 0)
    );
end entity register_file;

architecture structural of register_file is
    signal write_decoded : std_logic_vector(31 downto 0);
    signal registers_out : mux32_array; -- Array to hold outputs of 32 registers

    component register_N
        generic (
            N : integer := 32;
            INIT_VALUE : std_logic_vector(31 downto 0) := (others => '0') -- <== ADD THIS
        );
        port (
            i_CLK : in std_logic;
            i_RST : in std_logic;
            i_WE : in std_logic;
            i_D : in std_logic_vector(N-1 downto 0);
            o_Q : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component mux_32t1
        port (
            i_A : in std_logic_vector(4 downto 0);
            i_D : in mux32_array;
            o_Y : out std_logic_vector(31 downto 0)
        );
    end component;

    component decoder_5t32
        port (
            i_A : in std_logic_vector(4 downto 0);
            i_WE : in std_logic;
            o_D : out std_logic_vector(31 downto 0)
        );
    end component;

    begin

        decoder : decoder_5t32
            port map (
                i_A => i_WriteReg,
                i_WE => WriteEnable,
                o_D => write_decoded
            );
        
        gen_registers: for i in 1 to 31 generate
            gen_sp: if i = 2 generate
                reg_2: register_N
                    generic map (N => N, INIT_VALUE => x"7FFFEFFC")
                    port map (
                        i_CLK => CLK,
                        i_RST => RST,
                        i_WE  => write_decoded(i),
                        i_D   => DIN,
                        o_Q   => registers_out(i)
                    );
            end generate gen_sp;

            gen_other: if i /= 2 generate
                reg_i: register_N
                    generic map (N => N, INIT_VALUE => (others => '0'))
                    port map (
                        i_CLK => CLK,
                        i_RST => RST,
                        i_WE  => write_decoded(i),
                        i_D   => DIN,
                        o_Q   => registers_out(i)
                    );
            end generate gen_other;

        end generate gen_registers;

        -- Force register 0 to always be zero (RISC-V requirement)
        registers_out(0) <= (others => '0');

        mux : mux_32t1 -- already created 32-to-1 mux in mux_32t1.vhd
            port map (
                i_A => i_Source1,
                i_D => registers_out,
                o_Y => Source1Out
            );

        mux2 : mux_32t1 -- already created 32-to-1 mux in mux_32t1.vhd
            port map (
                i_A => i_Source2,
                i_D => registers_out,
                o_Y => Source2Out
            );

end structural;

