.global _start

.text
_start:
    la s1, test_data
    addi s2, s1, 16

    // lh/sh tests
    lh t0, 0(s1)    // Expected tag: 1
    lh t1, 6(s1)    // Expected tag: 1
    lh t2, 10(s1)   // Expected tag: 1
    lh t3, 12(s1)   // Expected tag: 0
    
    sh t0, 0(s2)    // Expected tag: 1, expected result: 01
    sh t1, 6(s2)    // Expected tag: 1, expected result: 11
    sh t2, 8(s2)    // Expected tag: 1, expected result: 11
    sh t3, 14(s2)   // Expected tag: 0, expected result: 01

_halt:
	lui ra,0x10000
	li sp,4
	sb sp,0(ra)

.data
test_data:
// Loads
.word 0x80000200 // Tags: 11
.word 0x22222222 // Tags: 10
.word 0x33333333 // Tags: 11
.word 0x44444444 // Tags: 10
// Half word tests
.word 0x0        // Tags: 00
.word 0x0        // Tags: 01
.word 0x0        // Tags: 10
.word 0x0        // Tags: 11

.macro tag b1, b0
    .word (\b1 << 16) | \b0
.endm

.section .tags
tag 1, 1
tag 1, 0
tag 1, 1
tag 1, 0
tag 0, 0
tag 0, 1
tag 1, 0
tag 1, 1

