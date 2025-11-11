#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# 
# The expected output of this program is that the 1st 4 addresses of the data segment
# are [4,0,3,2]. should take ~2000 cycles in a single cycle procesor.
#

# Adapted to RISC-V by Connor J. Link (3.1.2025)
# Per testing [3, 0, 2, 1] is the expected output (matches the original grendel.s in MARS)

#
# Edited by Gemini to add 3-cycle branch delay nops and fix no-forwarding data hazards
#

.data
res:
	.word -1-1-1-1
nodes:
        .byte   97 # a
        .byte   98 # b
        .byte   99 # c
        .byte   100 # d
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
	.byte 0 0 0 0
res_idx:
        .word   3
.text
        # NEW RISCV                # ORIGINAL MIPS
	# li   sp, 0x10011000        # Manually expanded to fix hazard
	# Use hardcoded values for constants
	lui  sp, 0x10011
	nop
	nop
	addi sp, sp, 0
	li   fp, 0                 # li $fp, 0 (OK, expands to addi fp, x0, 0)
	# la   ra, pump              # Manually expanded to fix hazard
	# Use %hi() / %lo() for symbols
	lui  ra, %hi(pump)
	nop
	nop
	addi ra, ra, %lo(pump)
	j    main
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
pump:
        j end
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
	ebreak                     # halt


main:
        addi sp,    sp, -40        # addiu   $sp,$sp,-40
        nop                        # HAZARD FIX (addi sp / sw ... 36(sp))
        nop
        sw   ra, 36(sp)            # sw      $31,36($sp)
        sw   fp, 32(sp)            # sw      $fp,32($sp)
        add  fp,    sp, x0         # add     $fp,$sp,$zero
        sw   x0, 24(sp)            # sw      $0,24($fp)
        j    main_loop_control
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

main_loop_body:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        # la   ra,    trucks         # Manually expanded to fix hazard
        lui  ra, %hi(trucks)
        nop
        nop
        addi ra, ra, %lo(trucks)
        j    is_visited
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
trucks:

        xori t2,    t2, 1          # xori    $2,$2,0x1
        nop                        # HAZARD FIX (xori t2 / andi t2)
        nop

        lw   t4, 24(fp)            # lw      $4,24($fp)
                                   # ; addi    $k0, $k0,1# breakpoint
        # la   ra,    billowy        # Manually expanded to fix hazard
        lui  ra, %hi(billowy)
        nop
        nop
        addi ra, ra, %lo(billowy)
        j    topsort
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
billowy:

kick:
        lw   t2, 24(fp)            # lw      $2,24($fp)
        nop                        # HAZARD FIX (lw t2 / addi t2)
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop                        # HAZARD FIX (addi t2 / sw t2)
        nop
        sw   t2, 24(fp)            # sw      $2,24($fp)
main_loop_control:
        lw   t2, 24(fp)            # lw      $2,24($fp)
        nop                        # HAZARD FIX (lw t2 / slti t2)
        nop
        slti t2,    t2, 4          # slti    $2,$2, 4
        nop                        # HAZARD FIX (slti t2 / beq t2)
        nop
        beq  t2,    x0, hew        # beq     $2, $zero, hew # beq, j to simulate bne 
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        j    main_loop_body
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
hew:
        sw   x0, 28(fp)            # sw      $0,28($fp)
        j    welcome
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

wave:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        nop                        # HAZARD FIX (lw t2 / addi t2)
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop                        # HAZARD FIX (addi t2 / sw t2)
        nop
        sw   t2, 28(fp)            # sw      $2,28($fp)
welcome:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        nop                        # HAZARD FIX (lw t2 / slti t2)
        nop
        slti t2,    t2, 4          # slti    $2,$2,4
        nop                        # HAZARD FIX (slti t2 / xori t2)
        nop
        xori t2,    t2, 1          # xori    $2,$2,1 # xori 1, beq to simulate bne where val in [0,1]
        nop                        # HAZARD FIX (xori t2 / beq t2)
        nop
        beq  t2,    x0, wave       # beq     $2,$0,wave
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

        mv   t2,    x0             # move    $2,$0
        mv   sp,    fp             # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw ... 36(sp))
        nop
        lw   ra, 36(sp)            # lw      $31,36($sp)
        lw   fp, 32(sp)            # lw      $fp,32($sp)
        addi sp, sp, 40            # addiu   $sp,$sp,40
        nop                        # DATA HAZARD FIX (lw ra / jr ra - no forwarding)
        nop                        # DATA HAZARD FIX (lw ra / jr ra - no forwarding)
        jr   ra                    # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        
