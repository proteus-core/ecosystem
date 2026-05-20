#include "support.h"
#include "ifthenloop.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) ifthenloop(1, 2);
}

int benchmark(void)
{
    return ifthenloop(1, 2);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
