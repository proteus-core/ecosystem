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
        variable: .word 42
        finish_address: .word 0
	secret: .word SECRET_VALUE

.include "lib.s"

.text
_start:

        # address_to_bound = &boundary;

        la t0, finish
        la t1, finish_address
        sw t0, (t1)

        la t0, secret
        lw t2, (t0)

        cflush t1 t0 # address flushed from the cache here

        la t4, variable
        sw t2, (t4)             # storing secret to variable
        lw t0, finish_address
        lw t6, (t0)             # slow load waiting for t0, t2 should be speculatively forwarded
        j finish                # jump over load that would otherwise cause an exception (invalid address)
        insert_dfence           # fence
        # leak(t6);
        insert_leak t6 t1 finish2

finish:
        nop
finish2:
        terminate_proteus
