	.text
	.file	"sharevalue.c"
	.globl	share_value
	.p2align	2
	.type	share_value,@function
share_value:
	addi	sp, sp, -32
  sw  s5, 36(sp)
  sw  s6, 32(sp)
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	sw	s1, 20(sp)
	sw	s2, 16(sp)
	sw	s3, 12(sp)
	sw	s4, 8(sp)
	blez	a2, .LBB0_5
	mv	s0, a2
	mv	s1, a1
	mv	s2, a0
	li	s3, 0
	li	s4, 42
	j	.LBB0_3
.LBB0_2:
	addi	s0, s0, -1
	addi	s1, s1, 4
	addi	s2, s2, 4
	beqz	s0, .LBB0_6
.LBB0_3:
	lw	a0, 0(s2)

	# Eliminate "bne	a0, s4, .LBB0_2" (Molnar's method)
  sub s5, a0, s4
  snez s5, s5
  andi s5, s5, 0xff
  neg s5, s5         # true mask
  not s6, s5         # false mask

  # Not live after sensitive region (temporary computations)
	li	a0, 42
	call	lookup_val
	lw	a1, 0(s1)
	mul	a0, a1, a0

  # Execute when branch condition evaluates to false
	# add	s3, a0, s3
  and t0, s3, s5
  add s3, a0, s3
  and s3, s3, s6
  or  s3, s3, t0

	j	.LBB0_2
.LBB0_5:
	li	s3, 0
.LBB0_6:
	mv	a0, s3
  lw  s5, 36(sp)
  lw  s6, 32(sp)
	lw	ra, 28(sp)
	lw	s0, 24(sp)
	lw	s1, 20(sp)
	lw	s2, 16(sp)
	lw	s3, 12(sp)
	lw	s4, 8(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	share_value, .Lfunc_end0-share_value

	.section	".note.GNU-stack","",@progbits
