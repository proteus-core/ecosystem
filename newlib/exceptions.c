#include <stdio.h>

void exception(long cause)
{
    long mtval, mepc;
    asm(
        "csrr %0, mtval\n\t"
        "csrr %1, mepc\n\t"
        : "=r"(mtval), "=r"(mepc)
   );

    printf("Exception at %lx: cause=%li mtval=%lx\n", mepc, cause, mtval);
}
