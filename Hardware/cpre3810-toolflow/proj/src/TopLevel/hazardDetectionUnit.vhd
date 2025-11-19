library ieee;
use ieee.std_logic_1164.all;

entity hazardDetectionUnit is
    port (
        rs1_id       : in std_logic_vector(4 downto 0);
        rs2_id       : in std_logic_vector(4 downto 0);
        rd_ex        : in std_logic_vector(4 downto 0);
        is_Imm       : in std_Logic;
        mem_read_ex  : in std_logic;
        branch_taken : in std_logic; -- Branch AND Branch_cond_met
        pc_write     : out std_logic;
        if_id_write  : out std_logic;
        if_id_flush  : out std_logic;
        id_ex_flush  : out std_logic;
        ex_mem_flush : out std_logic
    );
end entity hazardDetectionUnit;

architecture dataflow of hazardDetectionUnit is
    
    -- Internal signal to simplify the condition check
    signal load_use_hazard : std_logic;

begin

    -- load use hazard, ie, LW followed by ADD which uses that LW
    load_use_hazard <= '1' when (mem_read_ex = '1' and 
                                 (rd_ex = rs1_id or (rd_ex = rs2_id and is_Imm = '0'))) 
                           else '0';

    -- Stall PC
    pc_write <= '0' when (load_use_hazard = '1') else '1';

    -- Stall IF/ID Register
    if_id_write <= '0' when (load_use_hazard = '1') else '1';

    -- Flush IF/ID if Branch is taken
    if_id_flush <= '1' when (branch_taken = '1') else '0';

    -- Flush ID/EX (Insert Bubble) if:
    -- 1. Branch is taken (Control Hazard)
    -- 2. OR Load-Use Hazard is detected (We need to insert a NOP into EX)
    id_ex_flush <= '1' when (branch_taken = '1' or load_use_hazard = '1') else '0';
    ex_mem_flush <= '1' when (branch_taken = '1') else '0';

end architecture dataflow;