# ----  Secret value ----#
# Run experiments with 2 secret values that
# trigger distinct microarchitectural leakage
#ifdef EXP0
#define SECRET_VALUE 0x00000
#else
#define SECRET_VALUE 0xDEAD0
#endif

.globl _start
.include "lib.s"
.data
	public_value: .word 0
	.space 1024  # padding to avoid caching
	public_address: .word 0
	.space 1024  # padding to avoid caching
	secret: .word SECRET_VALUE

.text
_start:

setup:
	# public_address = &public_value;

	# set up ProSpeCT CSRs
	prospect_protect_4b secret

	la t0, public_value
	la t1, public_address
	sw t0, (t1)

	nop
	nop

	# t6 = *secret  // load secret architecturally
	lw t6, secret

condition:
	# t0 = *public_address
	# t0 = *t0
	## if (t0 == 0) { goto finish; }

	la t0, public_address
	lw t0, (t0)
	lw t0, (t0)
	beqz t0, finish

	# ----- BEGIN TRANSIENT BLOCK -----

	# fence
	insert_dfence

	# leak(t6);
	insert_leak t6 t1 condition

	# ----- END TRANSIENT BLOCK -----

finish:
	terminate_proteus
