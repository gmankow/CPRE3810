library ieee;
use ieee.std_logic_1164.all;

entity dMem_Out_Mux is 
    port (
        i_dMemOut : in std_logic_vector(31 downto 0); -- Data Memory Output
        i_Func3 : in std_logic_vector(2 downto 0); -- funct3 field from instruction
        o_dMemOut_Muxed : out std_logic_vector(31 downto 0) -- Muxed Data Memory Output
    );
end entity dMem_Out_Mux;

architecture behavioral of dMem_Out_Mux is

    signal lw_out : std_logic_vector(31 downto 0);
    signal lh_out : std_logic_vector(31 downto 0);
    signal lb_out : std_logic_vector(31 downto 0);
    signal lhu_out : std_logic_vector(31 downto 0);
    signal lbu_out : std_logic_vector(31 downto 0);

    begin
        
        -- Load Word
        lw_out <= i_dMemOut;

        -- Load Half (signed)
        lh_out <= (31 downto 16 => i_dMemOut(15)) & i_dMemOut(15 downto 0);

        -- Load Half Unsigned
        lhu_out <= (31 downto 16 => '0') & i_dMemOut(15 downto 0);

        -- Load Byte (signed)
        lb_out <= (31 downto 8 => i_dMemOut(7)) & i_dMemOut(7 downto 0);

        -- Load Byte Unsigned
        lbu_out <= (31 downto 8 => '0') & i_dMemOut(7 downto 0);

        -- Mux
        with i_Func3 select
            o_dMemOut_Muxed <= lw_out when "010", -- LW
                                lh_out when "001", -- LH
                                lhu_out when "101", -- LHU
                                lb_out when "000", -- LB
                                lbu_out when "100", -- LBU
                                (others => '0') when others; -- Default case

end architecture behavioral;