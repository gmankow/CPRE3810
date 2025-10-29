# Simple RISC-V program to sum elements of an array.
# This file is intended for toolflow verification, not as a self-checking test.
# It demonstrates memory access, looping, and basic arithmetic.

.data
# The array of 32-bit integer values to be summed.
data_array:
    .word   10
    .word   20
    .word   30
    .word   40
    .word   50

# A label marking the end of the array to control the loop.
array_end:

# String for printing the result to the console.
result_str:
    .string "The sum is: "

.text
.globl main

# Program entry point
main:
    # --- Initialization ---
    # t0 will hold the current address (pointer) of the array element.
    # t1 will hold the address of the end of the array.
    # t2 will be the accumulator for the sum.
    
    la      t0, data_array      # Load address of the start of the array into t0.
    la      t1, array_end       # Load address of the end of the array into t1.
    li      t2, 0               # Initialize sum register t2 to zero.

# --- Main Loop ---
# Iterates through the array until the pointer reaches the end.
loop_start:
    # Check if the current address (t0) has reached the end address (t1).
    beq     t0, t1, loop_end    # If t0 == t1, branch to the end of the loop.

    # --- Loop Body ---
    lw      t3, 0(t0)           # Load the 4-byte word from the address in t0 into t3.
    add     t2, t2, t3          # Add the loaded value (t3) to the sum (t2).
    addi    t0, t0, 4           # Increment the address pointer by 4 bytes to the next word.
    
    j       loop_start          # Unconditionally jump back to the start of the loop.

# --- Finalization ---
# Prepares and prints the result, then exits.
loop_end:
    # The final sum is now stored in register t2.
    # The following section uses RARS syscalls to print the result.
    
    # Print the result string.
    wfi
