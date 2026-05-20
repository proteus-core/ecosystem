#include "support.h"
#include "switch.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) switch_case(0x0001);
}

int benchmark(void)
{
    return switch_case(0x0001);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
