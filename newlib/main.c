#include <stdio.h>
#include "performance.h"

int main()
{
    uint64_t cycles = rdcycle();
    printf("Hello, world! It took %llu cycles to boot\n", cycles);
}