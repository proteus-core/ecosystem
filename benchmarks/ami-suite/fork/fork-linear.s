	.text
	.file	"fork.c"
	.globl	fork
	.p2align	2
	.type	fork,@function
fork:

  #Eliminate blt	a0, a1, .LBB0_2
  slt t0, a0, a1
  andi t0, t0, 0xff
  neg t0, t0         # true mask
  not t1, t0         # false mask

	addi	t2, a0, 2
  and t2, t2, t0
	li	a0, 3
  and a0, a0, t1
  or a0, a0, t2

	ret
.Lfunc_end0:
	.size	fork, .Lfunc_end0-fork

	.section	".note.GNU-stack","",@progbits
