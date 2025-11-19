# RISC-V Assembly Implementation of Merge Sort
# Blane F

.data
array:      .word   38, 27, 43, 3, 9, 82, 10, -5
array_size: .word   8

.text
.global main

main:
    # Load array address and size
    lasw a0, array
    lw a1, array_size

    # Call merge_sort(array, array_size)
    jal ra, merge_sort

    # Exit program
    li a7, 10         # ecall: exit
    ecall

# -----------------------------------------------------------------------------
# merge_sort(a0: base_address, a1: n)
# Sorts an array of 'n' integers.
# -----------------------------------------------------------------------------
merge_sort:
    # Stack frame layout:
    # -8(sp): ra (Return Address)
    # -12(sp): s0 (base_address)
    # -16(sp): s1 (n)
    # -20(sp): s2 (n1, size of left array)
    # Total stack space = 20 bytes (must be 16-byte aligned, so we use 32)

    # Check base case: if (n <= 1), return
    li t0, 1
    nop
    nop
    nop
    ble a1, t0, ms_return

    
    addi sp, sp, -32
    sw ra, 28(sp)     # Save return address
    sw s0, 24(sp)     # Save s0 (base_address)
    sw s1, 20(sp)     # Save s1 (n)
    sw s2, 16(sp)     # Save s2 (n1)

    # Save arguments
    nop
    mv s0, a0         # s0 = base_address
    mv s1, a1         # s1 = n

    # --- Divide ---
    # Calculate middle point (n1 = n / 2)
    srai s2, s1, 1    # s2 = n1 = n >> 1

    # Recursive call for left
    # merge_sort(base_address, n1)
    nop
    mv a0, s0
    nop
    mv a1, s2
    jal ra, merge_sort

    # Recursive call for right
    # Calculate n2 (size of right array) = n - n1
    sub t0, s1, s2    # t0 = n2
    # Calculate base_address_right = base_address + (n1 * 4)
    slli t1, s2, 2    # t1 = n1 * 4 (byte offset)
    nop
    nop
    nop
    add t2, s0, t1    # t2 = base_address_right

    # merge_sort(base_address_right, n2)
    nop
    nop
    nop
    mv a0, t2
    mv a1, t0
    jal ra, merge_sort

    # --- Allocate L and R on the stack ---
    # We need n1 * 4 bytes for L and n2 * 4 bytes for R.
    # Total bytes = (n1 + n2) * 4 = n * 4
    slli t0, s1, 2    # t0 = n * 4
    nop
    nop
    nop
    sub sp, sp, t0    # Allocate space on stack
    nop
    nop
    nop
    mv t1, sp         # t1 = base address of L
    slli t2, s2, 2    # t2 = n1 * 4 (size of L in bytes)
    nop
    nop
    nop
    add t3, t1, t2    # t3 = base address of R

    # --- Copy data to L and R ---
    # Copy L array: for(i=0; i < n1; i++) L[i] = A[i]
    li t4, 0          # i = 0
copy_L_loop:
    nop
    nop
    nop
    bge t4, s2, end_copy_L_loop
    nop
    nop
    nop
    slli t5, t4, 2    # t5 = i * 4
    nop
    nop
    nop
    add t6, s0, t5    # t6 = &A[i]
    nop
    nop
    nop
    lw a0, 0(t6)      # a0 = A[i]
    add t6, t1, t5    # t6 = &L[i]
    nop
    nop
    nop
    sw a0, 0(t6)      # L[i] = A[i]
    addi t4, t4, 1
    nop
    nop
    j copy_L_loop
    nop
    nop
    nop
end_copy_L_loop:

    # Copy R array: for(j=0; j < n2; j++) R[j] = A[n1 + j]
    sub t0, s1, s2    # t0 = n2
    li t4, 0          # j = 0
copy_R_loop:
    bge t4, t0, end_copy_R_loop
    nop
    nop
    nop
    add t5, s2, t4    # t5 = n1 + j
    nop
    nop
    nop
    slli t5, t5, 2    # t5 = (n1 + j) * 4
    nop
    nop
    nop
    add t6, s0, t5    # t6 = &A[n1 + j]
    nop
    nop
    nop
    lw a0, 0(t6)      # a0 = A[n1 + j]
    slli t5, t4, 2    # t5 = j * 4
    nop
    nop
    nop
    add t6, t3, t5    # t6 = &R[j]
    nop
    nop
    nop
    sw a0, 0(t6)      # R[j] = A[n1 + j]
    addi t4, t4, 1
    j copy_R_loop
    nop
    nop
    nop
