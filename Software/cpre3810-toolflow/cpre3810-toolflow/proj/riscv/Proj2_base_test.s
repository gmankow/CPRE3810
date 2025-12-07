# Project 1 Base Test Application (Software Scheduled)
# Modified for valid execution on a pipelined processor without forwarding unit.
# Rule: 2 NOPs required between register write and read (Data Hazard).
# Rule: 3 NOPs required after branches (None present in this code).

.data
val1:           .word   0x11223344
val2:           .word   0x55667788
storage_area:   .space  4

.text
.globl _start

_start:
    # --- Immediate and PC-Relative Instructions ---

    # LUI writes t0
    lui t0, 0xABCDE         

    # AUIPC writes t1 (Instruction 1 of delay for t0)
    auipc t1, 0x2          

    # HAZARD DETECTED: t0
    # Producer: lui (2 instr ago). Consumer: addi.
    # We have 'auipc' as 1 delay slot. We need 1 more NOP.
    nop

    # ADDI reads t0, writes t0
    addi t0, t0, 0x456      

    # HAZARD DETECTED: t0
    # Producer: addi (adjacent). Consumer: xori.
    # Need 2 NOPs.
    nop
    nop

    # XORI reads t0, writes t1
    xori t1, t0, 0x5A5      

    # HAZARD DETECTED: t1
    # Producer: xori (adjacent). Consumer: ori.
    # Need 2 NOPs.
    nop
    nop

    # ORI reads t1, writes t2
    ori t2, t1, 0x111      

    # HAZARD DETECTED: t2
    # Producer: ori (adjacent). Consumer: andi.
    # Need 2 NOPs.
    nop
    nop

    # ANDI reads t2, writes t3
    andi t3, t2, 0x70F      

    # --- Load and Store Instructions ---

    # LUI writes a0
    lui a0, %hi(val1)

    # HAZARD DETECTED: a0
    # Producer: lui (adjacent). Consumer: addi.
    # Need 2 NOPs.
    nop
    nop

    # ADDI reads a0, writes a0
    addi a0, a0, %lo(val1)

    # HAZARD DETECTED: a0
    # Producer: addi (adjacent). Consumer: lw.
    # Need 2 NOPs.
    nop
    nop

    # LW writes s0 (Reads a0 - safe)
    lw s0, 0(a0)            

    # LB writes s1 (Reads a0 - safe)
    lb s1, 0(a0)            

    # LBU writes s2 (Reads a0 - safe)
    lbu s2, 0(a0)           

    # LH writes s3 (Reads a0 - safe)
    lh s3, 0(a0)            

    # LHU writes s4 (Reads a0 - safe)
    lhu s4, 0(a0)           

    # LW writes s5 (Reads a0 - safe)
    lw s5, 4(a0)            

    # --- Register-Register Arithmetic and Logic ---

    # HAZARD DETECTED: s5
    # Producer: lw s5 (adjacent). Consumer: add (reads s5).
    # Note: s0 was loaded many lines ago, so s0 is safe. s5 is the hazard.
    # Need 2 NOPs.
    nop
    nop

    # ADD reads s0, s5. Writes t4.
    add t4, s0, s5          

    # SUB reads s5, s0. Writes t5.
    # Both s5 and s0 are safe (loaded >2 cycles ago).
    sub t5, s5, s0          

    # AND reads s0, s5. Writes s6. Safe.
    and s6, s0, s5          

    # OR reads s0, s5. Writes s7. Safe.
    or s7, s0, s5           

    # XOR reads s0, s5. Writes s8. Safe.
    xor s8, s0, s5          

    # HAZARD DETECTED: s8
    # Producer: xor (adjacent). Consumer: sw (reads s8).
    # Need 2 NOPs.
    nop
    nop

    # SW reads s8, a0. 
    sw s8, 8(a0)            

    # --- Shift Instructions ---

    # SLLI reads s0. Safe (s0 loaded long ago).
    slli s9, s0, 4          

    # SRLI reads s0. Safe.
    srli s10, s0, 8         

    # LUI writes t0
    lui t0, 0x80000         

    # HAZARD DETECTED: t0
    # Producer: lui (adjacent). Consumer: srai.
    # Need 2 NOPs.
    nop
    nop

    # SRAI reads t0. Writes s11.
    srai s11, t0, 4         

    # ADDI writes t1
    addi t1, zero, 2

    # HAZARD DETECTED: t1
    # Producer: addi (adjacent). Consumer: sll.
    # Need 2 NOPs.
    nop
    nop

    # SLL reads s0, t1. Writes t2.
    sll t2, s0, t1          

    # SRL reads s0, t1. Writes t3.
    # HAZARD CHECK: t1.
    # Producer: addi. Consumer: srl.
    # Sequence: addi -> (nop, nop) -> sll -> srl.
    # Distance is > 2. Safe.
    srl t3, s0, t1          

    # SRA reads t0, t1. Writes t4.
    # t0 written at lui (long ago). t1 written at addi (long ago). Safe.
    sra t4, t0, t1          


    # --- Comparison Instructions ---

    # SLT reads t0, s0. Safe.
    slt a1, t0, s0          

    # SLTI reads s0. Safe.
    slti a2, s0, 0          

    # SLTIU reads s0. Safe.
    sltiu a3, s0, 2047      

    # --- End of Program ---

    # WFI (Wait For Interrupt)
    wfi
