	.text
	.file	"bsl.c"
	.globl	BSL430_unlock_BSL
	.p2align	2
	.type	BSL430_unlock_BSL,@function
BSL430_unlock_BSL:
	li	a1, 0
	li	a2, 0
	lui	a3, %hi(.L.str)
	addi	a3, a3, %lo(.L.str)
	li	a4, 17
.LBB0_1:
	add	a5, a2, a3
	lbu	a5, 0(a5)
	add	a6, a0, a2
	lbu	a6, 0(a6)

  # Elminate "beq	a5, a6, .LBB0_3" (Molnar)
  sub t0, a5, a6
  snez t0, t0
  andi t0, t0, 0xff
  neg  t0, t0   # true mask
  not  t1, t0   # false mask
  # ori	a1, a1, 64
  and t2, a1, t1
  ori	a1, a1, 64
  and a1, a1, t0
  or  a1, a1, t2

	addi	a2, a2, 1
	bne	a2, a4, .LBB0_1
	li	a0, 0
	beqz	a1, .LBB0_6
	li	a0, 5
.LBB0_6:
	ret
.Lfunc_end0:
	.size	BSL430_unlock_BSL, .Lfunc_end0-BSL430_unlock_BSL

	.type	.L.str,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"0123456789ABCDEF"
	.size	.L.str, 17

	.section	".note.GNU-stack","",@progbits
