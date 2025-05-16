.macro sfence_t6
    .word 0x100F8F8F
.endm

.globl _start
.data
        .align 16
        padding1: .space 12
        variable: .word 0xDEAD0
        address_to_var: .word 0

        flushing_array: .space 1024
        boundary: .word 0

.text
_start:
        # address_to_var = &variable;

        la t0, variable
        la t1, address_to_var
        sw t0, (t1)

        # --- address flushed from the cache here ---
        la t1, boundary
        la t0, flushing_array
loop:
        addi t0, t0, 4
        lw zero, (t0)
        ble t0, t1, loop

        lw s0, variable      # making sure variable is cached again

        .rept 64
        nop
        .endr

        # --- flushing ends here ---

        lw t0, address_to_var
        sw zero, (t0)           # storing zero to variable
        lw t6, variable         # this will use a hardcoded address and be fast

        sfence_t6

        lw zero, (t6)           # leaking the old value here

finish:
        lui ra,0x10000
        li sp,4
        sb sp,0(ra)
