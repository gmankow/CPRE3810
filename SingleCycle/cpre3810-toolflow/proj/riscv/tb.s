# First part of the Lab 3 test program
#

# data section
.data
test_var: .word 0        # Define a valid word in memory

# code/instruction section
.text
li t0, 1000

looper:
    bne t0,x0, hop_1
hop_2:
    addi t0, t0, -1
    bne t0, x0, looper
    j end
hop_1:
    bne t0, x0, hop_2
end:
    wfi
