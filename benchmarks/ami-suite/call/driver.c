#include "support.h"
#include "call.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) call(2, 1);
}

int benchmark(void)
{
    return call(2, 1);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
