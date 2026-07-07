#ifndef RISCV_TEST_H
#define RISCV_TEST_H

#include "riscv-tests/env/encoding.h"

#define RVTEST_RV64U                                                    \
    .macro init;                                                        \
    .endm

#define RVTEST_RV64M                                                    \
    .macro init;                                                        \
    .endm

#define RVTEST_RV32U                                                    \
    .macro init;                                                        \
    .endm

#define RVTEST_RV32M                                                    \
    .macro init;                                                        \
    .endm

// Supervisor tests: if the test defines an stvec_handler, install it and
// delegate the exceptions the riscv-tests supervisor tests rely on (as in
// riscv-tests/env/p). Then enter the test body in S-mode.
#define RVTEST_ENTER_SUPERVISOR                                         \
    la t0, stvec_handler;                                               \
    beqz t0, 1f;                                                        \
    csrw stvec, t0;                                                     \
    li t0, (1 << CAUSE_MISALIGNED_FETCH) |                              \
           (1 << CAUSE_BREAKPOINT) |                                    \
           (1 << CAUSE_USER_ECALL);                                     \
    csrw medeleg, t0;                                                   \
1:  li t0, MSTATUS_MPP;                                                 \
    csrc mstatus, t0;                                                   \
    li t0, MSTATUS_MPP & (MSTATUS_MPP >> 1);                            \
    csrs mstatus, t0;                                                   \
    la t0, 1f;                                                          \
    csrw mepc, t0;                                                      \
    mret;                                                               \
1:

#define RVTEST_RV64S                                                    \
    .macro init;                                                        \
    RVTEST_ENTER_SUPERVISOR;                                            \
    .endm

#define RVTEST_RV32S                                                    \
    .macro init;                                                        \
    RVTEST_ENTER_SUPERVISOR;                                            \
    .endm

#define RVTEST_CODE_BEGIN                                               \
    .text;                                                              \
    .weak fail;                                                         \
    .globl _start;                                                      \
_start:                                                                 \
    la tp, trap_vector;                                                 \
    csrw mtvec, tp;                                                     \
    j start_tests;                                                      \
trap_vector:                                                            \
    la tp, mtvec_handler;                                               \
    beqz tp, 1f;                                                        \
    jr tp;                                                              \
1:  la tp, fail;                                                        \
    beqz tp, 1f;                                                        \
    jr tp;                                                              \
1:  mret;                                                               \
start_tests:                                                            \
    init;

// HACK LLVM started erring when weak symbols are redefined as global. However,
// globals being redefined as weak only causes a warning.
// https://reviews.llvm.org/D90108
#define RVTEST_CODE_END                                                 \
    .weak mtvec_handler;                                                \
    .weak stvec_handler;

#define RVTEST_DATA_BEGIN                                               \
    .data;

#define RVTEST_DATA_END

#define TESTNUM gp

#define TESTDEV 0x30000000

#define RVTEST_FAIL                                                     \
    li tp, TESTDEV;                                                     \
    sw TESTNUM, 0(tp);

#define RVTEST_PASS                                                     \
    li tp, TESTDEV;                                                     \
    sw zero, 0(tp);

#endif
