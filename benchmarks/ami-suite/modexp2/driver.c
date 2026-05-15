#include "support.h"
#include "modexp2.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) modexp2(10, 42);
}

int benchmark(void)
{
    return modexp2(10, 42);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
