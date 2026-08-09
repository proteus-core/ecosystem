.global _start

.text
_start:
    la s1, test_data
    addi s2, s1, 16

    // lw/sw tests
    lw t0, 0(s1)    // Expected tag: 1
    lw t1, 4(s1)    // Expected tag: 1
    lw t2, 8(s1)    // Expected tag: 1
    lw t3, 12(s1)   // Expected tag: 0
    
    sw t0, 0(s2)    // Expected store: 11, expected result: 11
    sw t1, 4(s2)    // Expected store: 11, expected result: 11
    sw t2, 8(s2)    // Expected store: 11, expected result: 11
    sw t3, 12(s2)   // Expected store: 00, expected result: 00

_halt:
	lui ra,0x10000
	li sp,4
	sb sp,0(ra)

.data
test_data:
// Loads
.word 0x80000200 // Tags: 11
.word 0x22222222 // Tags: 01
.word 0x33333333 // Tags: 10
.word 0x44444444 // Tags: 00
// Word tests
.word 0x0        // Tags: 00
.word 0x0        // Tags: 01
.word 0x0        // Tags: 10
.word 0x0        // Tags: 11

.macro tag b1, b0
    .word (\b1 << 16) | \b0
.endm

.section .tags
tag 1, 1
tag 0, 1
tag 1, 0
tag 0, 0
tag 0, 0
tag 0, 1
tag 1, 0
tag 1, 1
