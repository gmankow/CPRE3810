# First part of the Lab 3 test program
#

# data section
.data
test_var: .word 0        # Define a valid word in memory

# code/instruction section
.text
addi  x1,  x0,  1        # Place 1  in x1
addi  x2,  x1,  2        # Place 2  in x2
lasw    x3,  test_var      # Load address of test_var into x3
sw    x2,  0(x3)
lw    x4,  0(x3)
addi  x4,  x0,  4        # Place 4  in x4
addi  x5,  x3,  5        # Place 5  in x5
addi  x6,  x0,  6        # Place 6  in x6
addi  x7,  x6,  7        # Place 7  in x7
addi  x8,  x7,  8        # Place 8  in x8
addi  x9,  x8,  9        # Place 9  in x9
addi  x10, x9,  10       # Place 10 in x10
wfi