.global _start

.text
_start:
    la s1, test_data
    addi s2, s1, 16
    addi s3, s2, 16
    addi s4, s3, 16

    // lw/(sh/sb) tests
    lw t0, 0(s1)    // Expected tag: 1
    lw t1, 4(s1)    // Expected tag: 1
    lw t2, 8(s1)    // Expected tag: 1
    lw t3, 12(s1)   // Expected tag: 0

    sh t0, 0(s2)    // Expected tag: 11, expected result: 1111
    sh t3, 6(s2)    // Expected tag: 00, expected result: 0010
    sb t1, 8(s2)    // Expected tag: 1
    sb t2, 9(s2)    // Expected tag: 1, expected result: 1011
    sb t3, 13(s2)   // Expected tag: 0
    sb t3, 14(s2)   // Expected tag: 0, expected result: 1001

    // lh/(sw/sb) tests
    lh t0, 0(s1)    // Expected tag: 1
    lh t1, 4(s1)    // Expected tag: 0
    lh t2, 10(s1)   // Expected tag: 1
    lh t3, 12(s1)   // Expected tag: 0

    sw t0, 0(s3)    // Expected tag: 1111, expected result: 1111
    sw t3, 4(s3)    // Expected tag: 0000, expected result: 0000
    sb t2, 8(s3)    // Expected tag: 1
    sb t2, 9(s3)    // Expected tag: 1, expected result: 1011
    sb t1, 13(s3)   // Expected tag: 0
    sb t1, 14(s3)   // Expected tag: 0, expected result: 1001

    // lb/(sw/sh) tests
    lb t0, 0(s1)    // Expected tag: 1
    lb t1, 6(s1)    // Expected tag: 1
    lb t2, 4(s1)    // Expected tag: 0
    lb t3, 7(s1)   // Expected tag: 1

    sw t0, 0(s4)    // Expected tag: 1111, expected result: 1111
    sw t2, 4(s4)    // Expected tag: 0000, expected result: 0000
    sh t1, 8(s4)    // Expected tag: 11, expected result: 1011
    sh t2, 14(s4)   // Expected tag: 00, expected result: 0011

    // An immediate should always have tag set to 0
    li t0, 0xCAFEBABE
    sw t0, 16(s4)   // Expected tag: 0000, expected result: 0000

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
// lw/(sh/sb) tests
.word 0x0        // Tags: 1100
.word 0x0        // Tags: 0010
.word 0x0        // Tags: 1000
.word 0x0        // Tags: 1111
// lh/(sw/sb) tests
.word 0x0        // Tags: 1100
.word 0x0        // Tags: 1110
.word 0x0        // Tags: 1000
.word 0x0        // Tags: 1111
// lb/(sw/sh) tests
.word 0x0        // Tags: 1100
.word 0x0        // Tags: 1110
.word 0x0        // Tags: 1000
.word 0x0        // Tags: 1111
// immediate
.word 0x0        // Tags: 1111

.macro tag b3, b2, b1, b0
    .word (\b3 << 24) | (\b2 << 16) | (\b1 << 8) | \b0
.endm

.section .tags
tag 1, 1, 1, 1
tag 1, 1, 0, 0
tag 0, 1, 0, 1
tag 0, 0, 0, 0
tag 1, 1, 0, 0
tag 0, 0, 1, 0
tag 1, 0, 0, 0
tag 1, 1, 1, 1
tag 1, 1, 0, 0
tag 1, 1, 1, 0
tag 1, 0, 0, 0
tag 1, 1, 1, 1
tag 1, 1, 0, 0
tag 1, 1, 1, 0
tag 1, 0, 0, 0
tag 1, 1, 1, 1
tag 1, 1, 1, 1
