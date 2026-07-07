// Proteus adaptation of the riscv-tests virtual memory test environment (env/v).
//
// env/v is a small kernel: it boots in M-mode, builds Sv32/Sv39 page tables, delegates page
// faults to S-mode and sret's to the test in U-mode, demand-paging it in from the page-fault
// handler. The stock environment is left untouched; it is customized through its EXTRA_INIT and
// FILTER_TRAP hooks to adapt it to Proteus:
//
//  - The simulator does not zero memory, so .bss (which holds the page tables and the page
//    freelist) is cleared manually at boot.
//  - Pass/fail is reported by writing to the memory-mapped test device instead of the HTIF
//    tohost interface, which the simulator does not implement. The device page is identity-mapped
//    in the page tables since the report happens with translation enabled.
//    Note that internal env/v assertion failures still use HTIF and thus show up as simulator
//    timeouts instead of failures.

#ifndef _ENV_PROTEUS_VIRTUAL_H
#define _ENV_PROTEUS_VIRTUAL_H

#include "../riscv-tests/env/v/riscv_test.h"

#define TESTDEV_PA 0x30000000
// Leaf PTE mapping TESTDEV_PA with V|R|W|A|D, at a level-1 (Sv32) / level-2 (Sv39) entry, i.e. a
// megapage, for which TESTDEV_PA is sufficiently aligned.
#define TESTDEV_PTE (((TESTDEV_PA >> 12) << 10) | 0xc7)

#if __riscv_xlen == 64
// VA[29:21] indexes user_l2pt (= pt[1]), reached via l1pt[VA[38:30]] = l1pt[0].
# define TESTDEV_PTE_OFFSET (4096 + ((TESTDEV_PA >> 21) & 0x1ff) * 8)
# define VSTORE sd
# define VLOAD ld
# define VREGBYTES 8
#else
// VA[31:22] indexes the root page table l1pt (= pt[0]).
# define TESTDEV_PTE_OFFSET ((TESTDEV_PA >> 22) * 4)
# define VSTORE sw
# define VLOAD lw
# define VREGBYTES 4
#endif

// Runs in extra_boot, called from the reset handler in M-mode before vm_boot. Must preserve ra.
#undef EXTRA_INIT
#define EXTRA_INIT                                                      \
        la t0, __bss_start;                                             \
        la t1, _end;                                                    \
1:      bge t0, t1, 2f;                                                 \
        VSTORE zero, 0(t0);                                             \
        addi t0, t0, VREGBYTES;                                         \
        j 1b;                                                           \
2:      la t0, pt;                                                      \
        li t1, TESTDEV_PTE;                                             \
        li t2, TESTDEV_PTE_OFFSET;                                      \
        add t0, t0, t2;                                                 \
        VSTORE t1, 0(t0);

// Runs at the start of trap_filter(trapframe_t *tf) with a0 = tf, in S-mode with translation
// enabled. The test exits with a user ecall: a0 = 1 means pass, a0 = (testnum << 1) | 1 means
// failure; the test device expects 0 for pass and the failed test number otherwise.
#undef FILTER_TRAP
#define FILTER_TRAP                                                     \
        VLOAD t0, 35*VREGBYTES(a0); /* tf->cause */                     \
        li t1, CAUSE_USER_ECALL;                                        \
        bne t0, t1, 1f;                                                 \
        VLOAD t0, 10*VREGBYTES(a0); /* tf->gpr[10]: exit code */        \
        li t1, TESTDEV_PA;                                              \
        li t2, 1;                                                       \
        bne t0, t2, 2f;                                                 \
        li t0, 1; /* pass: report 0 */                                  \
2:      srli t0, t0, 1;                                                 \
        sw t0, 0(t1);                                                   \
3:      j 3b;                                                           \
1:

#endif