interest:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        # la   ra,    new            # la      $ra, new
        lui  ra, %hi(new)
        nop
        nop
        addi ra, ra, %lo(new)
        j    is_visited
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
new:
        xori t2,    t2, 1          # xori    $2,$2,0x1
        nop                        # HAZARD FIX (xori t2 / andi t2)
        nop

        lw   t4, 24(fp)            # lw      $4,24($fp)
        # la   ra,    partner        # la      $ra, partner
        lui  ra, %hi(partner)
        nop
        nop
        addi ra, ra, %lo(partner)
        j    topsort
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
partner:

tasteful:
        addi t2,    fp, 28         # addiu   $2,$fp,28
        nop                        # HAZARD FIX (addi t2 / mv t4)
        nop
        mv   t4,    t2             # move    $4,$2
        # la   ra,    badge          # la      $ra, badge
        lui  ra, %hi(badge)
        nop
        nop
        addi ra, ra, %lo(badge)
        j    next_edge
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
badge:
        sw   t2, 24(fp)            # sw      $2,24($fp)
        
turkey:
        lw   t3, 24(fp)            # lw      $3,24($fp)
        li   t2, -1                # li      $2,-1
        nop                        # HAZARD FIX (lw t3 / beq t3)
        nop                        # HAZARD FIX (li t2 / beq t2)
        beq  t3,    t2, telling    # beq     $3,$2,telling
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        j    interest
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
telling:
        # NOTE: $v0 === $2
	# la   t2,    res_idx        # Manually expanded to fix hazard
	lui  t2, %hi(res_idx)
	nop
	nop
	addi t2, t2, %lo(res_idx)
	nop                        # HAZARD FIX (la t2 / lw t2)
	nop
	lw   t2,  0(t2)            # lw      $v0, 0($v0)
        nop                        # HAZARD FIX (lw t2 / addi t4)
        nop
        addi t4,    t2, -1         # addiu   $4,$2,-1
        # la   t3,    res_idx        # Manually expanded to fix hazard
        lui  t3, %hi(res_idx)
        nop
        nop
        addi t3, t3, %lo(res_idx)
        nop                        # HAZARD FIX (addi t4 / sw t4)
        nop                        # HAZARD FIX (la t3 / sw... 0(t3))
        sw   t4,  0(t3)            # sw      $4, 0($3)
        # la   t4,    res            # Manually expanded to fix hazard
        lui  t4, %hi(res)
        nop
        nop
        addi t4, t4, %lo(res)
                                   # ; lui     $3,%hi(res_idx)
                                   # ; sw      $4,%lo(res_idx)($3)
                                   # ; lui     $4,%hi(res)
        slli t3,    t2, 2          # sll     $3,$2,2 (t2 is safe, 4 insts after lw t2)
        nop                        # HAZARD FIX (slli t3 / srli t3)
        nop
        srli t3,    t3, 1          # srl     $3,$3,1
        nop                        # HAZARD FIX (srli t3 / srai t3)
        nop
        srai t3,    t3, 1          # sra     $3,$3,1
        nop                        # HAZARD FIX (srai t3 / slli t3)
        nop
        slli t3,    t3, 2          # sll     $3,$3,2
       
       	xor  t6,    ra, t2         # xor     $at, $ra, $2 # does nothing 
        or   t6,    ra, t2         # nor     $at, $ra, $2 # does nothing 
        neg  t6,    t6
        
        # la   t2,    res            # Manually expanded to fix hazard
        lui  t2, %hi(res)
        nop
        nop
        addi t2, t2, %lo(res)
        li   a1,    0x0000ffff
        nop                        # HAZARD FIX (la t2 / and t6)
        nop                        # HAZARD FIX (li a1 / and t6)
        and  t6,    t2, a1         # andi    $at, $2, 0xffff
        nop                        # HAZARD FIX (la t4 / add t2)
        nop                        # HAZARD FIX (and t6 / add t2)
        add  t2,    t4, t6         # addu    $2, $4, $at (t4 is safe)
        nop                        # HAZARD FIX (slli t3 / add t2)
        nop                        # HAZARD FIX (add t2 / add t2)
        add  t2,    t3, t2         # addu    $2,$3,$2
        lw   t3, 48(fp)            # lw      $3,48($fp)
        nop                        # HAZARD FIX (add t2 / sw... 0(t2))
        nop                        # HAZARD FIX (lw t3 / sw t3)
        sw   t3,  0(t2)            # sw      $3,0($2)
        mv   sp,    fp             # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw... 44(sp))
        nop
        lw   ra, 44(sp)            # lw      $31,44($sp)
        lw   fp, 40(sp)            # lw      $fp,40($sp)
        addi sp,    sp, 48         # addiu   $sp,$sp,48
        nop                        # DATA HAZARD FIX (lw ra / jr ra - no forwarding)
        nop                        # DATA HAZARD FIX (lw ra / jr ra - no forwarding)
        jr   ra                    # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
   
