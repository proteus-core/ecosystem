.global _start

.text
_start:
    la s1, test_data
    addi s2, s1, 16

    // lb/sb tests
    lb t0, 0(s1)    // Expected tag: 1
    lb t1, 6(s1)    // Expected tag: 0
    lb t2, 4(s1)    // Expected tag: 0
    lb t3, 8(s1)   // Expected tag: 0

    sb t0, 0(s2)    // Expected tag: 1, expected result: 1
    sb t1, 6(s2)    // Expected tag: 0, expected result: 1
    sb t2, 9(s2)    // Expected tag: 0, expected result: 1
    sb t3, 12(s2)   // Expected tag: 1
    sb t3, 13(s2)   // Expected tag: 1
    sb t3, 14(s2)   // Expected tag: 1
    sb t3, 15(s2)   // Expected tag: 1, expected result: 1

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
// Byte tests
.word 0x0        // Tags: 0000
.word 0x0        // Tags: 1010
.word 0x0        // Tags: 1010
.word 0x0        // Tags: 0000

.macro tag b0
    .word \b0
.endm

.section .tags
tag 1
tag 0
tag 1
tag 0
tag 0
tag 0
tag 0
tag 0
