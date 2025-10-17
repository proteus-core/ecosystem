// inspired by https://github.com/ucb-bar/libgloss-htif/blob/master/misc/crt0.S
#if __riscv_xlen == 64
#define LREG ld
#define SREG sd
#define WORD_SIZE 8
#else
#define LREG lw
#define SREG sw
#define WORD_SIZE 4
#endif

#define CONTEXT_SIZE (32 * WORD_SIZE)

    .text
    .globl _init_traps
_init_traps:
    la  t0, _trap_handler
    csrw mtvec, t0
    ret

_trap_handler:
    addi sp, sp, -CONTEXT_SIZE

    /* Save trap frame */
    SREG x1, 1*WORD_SIZE(sp)
    SREG x5, 5*WORD_SIZE(sp)
    SREG x6, 6*WORD_SIZE(sp)
    SREG x7, 7*WORD_SIZE(sp)
    SREG x8, 8*WORD_SIZE(sp)
    SREG x9, 9*WORD_SIZE(sp)
    SREG x10, 10*WORD_SIZE(sp)
    SREG x11, 11*WORD_SIZE(sp)
    SREG x12, 12*WORD_SIZE(sp)
    SREG x13, 13*WORD_SIZE(sp)
    SREG x14, 14*WORD_SIZE(sp)
    SREG x15, 15*WORD_SIZE(sp)
    SREG x16, 16*WORD_SIZE(sp)
    SREG x17, 17*WORD_SIZE(sp)
    SREG x18, 18*WORD_SIZE(sp)
    SREG x19, 19*WORD_SIZE(sp)
    SREG x20, 20*WORD_SIZE(sp)
    SREG x21, 21*WORD_SIZE(sp)
    SREG x22, 22*WORD_SIZE(sp)
    SREG x23, 23*WORD_SIZE(sp)
    SREG x24, 24*WORD_SIZE(sp)
    SREG x25, 25*WORD_SIZE(sp)
    SREG x26, 26*WORD_SIZE(sp)
    SREG x27, 27*WORD_SIZE(sp)
    SREG x28, 28*WORD_SIZE(sp)
    SREG x29, 29*WORD_SIZE(sp)
    SREG x30, 30*WORD_SIZE(sp)
    SREG x31, 31*WORD_SIZE(sp)

    csrr t0, mcause
    srli t1, t0, __riscv_xlen - 1
    bne t1, zero, _interrupt_handler
    li t1, 11
    beq t0, t1, _syscall_handler
    j _unsupported_trap

_trap_return:
    LREG x1, 1*WORD_SIZE(sp)
    LREG x5, 5*WORD_SIZE(sp)
    LREG x6, 6*WORD_SIZE(sp)
    LREG x7, 7*WORD_SIZE(sp)
    LREG x8, 8*WORD_SIZE(sp)
    LREG x9, 9*WORD_SIZE(sp)
    LREG x10, 10*WORD_SIZE(sp)
    LREG x11, 11*WORD_SIZE(sp)
    LREG x12, 12*WORD_SIZE(sp)
    LREG x13, 13*WORD_SIZE(sp)
    LREG x14, 14*WORD_SIZE(sp)
    LREG x15, 15*WORD_SIZE(sp)
    LREG x16, 16*WORD_SIZE(sp)
    LREG x17, 17*WORD_SIZE(sp)
    LREG x18, 18*WORD_SIZE(sp)
    LREG x19, 19*WORD_SIZE(sp)
    LREG x20, 20*WORD_SIZE(sp)
    LREG x21, 21*WORD_SIZE(sp)
    LREG x22, 22*WORD_SIZE(sp)
    LREG x23, 23*WORD_SIZE(sp)
    LREG x24, 24*WORD_SIZE(sp)
    LREG x25, 25*WORD_SIZE(sp)
    LREG x26, 26*WORD_SIZE(sp)
    LREG x27, 27*WORD_SIZE(sp)
    LREG x28, 28*WORD_SIZE(sp)
    LREG x29, 29*WORD_SIZE(sp)
    LREG x30, 30*WORD_SIZE(sp)
    LREG x31, 31*WORD_SIZE(sp)
    addi sp, sp, CONTEXT_SIZE
    mret

_syscall_handler:
    jal syscall
    SREG a0, 10 * WORD_SIZE(sp)
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0
    j _trap_return

_interrupt_handler:
    slli a0, t0, 1
    srli a0, a0, 1
    jal isr
    j _trap_return

_unsupported_trap:
    mv a0, t0
    jal exception
    j _halt
