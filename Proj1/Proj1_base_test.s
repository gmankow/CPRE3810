# Project 1 Base Test Application
# This code demonstrates the sequential execution of arithmetic and logical instructions.
# It is designed to show that data written into registers can be effectively retrieved and used
# by subsequent instructions, without using any control flow.

.data
# Define some data in memory to use with load/store instructions.
val1:           .word   0x11223344      # A 32-bit word for loading
val2:           .word   0x55667788      # Another 32-bit word
storage_area:   .space  4               # Reserve 4 bytes to store a result

.text
.globl _start

_start:
    # --- Immediate and PC-Relative Instructions ---

    # LUI (Load Upper Immediate): Load 0xABCDE into the upper 20 bits of t0.
    lui t0, 0xABCDE         # t0 = 0xABCDE000

    # AUIPC (Add Upper Immediate to PC): Add an offset to the current PC.
    # Useful for position-independent code.
    auipc t1, 0x2          # t1 = pc + 0x2000

    # ADDI (Add Immediate): Add a 12-bit immediate to a register.
    addi t0, t0, 0x456      # t0 = 0xABCDE000 + 0x456 = 0xABCDE456

    # XORI (XOR Immediate): XOR a register with a 12-bit immediate.
    xori t1, t0, 0x5A5      # t1 = t0 ^ 0x5A5 = 0xABCDE1F3

    # ORI (OR Immediate): OR a register with a 12-bit immediate.
    ori t2, t1, 0x111      # t2 = t1 | 0x111 = 0xABCDE1F3

    # ANDI (AND Immediate): AND a register with a 12-bit immediate.
    andi t3, t2, 0x70F      # t3 = t2 & 0x70F = 0x00000103

    # --- Load and Store Instructions ---

    # Get the base address of our data section into a register (a0).
    lui a0, %hi(val1)
    addi a0, a0, %lo(val1)

    # LW (Load Word): Load the 32-bit value from 'val1' into s0.
    lw s0, 0(a0)            # s0 = 0x11223344

    # LB (Load Byte): Load the byte 0x44 (from val1) into s1 and sign-extend it.
    lb s1, 0(a0)            # s1 = 0x00000044 (since 0x44 is not negative)

    # LBU (Load Byte Unsigned): Load the byte 0x44 into s2 and zero-extend it.
    lbu s2, 0(a0)           # s2 = 0x00000044

    # LH (Load Half-word): Load 0x3344 from val1 into s3 and sign-extend it.
    lh s3, 0(a0)            # s3 = 0x00003344 (since 0x3344 is not negative)

    # LHU (Load Half-word Unsigned): Load 0x3344 into s4 and zero-extend it.
    lhu s4, 0(a0)           # s4 = 0x00003344

    # Load the second value for register-register operations.
    lw s5, 4(a0)            # s5 = 0x55667788

    # --- Register-Register Arithmetic and Logic ---

    # ADD (Add): Add two registers.
    add t4, s0, s5          # t4 = s0 + s5 = 0x6688AACC

    # SUB (Subtract): Subtract one register from another.
    sub t5, s5, s0          # t5 = s5 - s0 = 0x44444444

    # AND (AND): Bitwise AND of two registers.
    and s6, s0, s5          # s6 = 0x11223344 & 0x55667788 = 0x11223300

    # OR (OR): Bitwise OR of two registers.
    or s7, s0, s5           # s7 = 0x11223344 | 0x55667788 = 0x556677CC

    # XOR (XOR): Bitwise XOR of two registers.
    xor s8, s0, s5          # s8 = 0x11223344 ^ 0x55667788 = 0x444444CC

    # SW (Store Word): Store the result of the XOR operation into 'storage_area'.
    sw s8, 8(a0)            # Memory at storage_area = s8

    # --- Shift Instructions ---

    # SLLI (Shift Left Logical Immediate): Shift left by a constant.
    slli s9, s0, 4          # s9 = s0 << 4 = 0x12233440

    # SRLI (Shift Right Logical Immediate): Shift right logical by a constant.
    srli s10, s0, 8         # s10 = s0 >> 8 = 0x00112233

    # SRAI (Shift Right Arithmetic Immediate): Shift right arithmetic by a constant.
    lui t0, 0x80000         # t0 = 0x80000000 (a negative number)
    srai s11, t0, 4         # s11 = t0 >> 4 = 0xF8000000 (preserves sign)

    # Use a register for shift amounts.
    addi t1, zero, 2

    # SLL (Shift Left Logical): Shift left by a variable amount.
    sll t2, s0, t1          # t2 = s0 << 2 = 0x4488CC10

    # SRL (Shift Right Logical): Shift right logical by a variable amount.
    srl t3, s0, t1          # t3 = s0 >> 2 = 0x04488CC1

    # SRA (Shift Right Arithmetic): Shift right arithmetic by a variable amount.
    sra t4, t0, t1          # t4 = t0 >> 2 = 0xE0000000 (preserves sign)


    # --- Comparison Instructions ---

    # SLT (Set Less Than): Signed comparison between registers.
    slt a1, t0, s0          # a1 = (t0 < s0) ? 1 : 0. (-2^31 < 0x11223344) -> 1

    # SLTI (Set Less Than Immediate): Signed comparison with an immediate.
    slti a2, s0, 0          # a2 = (s0 < 0) ? 1 : 0 -> 0

    # SLTIU (Set Less Than Immediate Unsigned): Unsigned comparison.
    # 0x11223344 is much larger than 2047.
    sltiu a3, s0, 2047      # a3 = (s0 < 2047) (unsigned)? -> 0

    # --- End of Program ---

    # WFI (Wait For Interrupt): Halt the processor in a simulation environment.
    wfi

