.data
results: .word 0 : 8        # Array to store 8 test results
                            # [0]=JAL, [1]=JALR, [2]=BEQ, [3]=BNE, 
                            # [4]=NotTaken, [5]=Stall+Flush, [6]=Stress

.text
.globl main
main:
    # SETUP
    la   s11, results        # Base address for results
    addi t0, zero, 0         
    addi t1, zero, 0
    
    # Clear pipeline
    addi zero, zero, 0
    addi zero, zero, 0

    # TEST 01: JAL Flush (Unconditional Jump)
    # Scenario: JAL should flush the instruction immediately following it.
    
    addi t0, zero, 1         # Load "Pass" value
    sw   t0, 0(s11)          # Write "Pass" initially
    
    jal  x0, target_01       # Jump to target
    
    sw   zero, 0(s11)        # TRAP! If executed, overwrites Pass with 0 (Fail).
    
target_01:
    # If we get here without executing the trap, Test 01 Passed.
    addi zero, zero, 0       # Buffer
    addi zero, zero, 0       # Buffer

    # TEST 02: JALR Flush (Register Jump)
    # Scenario: JALR uses a register value to jump. Must flush 1 instr.
    
    la   t1, target_02       # Load address of target into t1
    addi t0, zero, 1         # Load "Pass" value
    sw   t0, 4(s11)          # Write "Pass" initially
    
    jalr x0, 0(t1)           # Jump to address in t1
    
    sw   zero, 4(s11)        # TRAP!

target_02:
    addi zero, zero, 0       # Buffer
    addi zero, zero, 0       # Buffer

    # TEST 03: BEQ Taken Flush (Conditional Branch)
    # Scenario: BEQ is taken. Must flush 1 instr.
    
    addi t0, zero, 1         # "Pass"
    sw   t0, 8(s11)          # Write "Pass"
    addi t1, zero, 5
    addi t2, zero, 5         # t1 == t2
    
    beq  t1, t2, target_03   # Taken Branch
    
    sw   zero, 8(s11)        # TRAP!

target_03:
    addi zero, zero, 0       # Buffer
    addi zero, zero, 0       # Buffer

    # TEST 04: BNE Taken Flush (Conditional Branch)
    # Scenario: BNE is taken. Must flush 1 instr.
    
    addi t0, zero, 1         # "Pass"
    sw   t0, 12(s11)         # Write "Pass"
    addi t1, zero, 5
    addi t2, zero, 9         # t1 != t2
    
    bne  t1, t2, target_04   # Taken Branch
    
    sw   zero, 12(s11)       # TRAP!

target_04:
    addi zero, zero, 0
    addi zero, zero, 0

    # TEST 05: Branch Not Taken (Prediction Check)
    # Scenario: Branch is NOT taken. Pipeline should continue normally.
    # We ensure the instruction following the branch IS executed.
    
    addi t0, zero, 0         # Init "Fail" (0)
    addi t1, zero, 5
    addi t2, zero, 9         # t1 != t2
    
    beq  t1, t2, fail_05     # Not Taken. Should fall through.
    
    addi t0, zero, 1         # Set "Pass" (1)
    
fail_05:
    sw   t0, 16(s11)         # Store Result (1 if fell through, 0 if taken)
    
    addi zero, zero, 0
    addi zero, zero, 0

    # TEST 06: JALR with Data Hazard (Stall THEN Flush)
    # Combined Hazard: JALR target depends on previous instruction.
    # 1. Hazard Unit must STALL JALR in ID (Data Hazard).
    # 2. Once data arrives, JALR executes and must FLUSH next instr (Control Hazard).
    
    la   t1, target_06       # Load Address
    addi t2, t1, 0           # Move to t2 (Data Dependency created)
    
    addi t0, zero, 1         # "Pass"
    sw   t0, 20(s11)         # Write "Pass"
    
    jalr x0, 0(t2)           # Uses t2 immediately. Stall -> Then Jump.
    
    sw   zero, 20(s11)       # TRAP!

target_06:
    addi zero, zero, 0
    addi zero, zero, 0

    # TEST 07: Back-to-Back Control (Stress Test)
    # Scenario: A taken branch jumps to... another taken branch.
    # Verifies the pipeline can handle rapid PC updates.
    
    addi t0, zero, 1         # "Pass"
    sw   t0, 24(s11)         # Write "Pass"
    
    beq  x0, x0, jump_1      # Unconditional BEQ (Taken)
    sw   zero, 24(s11)       # Trap 1
    
jump_1:
    beq  x0, x0, jump_2      # Immediately another Taken Branch
    sw   zero, 24(s11)       # Trap 2
    
jump_2:
    # If we get here, both flushes worked.
    addi zero, zero, 0
    
    addi a7, zero, 10
    wfi