topsort:
        addi sp,    sp, -48        # addiu   $sp,$sp,-48
        nop                        # HAZARD FIX (addi sp / sw... 44(sp))
        nop
        sw   ra, 44(sp)            # sw      $31,44($sp)
        sw   fp, 40(sp)            # sw      $fp,40($sp)
        mv   fp,    sp             # move    $fp,$sp
        nop                        # HAZARD FIX (mv fp / sw... 48(fp))
        nop
        sw   t4, 48(fp)            # sw      $4,48($fp)
        lw   t4, 48(fp)            # lw      $4,48($fp)
        # la   ra,    verse          # la      $ra, verse
        lui  ra, %hi(verse)
        nop
        nop
        addi ra, ra, %lo(verse)
        j    mark_visited
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
verse:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        lw   t5, 48(fp)            # lw      $5,48($fp)
        nop                        # HAZARD FIX (addi t2 / mv t4)
        nop
        mv   t4,    t2             # move    $4,$2
        # la   ra,    joyous         # la      $ra, joyous
        lui  ra, %hi(joyous)
        nop
        nop
        addi ra, ra, %lo(joyous)
        j    iterate_edges
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
joyous:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        nop                        # HAZARD FIX (addi t2 / mv t4)
        nop
        mv   t4,    t2             # move    $4,$2
        # la   ra,    whispering     # la      $ra, whispering
        lui  ra, %hi(whispering)
        nop
        nop
        addi ra, ra, %lo(whispering)
        j    next_edge
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
whispering:

        sw   t2, 24(fp)            # sw      $2,24($fp)
        j    turkey
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

iterate_edges:
        addi sp,    sp, -24        # addiu   $sp,$sp,-24
        nop                        # HAZARD FIX (addi sp / sw... 20(sp))
        nop
        sw   fp, 20(sp)            # sw      $fp,20($sp)
        mv   fp,    sp             # move    $fp,$sp
        nop                        # HAZARD FIX (mv fp / sub t6)
        nop
        sub  t6,    fp, sp         # subu    $at, $fp, $sp
        nop                        # HAZARD FIX (mv fp / sw... 24(fp))
        nop
        sw   t4, 24(fp)            # sw      $4,24($fp)
        sw   t5, 28(fp)            # sw      $5,28($fp)
        lw   t2, 28(fp)            # lw      $2,28($fp)
        nop                        # HAZARD FIX (lw t2 / sw t2)
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        lw   t2, 24(fp)            # lw      $2,24($fp)
        lw   t4,  8(fp)            # lw      $4,8($fp)
        lw   t3, 12(fp)            # lw      $3,12($fp)
        nop                        # HAZARD FIX (lw t2 / sw... 0(t2))
        nop
        sw   t4,  0(t2)            # sw      $4,0($2)
        sw   t3,  4(t2)            # sw      $3,4($2)
        lw   t2, 24(fp)            # lw      $2,24($fp)
        mv   sp,    fp             # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw... 20(sp))
        nop
        lw   fp, 20(sp)            # lw      $fp,20($sp)
        addi sp,    sp, 24         # addiu   $sp,$sp,24
        jr   ra                    # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        