end_copy_R_loop:

    # Call merge(A, L, R, n1, n2)
    mv a0, s0         # a0 = A (original array)
    mv a1, t1         # a1 = L
    mv a2, t3         # a2 = R
    mv a3, s2         # a3 = n1
    sub a4, s1, s2    # a4 = n2
    jal ra, merge

    # Deallocate temporary arrays
    slli t0, s1, 2    # t0 = n * 4
    nop
    nop
    nop
    add sp, sp, t0    # Free stack space
    nop
    nop
    nop

    
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    addi sp, sp, 32

ms_return:
    jalr zero, 0(ra)  # return


merge:
    # We will use s-registers, so we must save them.
    # s0 = A (base address of original array)
    # s3 = L (base address of left temp array)
    # s4 = R (base address of right temp array)
    # s2 = n1 (size of L)
    # a4 = n2 (size of R) - (re-using a4, no need to save)
    # s5 = i (index for L)
    # s6 = j (index for R)
    # s7 = k (index for A)

    # --- Prologue ---
    addi sp, sp, -32
    nop
    nop
    nop
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s2, 20(sp)
    sw s3, 16(sp)
    sw s4, 12(sp)
    sw s5, 8(sp)
    sw s6, 4(sp)
    sw s7, 0(sp)

    # Save arguments
    mv s0, a0         # s0 = A
    mv s3, a1         # s3 = L
    mv s4, a2         # s4 = R
    mv s2, a3         # s2 = n1

    # Initialize counters
    li s5, 0          # i = 0
    li s6, 0          # j = 0
    li s7, 0          # k = 0

merge_loop:
    # while (i < n1 && j < n2)
    bge s5, s2, copy_R_remains  # if i >= n1, goto copy_R
    nop
    nop
    nop
    bge s6, a4, copy_L_remains  # if j >= n2, goto copy_L

    # Load L[i] and R[j]
    slli t0, s5, 2    # t0 = i * 4
    nop
    nop
    nop
    add t1, s3, t0    # t1 = &L[i]
    nop
    nop
    nop
    lw t2, 0(t1)      # t2 = L[i]

    slli t0, s6, 2    # t0 = j * 4
    nop
    nop
    nop
    add t1, s4, t0    # t1 = &R[j]
    nop
    nop
    nop
    lw t3, 0(t1)      # t3 = R[j]
    nop
    nop
    nop

    # if (L[i] <= R[j])
    bgt t2, t3, else_merge
    # if_true: A[k] = L[i], i++
    slli t0, s7, 2    # t0 = k * 4
    nop
    nop
    nop
    add t1, s0, t0    # t1 = &A[k]
    nop
    nop
    nop
    sw t2, 0(t1)      # A[k] = L[i]
    addi s5, s5, 1    # i++
    j end_if_merge
    nop
    nop
    nop

else_merge:
    # else: A[k] = R[j], j++
    slli t0, s7, 2    # t0 = k * 4
    nop
    nop
    nop
    add t1, s0, t0    # t1 = &A[k]
    nop
    nop
    nop
    sw t3, 0(t1)      # A[k] = R[j]
    addi s6, s6, 1    # j++

end_if_merge:
    # k++
    addi s7, s7, 1
    j merge_loop
    nop
    nop
    nop

copy_L_remains:
    # while (i < n1)
    bge s5, s2, merge_end
    nop
    nop
    nop
    # A[k] = L[i]
    slli t0, s5, 2
    nop
    nop
    nop
    add t1, s3, t0
    nop
    nop
    nop
    lw t2, 0(t1)      # t2 = L[i]
    slli t0, s7, 2
    nop
    nop
    nop
    add t1, s0, t0
    nop
    nop
    nop
    sw t2, 0(t1)      # A[k] = L[i]
    # i++, k++
    addi s5, s5, 1
    addi s7, s7, 1
    j copy_L_remains
    nop
    nop
    nop

copy_R_remains:
    # while (j < n2)
    bge s6, a4, merge_end
    nop
    nop
    nop
    # A[k] = R[j]
    slli t0, s6, 2
    nop
    nop
    nop
    add t1, s4, t0
    nop
    nop
    nop
    lw t3, 0(t1)      # t3 = R[j]
    slli t0, s7, 2
    nop
    nop
    nop
    add t1, s0, t0
    nop
    nop
    nop
    sw t3, 0(t1)      # A[k] = R[j]
    # j++, k++
    addi s6, s6, 1
    addi s7, s7, 1
    j copy_R_remains
    nop
    nop
    nop

merge_end:
    # --- Epilogue ---
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s2, 20(sp)
    lw s3, 16(sp)
    lw s4, 12(sp)
    lw s5, 8(sp)
    lw s6, 4(sp)
    lw s7, 0(sp)
    addi sp, sp, 32

    jalr zero, 0(ra)  # return


