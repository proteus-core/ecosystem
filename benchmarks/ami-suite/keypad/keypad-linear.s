	.file	"keypad.c"
	.option nopic
	.text
	.align	2
	.globl	keypad_init
	.type	keypad_init, @function
keypad_init:
	lui	a5,%hi(count)
	sw	zero,%lo(count)(a5)
	lui	a5,%hi(key_state)
	sh	zero,%lo(key_state)(a5)
	lui	a5,%hi(pin_idx)
	sw	zero,%lo(pin_idx)(a5)
	ret
	.size	keypad_init, .-keypad_init
	.align	2
	.globl	keypad_poll
	.type	keypad_poll, @function
keypad_poll:
	lui	a4,%hi(count)
	lw	a5,%lo(count)(a4)
	li	a3,9
	addi	a2,a5,1
	sw	a2,%lo(count)(a4)
	addi	a5,a5,-1
	bgtu	a5,a3,.L7
	lui	a1,%hi(.LANCHOR0)
	addi	a1,a1,%lo(.LANCHOR0)
	slli	a5,a5,1
	add	a5,a1,a5
	lhu	t5,0(a5)
	mv	a0,t5
.L4:
	lui	t1,%hi(pin)
	addi	a2,a1,20
	li	a5,1
	addi	a1,a1,84
	lui	a6,%hi(key_state)
	lui	a7,%hi(pin_idx)
	addi	t1,t1,%lo(pin)
.L6:
	lhu	a3,%lo(key_state)(a6)
	and	a4,a0,a5
	and	a3,a3,a5

  # Hoist temporaries (with reallocated registers)
	lw	t0,%lo(pin_idx)(a7)

	li	t4,3
#	beq	a4,zero,.L5
#	bne	a3,zero,.L5
#	bgt	t0,t4,.L5
  seqz a4, a4
  snez a3, a3
  slt  t2, t4, t0
  or   a4, a4, a3
  or   a4, a4, t2
  andi a4, a4, 0xff
  neg  a4, a4       # false flag
  not  a3, a4       # true flag

	add	t2,t0,t1
	lw	t3,%lo(pin_idx)(a7)
	lb	t6,0(t2)

  #addi	t3,t0,1
  and   t4,t3,a4
  addi	t3,t0,1
  and   t3,t3,a3
  or    t3,t3,t4
  #lbu	t6,0(a2)
  and t4,t6,a4
  lbu	t6,0(a2)
  and t6,t6,a3
  or  t6,t6,t4

.L5:
	sw	t3,%lo(pin_idx)(a7)
	sb	t6,0(t2)

	addi	a2,a2,4
	slli	a5,a5,1
	bne	a2,a1,.L6
	lw	a5,%lo(pin_idx)(a7)
	li	a0,4
	sh	t5,%lo(key_state)(a6)
	sub	a0,a0,a5
	ret
.L7:
	lui	a1,%hi(.LANCHOR0)
	li	a0,0
	li	t5,0
	addi	a1,a1,%lo(.LANCHOR0)
	j	.L4
	.size	keypad_poll, .-keypad_poll
	.section	.rodata
	.align	2
	.set	.LANCHOR0,. + 0
	.type	CSWTCH.8, @object
	.size	CSWTCH.8, 20
CSWTCH.8:
	.half	1
	.half	1
	.half	0
	.half	2
	.half	0
	.half	4
	.half	0
	.half	8
	.half	0
	.half	16
	.type	keymap, @object
	.size	keymap, 64
keymap:
	.word	49
	.word	52
	.word	55
	.word	48
	.word	50
	.word	53
	.word	56
	.word	70
	.word	51
	.word	54
	.word	57
	.word	69
	.word	65
	.word	66
	.word	67
	.word	68
	.section	.sbss,"aw",@nobits
	.align	2
	.type	pin, @object
	.size	pin, 4
pin:
	.zero	4
	.type	pin_idx, @object
	.size	pin_idx, 4
pin_idx:
	.zero	4
	.type	key_state, @object
	.size	key_state, 2
key_state:
	.zero	2
	.zero	2
	.type	count, @object
	.size	count, 4
count:
	.zero	4
