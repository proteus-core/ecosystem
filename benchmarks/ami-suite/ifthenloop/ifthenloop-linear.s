	.text
	.file	"ifthenloop.c"
	.globl	ifthenloop
	.p2align	2
	.type	ifthenloop,@function
ifthenloop:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	sw	s1, 4(sp)
	lui	s0, %hi(v)
	sw	zero, %lo(v)(s0)
	# Eliminate "blt	a2, a1, .LBB0_2" (Molnar's method)
  slt a2, a1, a0
  andi a2, a2, 0xff
  neg a2, a2     # true mask  (used in foo)
  not a3, a2     # false mask (used in foo)

	addi	s1, x0, 3
.LBB0_2:
	call	foo
	addi	s1, s1, -1
	bnez	s1, .LBB0_2
.LBB0_3:
	lw	a0, %lo(v)(s0)
	lw	ra, 12(sp)
	lw	s0, 8(sp)
	lw	s1, 4(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	ifthenloop, .Lfunc_end0-ifthenloop

	.p2align	2
	.type	foo,@function
foo:
	lui	a0, %hi(v)
	lw	a1, %lo(v)(a0)

  # addi	a1, a1, 1
  and  t0, a1, a2
  addi a1, a1, 1
  and  a1, a1, a3
  or   a1, a1, t0

	sw	a1, %lo(v)(a0)
	ret
.Lfunc_end1:
	.size	foo, .Lfunc_end1-foo

  # ori	a1, a1, 64
  and t2, a1, t1
  ori	a1, a1, 64
  and a1, a1, t0
  or  a1, a1, t2

	.type	v,@object
	.section	.sbss,"aw",@nobits
	.p2align	2
v:
	.word	0
	.size	v, 4

	.section	".note.GNU-stack","",@progbits
