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
    
    sw t0, 0(s2)    // Expected store: 1111, expected result: 1111
    sw t1, 4(s2)    // Expected store: 1111, expected result: 1111
    sw t2, 8(s2)    // Expected store: 1111, expected result: 1111
    sw t3, 12(s2)   // Expected store: 0000, expected result: 0000

_halt:
	lui ra,0x10000
	li sp,4
	sb sp,0(ra)

.data
test_data:
// Loads
.word 0x80000200 // Tags: 1111
.word 0x22222222 // Tags: 1100
.word 0x33333333 // Tags: 0101
.word 0x44444444 // Tags: 0000
// Word tests
.word 0x0        // Tags: 0000
.word 0x0        // Tags: 0000
.word 0x0        // Tags: 0000
.word 0x0        // Tags: 1111

.macro tag b3, b2, b1, b0
    .word (\b3 << 24) | (\b2 << 16) | (\b1 << 8) | \b0
.endm

.section .tags
tag 1, 1, 1, 1
tag 1, 1, 0, 0
tag 0, 1, 0, 1
tag 0, 0, 0, 0
tag 0, 0, 0, 0
tag 0, 0, 0, 0
tag 0, 0, 0, 0
tag 1, 1, 1, 1
