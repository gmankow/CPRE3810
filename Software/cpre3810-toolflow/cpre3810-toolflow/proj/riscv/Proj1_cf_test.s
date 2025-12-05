# Project 1 Control Flow Test (Software Scheduled)
# Modified to handle data hazards and control flow delays.

.data

.text
.globl main


main:
# Make space for one value (the final result) and the return address.
# The stack pointer (sp) is already initialized by the system.
addi sp, sp, -8

# HAZARD: sp written by addi, used by sw. Adjacent -> 2 NOPs.
nop
nop
sw ra, 4(sp)        # Save return address (though not critical for main)

# Load an initial argument for the function chain.
li a0, 5

# Call func1 (jal)
jal func1
# CONTROL HAZARD: 3 NOPs after jump
nop
nop
nop

# After returning from func1, the final result is in a0.
# Store the final result (82) at the base of our stack frame.
sw a0, 0(sp)

# Standard program exit
# Restore stack pointer (optional, but good practice)
lw ra, 4(sp)
addi sp, sp, 8

# Exit ecall
li a7, 10
# HAZARD: a7 written by li, used by ecall. Adjacent -> 2 NOPs.
nop
nop
ecall


# -----------------------------------------------------------------
# func1: (5) -> 5 + func2(6) = 5 + 77 = 82
# -----------------------------------------------------------------
func1:
addi sp, sp, -8     # 1. Make stack space (for ra, s0)
# HAZARD: sp written by addi, used by sw. Adjacent -> 2 NOPs.
nop
nop
sw ra, 4(sp)        # 2. Save return address
# Note: 'sw s0' uses sp, but the NOPs above + 'sw ra' make it safe.
sw s0, 0(sp)        # 3. Save callee-saved register s0

mv s0, a0           # s0 = 5 (our argument)
addi a0, a0, 1      # a0 = 6 (new argument for func2)

# Call func2 (jal)
jal func2
# CONTROL HAZARD: 3 NOPs after jump
nop
nop
nop
# Returns with a0 = 77

add s0, s0, a0      # s0 = 5 + 77 = 82

# HAZARD: s0 written by add, used by mv. Adjacent -> 2 NOPs.
nop
nop
mv a0, s0           # Set return value a0 = 82

lw s0, 0(sp)        # 4. Restore s0
lw ra, 4(sp)        # 5. Restore ra
addi sp, sp, 8      # 6. Clean up stack

# Return (jalr x0, ra, 0)
# HAZARD: ra written by lw, used by jr. 1 instruction gap (addi) -> 1 NOP needed.
nop
jr ra
# CONTROL HAZARD: 3 NOPs after jump
nop
nop
nop


# -----------------------------------------------------------------
# func2: (6) -> 6 + func3(8) = 6 + 71 = 77
# -----------------------------------------------------------------
func2:
addi sp, sp, -8     # 1. Make stack space (for ra, s0)
# HAZARD: sp written by addi, used by sw. Adjacent -> 2 NOPs.
nop
nop
sw ra, 4(sp)        # 2. Save return address
sw s0, 0(sp)        # 3. Save callee-saved register s0

mv s0, a0           # s0 = 6 (our argument)
addi a0, a0, 2      # a0 = 8 (new argument for func3)

# Call func3 (jal)
jal func3
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
# Returns with a0 = 71

add s0, s0, a0      # s0 = 6 + 71 = 77
# HAZARD: s0 written by add, used by mv. Adjacent -> 2 NOPs.
nop
nop
mv a0, s0           # Set return value a0 = 77

lw s0, 0(sp)        # 4. Restore s0
lw ra, 4(sp)        # 5. Restore ra
addi sp, sp, 8      # 6. Clean up stack

# Return (jalr)
# HAZARD: ra written by lw (gap 1) -> 1 NOP.
nop
jr ra
# CONTROL HAZARD: 3 NOPs
nop
nop
nop

# -----------------------------------------------------------------
# func3: (8) -> 8 + func4(11) = 8 + 63 = 71
# -----------------------------------------------------------------
func3:
addi sp, sp, -8     # 1. Make stack space (for ra, s0)
# HAZARD: sp written by addi, used by sw. Adjacent -> 2 NOPs.
nop
nop
sw ra, 4(sp)        # 2. Save return address
sw s0, 0(sp)        # 3. Save callee-saved register s0

mv s0, a0           # s0 = 8 (our argument)
addi a0, a0, 3      # a0 = 11 (new argument for func4)

# Call func4 (jal)
jal func4
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
# Returns with a0 = 63

add s0, s0, a0      # s0 = 8 + 63 = 71
# HAZARD: s0 written by add, used by mv. Adjacent -> 2 NOPs.
nop
nop
mv a0, s0           # Set return value a0 = 71

lw s0, 0(sp)        # 4. Restore s0
lw ra, 4(sp)        # 5. Restore ra
addi sp, sp, 8      # 6. Clean up stack

# Return (jalr)
# HAZARD: ra written by lw (gap 1) -> 1 NOP.
nop
jr ra
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


# -----------------------------------------------------------------
# func4: (11) -> 63 (from branch tests)
# -----------------------------------------------------------------
func4:
# t0 will hold the result. Start at 0.
li t0, 0

# Test values
li t1, 11           # For beq
li t2, 20           # For bne/blt
li t3, -5           # For bge (signed)
li t4, 0xFFFFFFFF   # -1 (unsigned max)
li t5, 1            # 1

# All branches are designed to be TAKEN.
# The final result in t0 should be 1+2+4+8+16+32 = 63.

# 1. BEQ (Branch if Equal): 11 == 11
beq a0, t1, beq_ok
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
j beq_fail          # This line should be skipped
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


beq_ok:
addi t0, t0, 1      # t0 = 1
beq_fail:

# 2. BNE (Branch if Not Equal): 11 != 20
bne a0, t2, bne_ok
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
j bne_fail          # This line should be skipped
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


bne_ok:
addi t0, t0, 2      # t0 = 1 + 2 = 3
bne_fail:

# 3. BLT (Branch if Less Than, Signed): 11 < 20
blt a0, t2, blt_ok
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
j blt_fail          # This line should be skipped
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


blt_ok:
addi t0, t0, 4      # t0 = 3 + 4 = 7
blt_fail:

# 4. BGE (Branch if Greater/Equal, Signed): 11 >= -5
bge a0, t3, bge_ok
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
j bge_fail          # This line should be skipped
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


bge_ok:
addi t0, t0, 8      # t0 = 7 + 8 = 15
bge_fail:

# 5. BLTU (Branch if Less Than, Unsigned): 1 < 0xFFFFFFFF
bltu t5, t4, bltu_ok
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
j bltu_fail         # This line should be skipped
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


bltu_ok:
addi t0, t0, 16     # t0 = 15 + 16 = 31
bltu_fail:

# 6. BGEU (Branch if Greater/Equal, Unsigned): 0xFFFFFFFF >= 1
bgeu t4, t5, bgeu_ok
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
j bgeu_fail         # This line should be skipped
# CONTROL HAZARD: 3 NOPs
nop
nop
nop


bgeu_ok:
addi t0, t0, 32     # t0 = 31 + 32 = 63
bgeu_fail:

# Move the final result (63) into the return register a0
# HAZARD: t0 written by addi (fallthrough), used by mv. Adjacent -> 2 NOPs.
nop
nop
mv a0, t0

# Return (jalr)
jr ra
# CONTROL HAZARD: 3 NOPs
nop
nop
nop
