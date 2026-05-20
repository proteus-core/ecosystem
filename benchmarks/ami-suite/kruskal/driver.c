#include "support.h"
#include "kruskal.h"

/* 5 vertices, 7 edges */
static int g[]  = {7, 1, 2, 2, 3, 4, 3, 4, 5, 1, 5, 1, 3, 4, 1};
static int mst[15];
static int par[15];

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) kruskal(g, mst, par, sizeof(g) / sizeof(g[0]));
}

int benchmark(void)
{
    return kruskal(g, mst, par, sizeof(g) / sizeof(g[0]));
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
