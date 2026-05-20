	.text
	.file	"call.c"
	.globl	call
	.p2align	2
	.type	call,@function
call:
	li	a2, 2
	bne	a0, a2, .LBB0_2
	mv	a0, a1
	tail	foo
.LBB0_2:
	li	a0, 0
	ret
.Lfunc_end0:
	.size	call, .Lfunc_end0-call

	.p2align	2
	.type	foo,@function
foo:
	lui	a1, %hi(v)
	sw	a0, %lo(v)(a1)
	lw	a0, %lo(v)(a1)
	addi	a2, a0, 1
	sw	a2, %lo(v)(a1)
	ret
.Lfunc_end1:
	.size	foo, .Lfunc_end1-foo

	.type	v,@object
	.section	.sbss,"aw",@nobits
	.p2align	2
v:
	.word	0
	.size	v, 4

	.section	".note.GNU-stack","",@progbits
