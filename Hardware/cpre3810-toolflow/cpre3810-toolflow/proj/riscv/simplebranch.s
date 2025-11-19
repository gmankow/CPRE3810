main:
	ori s0, x0, 0x123
	j skip
	nop
	nop
	nop
	li s0, 0xffffffff
skip:
	ori s1, x0, 0x123
	nop
	nop
	nop
	beq s0, s1, skip2
	nop
	nop
	nop
	li s0, 0xffffffff
skip2:
	jal fun
	nop
	nop
	nop
	ori s3, x0, 0x123	
	beq s0, x0, exit
	nop
	nop
	nop
	ori s4, x0, 0x123
	j exit
	nop
	nop
	nop
fun:
	ori s2, x0, 0x123
	jr ra
	nop
	nop
	nop
exit:
	wfi

