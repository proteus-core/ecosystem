#include "support.h"
#include "triangle.h"

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) triangle(1, 2);
}

int benchmark(void)
{
    return triangle(1, 2);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
