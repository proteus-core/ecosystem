	.text
	.file	"lookup.c"
	.globl	lookup_val
	.p2align	2
	.type	lookup_val,@function
lookup_val:
	li	a1, 10

	# Eliminate "blt	a0, a1, .LBB0_2" (Molnar's method)
  slt t0, a0, a1
  andi t0, t0, 0xff
  neg t0, t0         # true mask
  not t1, t0         # false mask

  # Execute when branch condition evaluates to false
	# li	a0, 7
  and t2, a0, t0
  li  a0, 7
  and a0, a0, t1
  or  a0, a0, t2

  # Execute when branch condition evaluates to true
.LBB0_2:
	slli	t3, t3, 1 # Temporary computation (not live after senstive region)
  and   t2, a0, t1
	addi	a0, t3, 2
  and   a0, a0, t0
  or    a0, a0, t2

	ret
.Lfunc_end0:
	.size	lookup_val, .Lfunc_end0-lookup_val

	.section	".note.GNU-stack","",@progbits
