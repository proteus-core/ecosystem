#include "kruskal.h"
#include <string.h>

static int results[2];

/* 5 vertices, 7 edges */
static int g1[] = {7, 1, 2, 2, 3, 4, 3, 4, 5, 1, 5, 1, 3, 4, 1};

/* 7 vertices, 7 edges */
static int g2[] = {7, 1, 2, 4, 3, 4, 5, 7, 5, 7, 1, 6, 2, 2, 4};

static int mst1[sizeof(g1)];
static int mst2[sizeof(g1)];
static int par[sizeof(g1)];

static int expect1[] = {4, 1, 2, 2, 3, 4, 3, 3, 5};
static int expect2[] = {6, 1, 2, 4, 3, 3, 5, 7, 5, 5, 6, 2, 2};

void __attribute__ ((noinline))
initialise_benchmark (void)
{
}

void __attribute__ ((noinline))
warm_caches (int  heat)
{
}

int __attribute__ ((noinline))
benchmark (void)
{
  results[0] = kruskal(g1, mst1, par, sizeof(g1)/sizeof(g1[0]));
  results[1] = kruskal(g2, mst2, par, sizeof(g2)/sizeof(g2[0]));

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 4)
      && (results[1] == 6)
      && (memcmp(mst1, expect1, sizeof(expect1)) == 0)
      && (memcmp(mst2, expect2, sizeof(expect2)) == 0);
}
