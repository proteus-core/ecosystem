#include "support.h"
#include "fork.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) fork(2, 3);
}

int benchmark(void)
{
    return fork(2, 3);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
