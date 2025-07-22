# ----  Secret value ----#
# Run experiments with 2 secret values that
# trigger distinct microarchitectural leakage
#ifdef EXP0
#define SECRET_VALUE 0x00000
#else
#define SECRET_VALUE 0xDEAD0
#endif

.globl _start
.data
        .align 16
        padding1: .space 12
        variable: .word SECRET_VALUE
        address_to_var: .word 0

.include "lib.s"

.text
_start:
        # address_to_var = &variable;

        la t0, variable
        la t1, address_to_var
        sw t0, (t1)

        cflush t1 t0           # address flushed from the cache here
        reload s0 variable     # making sure variable is cached again        # --- flushing ends here ---

        lw t0, address_to_var
        sw zero, (t0)            # storing finish address to variable
        lw t6, variable        # this will use a hardcoded address and be fast

        insert_dfence

        insert_leak t6 t1 finish2 # leaking the old value here

finish:
        nop
finish2:
        terminate_proteus
