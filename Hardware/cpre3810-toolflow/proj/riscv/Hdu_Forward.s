.data
results: .word 0 : 8        # Array to store 8 test results

.text
.globl main
main:
    # SETUP
    la   s11, results        # s11 holds base address of results (like s0 in your fibs)
    
    # Clear pipeline
    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 01: EX-to-EX Forwarding (Distance 1)
    addi t0, zero, 5         # Init t0 = 5
    addi t1, zero, 10        # Init t1 = 10
    add  t2, t0, t1          # t2 = 15 (In EX stage)
    add  t3, t2, t2          # t3 = 15 + 15 = 30 (DEPENDENCY)
    sw   t3, 0(s11)          # Store Result 1 in results[0]

    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 02: MEM-to-EX Forwarding (Distance 2)
    addi t0, zero, 2         # Init t0 = 2
    add  t1, t0, t0          # t1 = 4
    addi zero, zero, 0       # nop (t1 moves to MEM)
    add  t2, t1, t1          # t2 = 4 + 4 = 8 (DEPENDENCY)
    sw   t2, 4(s11)          # Store Result 2 in results[1]

    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 03: Load-Use Hazard (Stall)
    lw   t0, 4(s11)          # Load t0 from results[1] (Value 8)
    add  t1, t0, t0          # Use t0 immediately (Should Stall)
    sw   t1, 8(s11)          # Store Result 3 in results[2]

    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 04: Branch Data Hazard Stall (EX Dependency)
    addi t0, zero, 1         # Init
    sub  t1, t0, t0          # t1 = 0
    beq  t1, zero, pass_ex   # Branch reads t1 (Should Stall)

    # Fail path
    addi t2, zero, 0
    beq  zero, zero, end_t4

pass_ex:
    addi t2, zero, 1         # Success

end_t4:
    sw   t2, 12(s11)         # Store Result 4 in results[3]

    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 05: Branch Data Hazard Stall (MEM Dependency)
    addi t0, zero, 5         # Init
    sub  t1, t0, t0          # t1 = 0
    addi zero, zero, 0       # nop (Move to MEM)
    beq  t1, zero, pass_mem  # Branch reads t1 (Should Stall)

    # Fail path
    addi t2, zero, 0
    beq  zero, zero, end_t5

pass_mem:
    addi t2, zero, 1         # Success

end_t5:
    sw   t2, 16(s11)         # Store Result 5 in results[4]

    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 06: Double Data Hazard (Priority Check)
    addi t0, zero, 1
    addi t0, zero, 2
    addi t0, zero, 3
    add  t1, t0, t0          # Should use 3 (Youngest) -> 6
    sw   t1, 20(s11)         # Store Result 6 in results[5]

    addi zero, zero, 0       # nop
    addi zero, zero, 0       # nop

    # TEST 07: Store Data Forwarding
    addi t0, zero, 77
    addi t1, zero, 77
    add  t2, t0, t1          # t2 = 154
    sw   t2, 24(s11)         # Store t2 (Forwarding to Store Val)

    wfi                      # Halt