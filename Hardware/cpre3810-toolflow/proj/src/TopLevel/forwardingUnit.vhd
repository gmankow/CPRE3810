library ieee;
use ieee.std_logic_1164.all;

entity forwardingUnit is
    port (
        rs1_ex        : in std_logic_vector(4 downto 0);
        rs2_ex        : in std_logic_vector(4 downto 0);
        rd_mem        : in std_logic_vector(4 downto 0);
        reg_write_mem : in std_logic;
        rd_wb         : in std_logic_vector(4 downto 0);
        reg_write_wb  : in std_logic;
        forward_a     : out std_logic_vector(1 downto 0);
        forward_b     : out std_logic_vector(1 downto 0)
    );
end entity forwardingUnit;

architecture dataflow of forwardingUnit is

begin
    -- 01 -> write from EX/MEM
    -- 10 -> write from MEM/WB

    -- rs1 (A)
    -- Forward from EX/MEM
    forward_a <= "01" when (reg_write_mem = '1' and rd_mem /= "00000" and rd_mem = rs1_ex) else
                 -- Forward from MEM/WB
                 "10" when (reg_write_wb = '1' and rd_wb /= "00000" and rd_wb = rs1_ex) else
                 -- Default
                 "00";

    -- rs2 (B)
    -- Forward from EX/MEM
    forward_b <= "01" when (reg_write_mem = '1' and rd_mem /= "00000" and rd_mem = rs2_ex) else
                 -- Forward from MEM/WB
                 "10" when (reg_write_wb = '1' and rd_wb /= "00000" and rd_wb = rs2_ex) else
                 -- Default
                 "00";

end architecture dataflow;