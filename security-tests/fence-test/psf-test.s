.macro sfence_t6
    .word 0x100F8F8F
.endm

.globl _start
.data
        variable: .word 42
        address_to_bound: .word 0

        flushing_array: .space 1024
        boundary: .word 43

.text
_start:
        # address_to_bound = &boundary;

        la t0, boundary
        la t1, address_to_bound
        sw t0, (t1)

        # --- address flushed from the cache here ---
        la t1, boundary
        la t0, flushing_array
loop:
        addi t0, t0, 4
        lw zero, (t0)
        ble t0, t1, loop

        .rept 64
        nop
        .endr

        # --- flushing ends here ---

        la t4, variable
        li t2, 0xDEAD0
        sw t2, (t4)             # storing secret to variable
        lw t0, address_to_bound
        lw t6, (t0)             # slow load waiting for t0, t2 should be speculatively forwarded

        sfence_t6

        j finish                # jump over load that would otherwise cause an exception (invalid address)
        lw zero, (t6)           # leaking the old value here

finish:
        lui ra,0x10000
        li sp,4
        sb sp,0(ra)
