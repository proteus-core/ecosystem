#include "support.h"
#include "mulmod16.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) mulmod16(267, 13853);
}

int benchmark(void)
{
    return mulmod16(267, 13853);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
