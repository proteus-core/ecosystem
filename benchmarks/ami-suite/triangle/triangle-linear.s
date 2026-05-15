	.text
	.file	"triangle.c"
	.globl	triangle
	.p2align	2
	.type	triangle,@function
triangle:
	mv	a2, a0
	# Eliminate "blt	a2, a1, .LBB0_2" (Molnar's method)
  slt a1, a2, a1
  andi a1, a1, 0xff
  neg a1, a1     # true mask
  not a2, a1     # false mask

	andi	a1, a1, 7
	li	  a0, 3
  and   a0, a0, a2
  or    a0, a0, a1
.LBB0_2:
	ret
.Lfunc_end0:
	.size	triangle, .Lfunc_end0-triangle

	.section	".note.GNU-stack","",@progbits
