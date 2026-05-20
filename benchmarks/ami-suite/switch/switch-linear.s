	.text
	.file	"switch.c"
	.globl	switch_case                     # -- Begin function switch_case
	.p2align	2
	.type	switch_case,@function
switch_case:                            # @switch_case
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16

	mv t0, a0


  li a1, 1
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 1
  and a0, a0, t1
  or a0, a0, t3

  li a1, 2
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 2
  and a0, a0, t1
  or a0, a0, t3

  li a1, 3
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 3
  and a0, a0, t1
  or a0, a0, t3

  li a1, 4
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 4
  and a0, a0, t1
  or a0, a0, t3

  li a1, 5
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 5
  and a0, a0, t1
  or a0, a0, t3

  li a1, 6
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 6
  and a0, a0, t1
  or a0, a0, t3

  li a1, 7
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 7
  and a0, a0, t1
  or a0, a0, t3

  li a1, 8
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 8
  and a0, a0, t1
  or a0, a0, t3

  li a1, 9
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 9
  and a0, a0, t1
  or a0, a0, t3

  li a1, 10
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 10
  and a0, a0, t1
  or a0, a0, t3

  li a1, 11
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 11
  and a0, a0, t1
  or a0, a0, t3

  li a1, 12
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 12
  and a0, a0, t1
  or a0, a0, t3

  li a1, 13
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 13
  and a0, a0, t1
  or a0, a0, t3

  li a1, 14
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 14
  and a0, a0, t1
  or a0, a0, t3

  li a1, 15
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 15
  and a0, a0, t1
  or a0, a0, t3

  li a1, 15
  sub t1, t0, a1
  seqz t1, t1
  andi t1, t1, 0xff
  neg  t1, t1       # true mask
  not  t2, t1       # false mask
  and t3, a0, t2
	li	a0, 15
  and a0, a0, t1
  or a0, a0, t3


	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	ret
.Lfunc_end0:
	.size	switch_case, .Lfunc_end0-switch_case
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
