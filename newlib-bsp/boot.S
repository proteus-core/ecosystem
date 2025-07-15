#include "chardev.h"

    .section .boot
    .globl _boot
_boot:
    .option push
    .option norelax
    .extern _end
    la sp, _end
    .extern heap_pointer
    la a0, heap_pointer
    .option pop

    # stack size: 256MB
    li t0, 268435456
    add sp, sp, t0
    # align sp to 8 bytes
    li t0, 0xfffffff8
    and sp, sp, t0

    # initialise heap_pointer
    sw sp, 0(a0)

    jal _init_traps
    jal _start

    .globl _halt
_halt:
    li x1, CHARDEV_ADDR
    li x2, CHARDEV_EOT
    sb x2, 0(x1)
1:
    j 1b
