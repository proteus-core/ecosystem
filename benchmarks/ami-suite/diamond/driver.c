#include "diamond.h"

static int results[4];

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
  results[0] = diamond(1, 1);
  results[1] = diamond(1, 2);
  results[2] = diamond(2, 1);
  results[3] = diamond(2, 10);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 0)
      && (results[1] == 3)
      && (results[2] == 7)
      && (results[3] == 12);
}
