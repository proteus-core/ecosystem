#include <stdio.h>
#include <inttypes.h>
#include "performance.h"

int main()
{
    uint64_t cycles = rdcycle();
    printf("Hello, world! It took %" PRIu64 " cycles to boot\n", cycles);
}