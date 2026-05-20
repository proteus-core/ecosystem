	.text
	.file	"mulmod16.c"
	.globl	mulmod16
	.p2align	2
	.type	mulmod16,@function
mulmod16:
	lui	a2, 16
	addi	a2, a2, -1
	and	a0, a0, a2
	and	a1, a1, a2
 
  # Eliminate two consecutive branch instructions:
  #beqz	a0, .LBB0_3
  #beqz	a1, .LBB0_4

.LBB0_3:
  # CASE 1: a == 0
  seqz t3, a0
  andi t3, t3, 0xff
  neg  t3, t3       # true mask
  not  t4, t3       # false mask
	sub	t0, a2, a1    # region-temporary (reallocate registers)
  # addi a0, a0, 2  # execute conditionally (Molnar)
  and  t1, a0, t4
	addi t2, t0, 2
  and  t2, t2, t3
  or   a0, t2, t1

.LBB0_4:
  # CASE 2: b == 0
  seqz t5, a1
  andi t5, t5, 0xff
  neg  t5, t5       # true mask
  not  t6, t5       # false mask
	sub  t0, a2, a0   # region-temporary (rellocate registers)
  # addi a0, a0, 2  # execute conditionally (Molnar)
  and  t1, a0, t6
	addi t2, t0, 2
  and  t2, t2, t5
  or   a0, t2, t1

  # CASE 3: a != 0 and b != 0
  and t3, t4, t6    # true mask (bitwise and of above false masks)
  not t4, t3        # false mask
	mul	t0, a1, a0    # region-temporary (reallocate registers)
	and	t1, t0, a2    # region-temporary (reallocate registers)
	srli	t0, t0, 16  # region-temporary (reallocate registers)
	sub	a3, t1, t0    # region-temporary (reallocate registers)
	sltu	t0, t1, t0  # region-temporary (reallocate registers)
  # add	a0, a3, a0  # execute conditionnaly (Molnar)
  and t1, a0, t4
	add	t2, a3, t0 
  and t2, t2, t3
  or  a0, t2, t1

	and	a0, a0, a2
	ret
.Lfunc_end0:
	.size	mulmod16, .Lfunc_end0-mulmod16

	.section	".note.GNU-stack","",@progbits