next_edge:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        nop                        # HAZARD FIX (addi sp / sw... 28(sp))
        nop
        sw   ra, 28(sp)            # sw      $31,28($sp)
        sw   fp, 24(sp)            # sw      $fp,24($sp)
        add  fp,    x0, sp         # add     $fp,$zero,$sp
        nop                        # HAZARD FIX (add fp / sw... 32(fp))
        nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        j    waggish
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

snail:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t2 / lw t3)
        nop
        lw   t3,  0(t2)            # lw      $3,0($2)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t2 / lw t2)
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop                        # HAZARD FIX (lw t2 / mv t5)
        nop
        mv   t5,    t2             # move    $5,$2
        nop                        # HAZARD FIX (lw t3 / mv t4)
        nop
        mv   t4,    t3             # move    $4,$3
        # la   ra,    induce         # la      $ra,induce
        lui  ra, %hi(induce)
        nop
        nop
        addi ra, ra, %lo(induce)
        j    has_edge
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
induce:
        nop                        # HAZARD FIX (return from has_edge t2 / beq t2)
        nop
        beq  t2,    x0, quarter    # beq     $2,$0,quarter
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t2 / lw t2)
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop                        # HAZARD FIX (lw t2 / addi t4)
        nop
        addi t4,    t2, 1          # addiu   $4,$2,1
        lw   t3, 32(fp)            # lw      $3,32($fp)
        nop                        # HAZARD FIX (addi t4 / sw t4)
        nop
        sw   t4,  4(t3)            # sw      $4,4($3)
        j    cynical
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

quarter:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t2 / lw t2)
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop                        # HAZARD FIX (lw t2 / addi t3)
        nop
        addi t3,    t2, 1          # addiu   $3,$2,1
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (addi t3 / sw t3)
        nop
        sw   t3,  4(t2)            # sw      $3,4($2)

waggish:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t2 / lw t2)
        nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        nop                        # HAZARD FIX (lw t2 / slti t2)
        nop
        slti t2,    t2, 4          # slti    $2,$2,4
        nop                        # HAZARD FIX (slti t2 / beq t2)
        nop
        beq  t2,    x0, mark       # beq     $2,$zero,mark # beq, j to simulate bne 
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        j    snail
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
mark:
        li   t2, -1                # li      $2,-1

cynical:
        mv   sp,    fp             # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw... 28(sp))
        nop
        lw   ra, 28(sp)            # lw      $31,28($sp)
        lw   fp, 24(sp)            # lw      $fp,24($sp)
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        nop                        # DATA HAZARD FIX (lw ra / jr ra - no forwarding)
        nop                        # DATA HAZARD FIX (lw ra / jr ra - no forwarding)
        jr   ra                    # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
has_edge:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        nop                        # HAZARD FIX (addi sp / sw... 28(sp))
        nop
        sw   fp, 28(sp)            # sw      $fp,28($sp)
        mv   fp,    sp             # move    $fp,$sp
        nop                        # HAZARD FIX (mv fp / sw... 32(fp))
        nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        sw   t5, 36(fp)            # sw      $5,36($fp)
        # la   t2,    adjacencymatrix# Manually expanded to fix hazard
        lui  t2, %hi(adjacencymatrix)
        nop
        nop
        addi t2, t2, %lo(adjacencymatrix)
        lw   t3, 32(fp)            # lw      $3,32($fp)
        nop                        # HAZARD FIX (lw t3 / slli t3)
        nop
        slli t3,    t3, 2          # sll     $3,$3,2
        nop                        # HAZARD FIX (la t2 / add t2)
        nop                        # HAZARD FIX (slli t3 / add t2)
        add  t2,    t3, t2         # addu    $2,$3,$2
        nop                        # HAZARD FIX (add t2 / lw t2)
        nop
        lw   t2,  0(t2)            # lw      $2,0($2)
        nop                        # HAZARD FIX (lw t2 / sw t2)
        nop
        sw   t2, 16(fp)            # sw      $2,16($fp)
        li   t2,  1                # li      $2,1
        nop                        # HAZARD FIX (li t2 / sw t2)
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        j    measley
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

look:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        nop                        # HAZARD FIX (lw t2 / slli t2)
        nop
        slli t2,    t2, 1          # sll     $2,$2,1
        nop                        # HAZARD FIX (slli t2 / sw t2)
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        lw   t2, 12(fp)            # lw      $2,12($fp)
        nop                        # HAZARD FIX (lw t2 / addi t2)
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop                        # HAZARD FIX (addi t2 / sw t2)
        nop
        sw   t2, 12(fp)            # sw      $2,12($fp)
measley:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        lw   t2, 36(fp)            # lw      $2,36($fp)
        nop                        # HAZARD FIX (lw t3 / slt t2)
        nop                        # HAZARD FIX (lw t2 / slt t2)
        slt  t2,    t3, t2         # slt     $2,$3,$2
        nop                        # HAZARD FIX (slt t2 / beq t2)
        nop
        beq  t2,    x0, experience # beq     $2,$0,experience
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        j    look
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
experience:
        lw   t3,  8(fp)            # lw      $3,8($fp)
        lw   t2, 16(fp)            # lw      $2,16($fp)
        nop                        # HAZARD FIX (lw t3 / and t2)
        nop                        # HAZARD FIX (lw t2 / and t2)
        and  t2,    t3, t2         # and     $2,$3,$2
        nop                        # HAZARD FIX (and t2 / slt t2)
        nop
        slt  t2,    x0, t2         # slt     $2,$0,$2
        nop                        # HAZARD FIX (slt t2 / andi t2)
        nop
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        mv   sp,    fp             # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw... 28(sp))
        nop
        lw   fp, 28(sp)            # lw      $fp,28($sp)
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        jr   ra                    # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        
mark_visited:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        nop                        # HAZARD FIX (addi sp / sw... 28(sp))
        nop
        sw   fp, 28(sp)            # sw      $fp,28($sp)
        mv   fp,    sp             # move    $fp,$sp
        nop                        # HAZARD FIX (mv fp / sw... 32(fp))
        nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        li   t2,  1                # li      $2,1
        nop                        # HAZARD FIX (li t2 / sw t2)
        nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        j    recast

example:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        nop                        # HAZARD FIX (lw t2 / slli t2)
        nop
        nop                        # GEMINI: ADDED NOP FOR 3-NOP STALL
        slli t2,    t2, 8          # sll     $2,$2,8
        nop                        # HAZARD FIX (slli t2 / sw t2)
        nop
        nop                        # GEMINI: ADDED NOP FOR 3-NOP STALL
        sw   t2,  8(fp)            # sw      $2,8($fp)
        lw   t2, 12(fp)            # lw      $2,12($fp)
        nop                        # HAZARD FIX (lw t2 / addi t2)
        nop
        nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        nop                        # HAZARD FIX (addi t2 / sw t2)
        nop
        sw   t2, 12(fp)            # sw      $2,12($fp)
