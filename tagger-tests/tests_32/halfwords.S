.global _start

.text
_start:
    la s1, test_data
    addi s2, s1, 16

    // lh/sh tests
    lh t0, 0(s1)    // Expected tag: 1
    lh t1, 6(s1)    // Expected tag: 0
    lh t2, 10(s1)   // Expected tag: 1
    lh t3, 12(s1)   // Expected tag: 0
    
    sh t0, 0(s2)    // Expected tag: 1, expected result: 1
    sh t1, 6(s2)    // Expected tag: 0, expected result: 1
    sh t2, 8(s2)    // Expected tag: 1, expected result: 1
    sh t3, 14(s2)   // Expected tag: 0, expected result: 1

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
// Half word tests
.word 0x0        // Tags: 0000
.word 0x0        // Tags: 0011
.word 0x0        // Tags: 0001
.word 0x0        // Tags: 1100

.macro tag b0
    .word \b0
.endm

.section .tags
tag 1
tag 0
tag 1
tag 0
tag 0
tag 1
tag 1
tag 0

