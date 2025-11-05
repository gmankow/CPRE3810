library ieee;
use ieee.std_logic_1164.all;

entity Barrel_Shifter is
    port (
        data_in      : in  std_logic_vector(31 downto 0);
        shift_amount : in  std_logic_vector(4 downto 0);
        ALUOp : in std_logic_vector (3 downto 0);
        data_out     : out std_logic_vector(31 downto 0)
    );
end entity Barrel_Shifter;

architecture structural of Barrel_Shifter is

    -- Component declaration for the 2-to-1 MUX
    component mux2t1 is
        port (
            i_D0          : in std_logic;
	        i_D1          : in std_logic;
	        i_S          : in std_logic;
	        o_O          : out std_logic
        );
    end component mux2t1;

    -- Signals for the unidirectional shifter core and reversal logic
    signal reversed_in    : std_logic_vector(31 downto 0) := (others => '0');
    signal shifter_in     : std_logic_vector(31 downto 0) := (others => '0');
    signal reversed_out   : std_logic_vector(31 downto 0) := (others => '0');
    signal shifter_out    : std_logic_vector(31 downto 0) := (others => '0');
    signal shift_in_bit :std_logic;
    signal c_direction :std_logic;

    -- Intermediate signals to connect the shifter stages
    signal stage_16_out : std_logic_vector(31 downto 0) := (others => '0');
    signal stage_8_out  : std_logic_vector(31 downto 0) := (others => '0');
    signal stage_4_out  : std_logic_vector(31 downto 0) := (others => '0');
    signal stage_2_out  : std_logic_vector(31 downto 0) := (others => '0');
    

begin

	
    shift_in_bit <= ALUOp(3) and data_in(31);
    c_direction <= ALUOp(0);
    --Create a reversed array of the input values
    gen_reverse_in: for i in 0 to 31 generate
        reversed_in(i) <= data_in(31-i);
    end generate gen_reverse_in;

    -- Create the first row of muxes that select between the regular and reversed input directions
    gen_input_mux: for i in 0 to 31 generate
        input_mux_i: component mux2t1
            port map (
                i_D0 => data_in(i),
                i_D1 => reversed_in(i),
                i_S  => c_direction,
                o_O  => shifter_in(i)
            );
    end generate gen_input_mux;

    -- Create the second row of muxes that shift by 16 bits
    -- Controlled by the most significant bit of the shift_amount
    gen_stage_16: for i in 0 to 31 generate
        -- This constant represents the "gap" in the diagram by which each stage had its inputs moved
        constant src_index : integer := i - 16;
        -- This signal caries the when statement I wrote in the design doc
        signal shift_src   : std_logic;
    begin
        shift_src <= shifter_in(src_index) when src_index >= 0 else shift_in_bit;
        shift_mux_16: component mux2t1
            port map (
                i_D0   => shifter_in(i),
                i_D1   => shift_src,
                i_S => shift_amount(4),
                o_O   => stage_16_out(i)
            );
    end generate gen_stage_16;

    -- Create the second row of muxes that shift by 8 bits
    -- Controlled by the most significant bit of the shift_amount
    gen_stage_8: for i in 0 to 31 generate
        -- This constant represents the "gap" in the diagram by which each stage had its inputs moved
        constant src_index : integer := i - 8;
        -- This signal caries the when statement I wrote in the design doc
        signal shift_src   : std_logic;
    begin
        shift_src <= stage_16_out(src_index) when src_index >= 0 else shift_in_bit;
        shift_mux_16: component mux2t1
            port map (
                i_D0   => stage_16_out(i),
                i_D1   => shift_src,
                i_S => shift_amount(3),
                o_O   => stage_8_out(i)
            );
    end generate gen_stage_8;

    -- Create the second row of muxes that shift by 16 bits
    -- Controlled by the most significant bit of the shift_amount
    gen_stage_4: for i in 0 to 31 generate
        -- This constant represents the "gap" in the diagram by which each stage had its inputs moved
        constant src_index : integer := i - 4;
        -- This signal caries the when statement I wrote in the design doc
        signal shift_src   : std_logic;
    begin
        shift_src <= stage_8_out(src_index) when src_index >= 0 else shift_in_bit;
        shift_mux_16: component mux2t1
            port map (
                i_D0   => stage_8_out(i),
                i_D1   => shift_src,
                i_S => shift_amount(2),
                o_O   => stage_4_out(i)
            );
    end generate gen_stage_4;

    gen_stage_2: for i in 0 to 31 generate
        constant src_index : integer := i - 2;
        signal shift_src   : std_logic;
    begin
        shift_src <= stage_4_out(src_index) when src_index >= 0 else shift_in_bit;
        shift_mux_2: component mux2t1
            port map (
                i_D0   => stage_4_out(i),
                i_D1   => shift_src,
                i_S => shift_amount(1),
                o_O   => stage_2_out(i)
            );
    end generate gen_stage_2;

    gen_stage_1: for i in 0 to 31 generate
        constant src_index : integer := i - 1;
        signal shift_src   : std_logic;
    begin
        shift_src <= stage_2_out(src_index) when src_index >= 0 else shift_in_bit;
        shift_mux_1: component mux2t1
            port map (
                i_D0   => stage_2_out(i),
                i_D1   => shift_src,
                i_S => shift_amount(0),
                o_O   => shifter_out(i) -- Output of the shifter core
            );
    end generate gen_stage_1;

    gen_reverse_out: for i in 0 to 31 generate
        reversed_out(i) <= shifter_out(31 - i);
    end generate gen_reverse_out;

    -- Output MUX Row: Selects between the normal shifter output for a LEFT shift
    -- or the reversed output for a RIGHT shift.
    gen_output_mux: for i in 0 to 31 generate
        output_mux_i: component mux2t1
            port map (
                i_D0   => shifter_out(i),  -- sel='0' (LEFT)
                i_D1   => reversed_out(i), -- sel='1' (RIGHT)
                i_S => c_direction,
                o_O   => data_out(i)
            );
    end generate gen_output_mux;

end;




