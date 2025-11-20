library ieee;
use ieee.std_logic_1164.all;

entity hazardDetectionUnit is
    port (
        rs1_id       : in std_logic_vector(4 downto 0);
        rs2_id       : in std_logic_vector(4 downto 0);
        rd_ex        : in std_logic_vector(4 downto 0);
        rd_mem       : in std_logic_vector(4 downto 0);
        reg_write_ex : in std_logic;
        reg_write_mem : in std_logic;
        rd_wb        : in std_logic_vector(4 downto 0);
        reg_write_wb : in std_logic;
        is_Imm       : in std_logic;
        is_store_id  : in std_logic;
        is_JALR_id   : in std_logic;
        mem_read_ex  : in std_logic;
        is_branch_id : in std_logic;
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
    signal branch_data_hazard : std_logic;
    signal stall_pipeline : std_logic;
    signal uses_rs2 : std_logic;

begin

    uses_rs2 <= '1' when (is_Imm = '0' or is_store_id = '1') else '0';

    -- 1. Load-Use Hazard (Standard)
    -- Stalls if ID instruction needs result of LW in EX
    load_use_hazard <= '1' when (mem_read_ex = '1' and rd_ex /= "00000" and 
                        ((rd_ex = rs1_id) or (rd_ex = rs2_id and uses_rs2 = '1'))) -- Gated rs2 check
                        else '0';

    -- 2. Branch Data Hazard
    -- Stalls if Branch in ID needs result from EX, MEM
    branch_data_hazard <= '1' when ( (is_branch_id = '1' or is_jalr_id = '1') and -- Check Trigger
                                     (
                                        -- Check Hazard with EX Stage (ALU Result not yet written)
                                        (reg_write_ex = '1' and rd_ex /= "00000" and 
                                        (rd_ex = rs1_id or (rd_ex = rs2_id and uses_rs2 = '1')))
                                        
                                        OR
                                        
                                        -- Check Hazard with MEM Stage (Memory/ALU result not yet written)
                                        (reg_write_mem = '1' and rd_mem /= "00000" and 
                                        (rd_mem = rs1_id or (rd_mem = rs2_id and uses_rs2 = '1')))
                                     )
                                   ) 
                          else '0';
    -- Combined Stall Signal
    stall_pipeline <= load_use_hazard OR branch_data_hazard;

    -- OUTPUTS
    
    -- Stall PC and IF/ID if any hazard is detected
    pc_write <= '0' when (stall_pipeline = '1') else '1';
    if_id_write <= '0' when (stall_pipeline = '1') else '1';

    -- Flush IF/ID only if branch is taken AND we are not stalling for data
    -- (If we are stalling, we must wait for data before deciding to flush)
    if_id_flush <= '1' when (branch_taken = '1' and branch_data_hazard = '0') else '0';

    -- Flush ID/EX (Insert Bubble) if:
    -- 1. Any Hazard requires us to stall (Load-Use OR Branch Data)
    id_ex_flush <= '1' when (stall_pipeline = '1') else '0';

    -- Never flush EX/MEM
    ex_mem_flush <= '0';

end architecture dataflow;