recast:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t3 / slt t2)
        nop                        # HAZARD FIX (lw t2 / slt t2)
        slt  t2,    t3, t2         # slt     $2,$3,$2
        nop                        # HAZARD FIX (slt t2 / beq t2)
        nop
        beq  t2,    x0, pat        # beq     $2,$zero,pat
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        j    example
pat:

       	# la   t2, visited             # Manually expanded to fix hazard
       	lui  t2, %hi(visited)
       	nop
       	nop
       	addi t2, t2, %lo(visited)
       	nop                        # HAZARD FIX (la t2 / sw t2)
       	nop
        sw   t2, 16(fp)              # sw      $2,16($fp)
        lw   t2, 16(fp)              # lw      $2,16($fp)
        nop                        # HAZARD FIX (lw t2 / lw t3)
        nop
        lw   t3,  0(t2)              # lw      $3,0($2)
        lw   t2,  8(fp)              # lw      $2,8($fp)
        nop                        # HAZARD FIX (lw t3 / or t3)
        nop                        # HAZARD FIX (lw t2 / or t3)
        or   t3,    t3, t2           # or      $3,$3,$2
        lw   t2, 16(fp)              # lw      $2,16($fp)
        nop                        # HAZARD FIX (or t3 / sw t3)
        nop
        sw   t3,  0(t2)              # sw      $3,0($2)
        mv   sp,    fp               # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw... 28(sp))
        nop
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        
is_visited:
        addi sp,    sp, -32          # addiu   $sp,$sp,-32
        nop                        # HAZARD FIX (addi sp / sw... 28(sp))
        nop
        sw   fp, 28(sp)              # sw      $fp,28($sp)
        mv   fp,    sp               # move    $fp,$sp
        nop                        # HAZARD FIX (mv fp / sw... 32(fp))
        nop
        sw   t4, 32(fp)              # sw      $4,32($fp)
        ori  t2,    x0, 1            # ori     $2,$zero,1
        nop                        # HAZARD FIX (ori t2 / sw t2)
        nop
        nop
        sw   t2,  8(fp)              # sw      $2,8($fp)
        sw   x0, 12(fp)              # sw      $0,12($fp)
        j    evasive
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

justify:
        lw   t2,  8(fp)              # lw      $2,8($fp)
        nop                        # HAZARD FIX (lw t2 / slli t2)
        nop
        nop                        # GEMINI: ADDED NOP FOR 3-NOP STALL
        slli t2,    t2, 8            # sll     $2,$2,8
        nop                        # HAZARD FIX (slli t2 / sw t2)
        nop
        nop                        # GEMINI: ADDED NOP FOR 3-NOP STALL
        sw   t2,  8(fp)              # sw      $2,8($fp)
        lw   t2, 12(fp)              # lw      $2,12($fp)
        nop                        # HAZARD FIX (lw t2 / addi t2)
        nop
        nop
        addi t2,    t2, 1            # addiu   $2,$2,1
        nop                        # HAZARD FIX (addi t2 / sw t2)
        nop
        nop
        sw   t2, 12(fp)              # sw      $2,12($fp)
evasive:
        lw   t3, 12(fp)              # lw      $3,12($fp)
        lw   t2, 32(fp)              # lw      $2,32($fp)
        nop                        # HAZARD FIX (lw t3 / slt t2)
        nop                        # HAZARD FIX (lw t2 / slt t2)
        slt  t2,    t3, t2           # slt     $2,$3,$2
        nop                        # HAZARD FIX (slt t2 / beq t2)
        nop
        beq  t2,    x0,representative# beq $2,$0,representitive
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        j    justify
representative:

        # la   t2,    visited          # la      $2,visited
        lui  t2, %hi(visited)
        nop
        nop
        addi t2, t2, %lo(visited)
        nop                        # HAZARD FIX (la t2 / lw t2)
        nop
        lw   t2,  0(t2)              # lw      $2,0($2)
        nop                        # HAZARD FIX (lw t2 / sw t2)
        nop
        sw   t2, 16(fp)              # sw      $2,16($fp)
        lw   t3, 16(fp)              # lw      $3,16($fp)
        lw   t2,  8(fp)              # lw      $2,8($fp)
        nop                        # HAZARD FIX (lw t3 / and t2)
        nop                        # HAZARD FIX (lw t2 / and t2)
        and  t2,    t3, t2           # and     $2,$3,$2
        nop                        # HAZARD FIX (and t2 / slt t2)
        nop
        slt  t2,    x0, t2           # slt     $2,$0,$2
        nop                        # HAZARD FIX (slt t2 / andi t2)
        nop
        andi t2,    t2, 0xff         # andi    $2,$2,0x00ff
        mv   sp,    fp               # move    $sp,$fp
        nop                        # HAZARD FIX (mv sp / lw... 28(sp))
        nop
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT
        nop                        # BRANCH DELAY SLOT

end:
        wfi
