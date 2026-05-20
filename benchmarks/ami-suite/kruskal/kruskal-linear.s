	.text
	.file	"kruskal_s.c"
	.globl	kruskal
	.p2align	2
	.type	kruskal,@function
kruskal:
	li	a4, 0
	blez	a3, .LBB0_14
	li	a5, -1
	mv	a6, a1
	mv	a7, a2
.LBB0_2:
	sw	a5, 0(a6)
	sw	a4, 0(a7)
	addi	a4, a4, 1
	addi	a7, a7, 4
	addi	a6, a6, 4
	bne	a3, a4, .LBB0_2
	li	a4, 2
	blt	a3, a4, .LBB0_13
	li	a4, 0
	li	a5, 1
	j	.LBB0_7
.LBB0_6:
	add	a6, a1, a6
	sw	a7, 0(a6)
	add	a6, a1, t0
	addi	a5, a5, 2
	sw	t1, 0(a6)
	bge	a5, a3, .LBB0_14
.LBB0_7:
	slli	a6, a5, 2
	add	a7, a0, a6
	lw	t0, 0(a7)
.LBB0_8:
	mv	a7, t0
	slli	t0, t0, 2
	add	t2, a2, t0
	lw	t0, 0(t2)
	bne	t0, a7, .LBB0_8
	addi	t0, a5, 1
	slli	t0, t0, 2
	add	t1, a0, t0
	lw	t3, 0(t1)
.LBB0_10:
	mv	t1, t3
	slli	t3, t3, 2
	add	t3, a2, t3
	lw	t3, 0(t3)
	bne	t3, t1, .LBB0_10

	# Eliminate "bne	a7, t1, .LBB0_5" (Molnar's method)
  sub t4, a7, t1
  snez t4, t4
  andi t4, t4, 0xff
  neg  t4, t4       # true mask
  not  t5, t4       # false mask

  # Execute when branch condition evaluates to true
  # sw	t1, 0(t2)
  #   1. first load the currently stored value in t1
  #      if the condition evaluates to false to make
  #      sure is not updated 
  and t6, t1, t4
  lw  t1, 0(t2)
  and t1, t1, t5
  or  t1, t1, t6
	sw	t1, 0(t2)   # 2. Perform the store
  #addi	a4, a4, 1
  and  t6, a4, t5
	addi a4, a4, 1
  and  a4, a4, t4
  or   a4, a4, t6

  # Execute when branch condition evalutates to false
  #li	a7, -1
  and  t6, a7, t4
  addi a7, a7, -1
  and  a7, a7, t5
  or   a7, a7, t6
  #li	t1, -1
  and  t6, t1, t4
  addi t1, t1, -1
  and  t1, t1, t5
  or   t1, t1, t6

	j	.LBB0_6
.LBB0_13:
	li	a4, 0
.LBB0_14:
	sw	a4, 0(a1)
	mv	a0, a4
	ret
.Lfunc_end0:
	.size	kruskal, .Lfunc_end0-kruskal

	.section	".note.GNU-stack","",@progbits
