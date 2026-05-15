#include "support.h"
#include "diamond.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) diamond(1, 1);
}

int benchmark(void)
{
    return diamond(1, 1);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
