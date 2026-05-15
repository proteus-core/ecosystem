#include "support.h"
#include "sharevalue.h"

#define S SPECIAL_SHARE

static int ids[] = {1, S, 3, S, 5, S, 7, S, 9, S};
static int qty[] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 100};

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) share_value(ids, qty, sizeof(ids) / sizeof(ids[0]));
}

int benchmark(void)
{
    return share_value(ids, qty, sizeof(ids) / sizeof(ids[0]));
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
