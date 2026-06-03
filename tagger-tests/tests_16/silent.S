.global _start

.text
_start:
    la s1, test_data
    li t1, 0x11111111
    li t2, 0x22222222

    lw t0, 0(s1)
    sw t1, 0(s1)

    lw t0, 4(s1)
    sw t2, 4(s1)

    lw t0, 16(s1)
    sw t0, 16(s1)

    lw t0, 20(s1)
    sw t0, 20(s1)

_halt:
	lui ra,0x10000
	li sp,4
	sb sp,0(ra)

.data
test_data:
.word 0x11111111
.word 0x22222222
.word 0x0
.word 0x0
.word 0x33333333
.word 0x44444444
.word 0x0
.word 0x0

.macro tag b3, b2, b1, b0
    .word (\b1 << 16) | \b0
.endm

.section .tags
tag 0, 0, 0, 0
tag 1, 1, 1, 1
tag 0, 0, 0, 0
tag 0, 0, 0, 0
tag 0, 0, 0, 0
tag 1, 1, 1, 1
tag 0, 0, 0, 0
tag 0, 0, 0, 0
