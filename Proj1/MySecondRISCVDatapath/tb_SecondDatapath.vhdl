library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_SecondDatapath is 
    generic(gCLK_HPER   : time := 10 ns;
            DATA_WIDTH  : integer := 32);   -- Generic for half of the clock cycle period
end tb_SecondDatapath;

architecture mixed of tb_SecondDatapath is

    constant cCLK_PER  : time := gCLK_HPER * 2;

    component SecondDatapath is
        port(
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
    end component;

    signal s_Source1 : std_logic_vector(4 downto 0);
    signal s_Source2 : std_logic_vector(4 downto 0);
    signal s_WriteReg : std_logic_vector(4 downto 0);
    signal s_Imm : std_logic_vector(11 downto 0);
    signal s_RegWriteEn : std_logic;
    signal s_MemWriteEn : std_logic;
    signal s_ALUSrc : std_logic;
    signal s_nAdd_Sub : std_logic;
    signal s_MemToReg : std_logic;
    signal s_SignExt : std_logic;
    signal s_CLK, s_reset : std_logic;

    begin

        DUT: SecondDatapath
        port map(
            Source1 => s_Source1,
            Source2 => s_Source2,
            WriteReg => s_WriteReg,
            Imm => s_Imm,
            RegWriteEn => s_RegWriteEn,
            MemWriteEn => s_MemWriteEn,
            ALUSrc => s_ALUSrc,
            nAdd_Sub => s_nAdd_Sub,
            MemToReg => s_MemToReg,
            SignExt => s_SignExt,
            CLK => s_CLK,
            RST => s_reset
        );
    
     --This first process is to setup the clock for the test bench
    P_CLK: process
    begin
        s_CLK <= '1';         -- clock starts at 1
        wait for gCLK_HPER; -- after half a cycle
        s_CLK <= '0';         -- clock becomes a 0 (negative edge)
        wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
    end process;

    -- This process resets the sequential components of the design.
    -- It is held to be 1 across both the negative and positive edges of the clock
    -- so it works regardless of whether the design uses synchronous (pos or neg edge)
    -- or asynchronous resets.
    P_RST: process
    begin
        s_reset <= '0';   
        wait for gCLK_HPER/2;
        s_reset <= '1';
        wait for gCLK_HPER*2;
        s_reset <= '0';
        wait;
    end process;  
    
    -- Assign inputs for each test case.
    -- TODO: add test cases as needed.
    P_TEST_CASES: process
    begin
        wait for gCLK_HPER;
        wait for gCLK_HPER*3; -- wait a few cycles after reset

        -- REMEMBER to load HEX FILE FIRST

        -- addi x25, x25, 0
        s_Source1 <= "11001";
        s_Source2 <= "00000";
        s_WriteReg <= "11001";
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- addi x26, x26, 256
        s_Source1 <= "11010";
        s_Source2 <= "00000";
        s_WriteReg <= "11010";
        s_Imm <= x"100";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- lw x1, 0(x25)  -- load from address in x25 (0)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000";
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- lw x2, 4(x25)  -- load from address in x25 (4)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000";
        s_WriteReg <= "00010"; -- x2
        s_Imm <= x"004";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- add x1, x1, x2
        s_Source1 <= "00001"; -- x1
        s_Source2 <= "00010"; -- x2
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '0';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- sw x1, 0(x26)  -- store to address in x26 (256)
        s_Source1 <= "11010"; -- x26
        s_Source2 <= "00001"; -- x1 
        s_WriteReg <= "00000"; -- not used
        s_Imm <= x"000"; -- offset 0
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '1';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0'; -- not used
        s_SignExt <= '1';
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        -- lw x2, 8(x25) -- load from address in x25 (8)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000"; -- not used
        s_WriteReg <= "00010"; -- x2
        s_Imm <= x"008"; -- offset 8
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- add x1, x1, x2
        s_Source1 <= "00001"; -- x1
        s_Source2 <= "00010"; -- x2
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '0';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- sw x1, 4(x26)
        s_Source1 <= "11010"; -- x26
        s_Source2 <= "00001"; -- x1
        s_WriteReg <= "00000"; -- not used
        s_Imm <= x"004"; -- offset 4
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '1';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0'; -- not used
        s_SignExt <= '1';
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        -- lw x2, 12(x25)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000"; -- not used
        s_WriteReg <= "00010"; -- x2
        s_Imm <= x"00C"; -- offset 12
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- add x1, x1, x2
        s_Source1 <= "00001"; -- x1
        s_Source2 <= "00010"; -- x2
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '0';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- sw x1, 8(x26)
        s_Source1 <= "11010"; -- x26
        s_Source2 <= "00001"; -- x1
        s_WriteReg <= "00000"; -- not used
        s_Imm <= x"008"; -- offset 8
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '1';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0'; -- not used
        s_SignExt <= '1';
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        -- lw x2, 16(x25)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000"; -- not used
        s_WriteReg <= "00010"; -- x2
        s_Imm <= x"010"; -- offset 16
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- add x1, x1, x2
        s_Source1 <= "00001"; -- x1
        s_Source2 <= "00010"; -- x2
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '0';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- sw x1, 12(x26)
        s_Source1 <= "11010"; -- x26
        s_Source2 <= "00001"; -- x1
        s_WriteReg <= "00000"; -- not used
        s_Imm <= x"00C"; -- offset 12
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '1';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0'; -- not used
        s_SignExt <= '1';
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        -- lw x2, 12(x25)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000"; -- not used
        s_WriteReg <= "00010"; -- x2
        s_Imm <= x"00C"; -- offset 12
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- add x1, x1, x2
        s_Source1 <= "00001"; -- x1
        s_Source2 <= "00010"; -- x2
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '0';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- sw x1, 16(x26)
        s_Source1 <= "11010"; -- x26
        s_Source2 <= "00001"; -- x1
        s_WriteReg <= "00000"; -- not used
        s_Imm <= x"010"; -- offset 16
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '1';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0'; -- not used
        s_SignExt <= '1';
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        -- lw x2, 24(x25)
        s_Source1 <= "11001"; -- x25
        s_Source2 <= "00000"; -- not used
        s_WriteReg <= "00010"; -- x2
        s_Imm <= x"018"; -- offset 24
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '1';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- add x1, x1, x2
        s_Source1 <= "00001"; -- x1
        s_Source2 <= "00010"; -- x2
        s_WriteReg <= "00001"; -- x1
        s_Imm <= x"000";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '0';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- addi x27, x27, 512
        s_Source1 <= "11011";
        s_Source2 <= "00000";
        s_WriteReg <= "11011";
        s_Imm <= x"200";
        s_RegWriteEn <= '1';
        s_MemWriteEn <= '0';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0';
        s_SignExt <= '1';
        wait for gCLK_HPER*2;

        -- sw x1, -4(x27)
        s_Source1 <= "11011"; -- x27
        s_Source2 <= "00001"; -- x1
        s_WriteReg <= "00000"; -- not used
        s_Imm <= x"FFC"; -- offset -4
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '1';
        s_ALUSrc <= '1';
        s_nAdd_Sub <= '0';
        s_MemToReg <= '0'; -- not used
        s_SignExt <= '1';
        wait for gCLK_HPER*2;
        wait for gCLK_HPER*2;

        -- stop writing
        s_RegWriteEn <= '0';
        s_MemWriteEn <= '0';
        wait;


    end process;
end mixed;