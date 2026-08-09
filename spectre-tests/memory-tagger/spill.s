.globl _start

.data
    public_value: .word 0
    public_address: .word 0
    secret: .word 0xDEAD0
    
    stack_space: .word 0 

.macro tag b3, b2, b1, b0
    .word (\b3 << 24) | (\b2 << 16) | (\b1 << 8) | \b0
.endm

.section .tags
    tag 0, 0, 0, 0
    tag 0, 0, 0, 0
    tag 1, 1, 1, 1
    tag 0, 0, 0, 0

.text
_start:

setup:
    la sp, stack_space

    # public_address = &public_value;

    la t0, public_value
    la t1, public_address
    sw t0, (t1)

    # Load secret from memory
    la t6, secret
    lw t6, (t6)

    # Spill secret to stack
    sw t6, 0(sp)

condition:
    # t0 = *public_address
    # t0 = *t0
    # t0 = t0 * t0
    # t0 = t0 * t0
    # if (t0 == 0) { goto finish; } 
    
    la t0, public_address
    lw t0, (t0)
    lw t0, (t0)
    mul t0, t0, t0
    mul t0, t0, t0
    beqz t0, finish

    # ----- BEGIN TRANSIENT BLOCK -----

    lw t5, 0(sp)
    lw zero, (t5)

    # ----- END TRANSIENT BLOCK -----

finish:
    lui ra,0x10000
    li sp,4
    sb sp,0(ra)
