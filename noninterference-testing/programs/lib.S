.data
	flushing_array: .space 1024
	boundary: .word 43

# ----  Defense insertion ----#
# Expand into different fences
# according to processor directive
.macro insert_dfence
#if defined(FULLFENCE)
	fence
#endif
# no defence
.endm

.macro prospect_protect_4b label
#if defined(PROSPECT)
	la t0, \label
	csrrw zero, 0x707, t0
	addi t0, t0, 4
	csrrw zero, 0x708, t0
#endif
.endm

# ----  Leakage insertion ----#
# Leak the register in different ways
# according to processor directive
.macro insert_leak secret_reg other_reg jmp_label
#if defined(LEAKLOAD)
	lw zero, (\secret_reg)
#elif defined(LEAKSTORE)
	;; lw zero, (zero)
	sw zero, (\secret_reg)
	lw \other_reg, (zero)
	div \other_reg, \other_reg, \other_reg
#elif defined(LEAKBR)
	beqz \secret_reg, \jmp_label
#elif defined(LEAKJMP)
# /!\ Make sure \secret_reg is zero architecturally
	la \other_reg, finish
	add \other_reg, \other_reg, \secret_reg
	jalr zero, 0(\other_reg)
#elif defined(LEAKDIV)
	div \other_reg, \other_reg, \secret_reg
#endif
.endm

# ----  Proteus specific macros ----#
.macro terminate_proteus
	lui ra,0x10000
	li sp,4
	sb sp,0(ra)
	.rept 64
	nop
	.endr
.endm

# Flush cache using temporary registers r1 and r2
.macro cflush r1 r2
	la \r1, boundary
	la \r2, flushing_array
loop:
	addi \r2, \r2, 4
	lw zero, (\r2)
	ble \r2, \r1, loop
	.rept 64
	nop
	.endr
.endm

# Load from memory and wait for load to be completed
.macro reload reg addr
	lw \reg, \addr
	.rept 64
	nop
	.endr
.endm
