#include "ifthenloop.h"

static int results[2];

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
  results[0] = ifthenloop(1, 2);
  results[1] = ifthenloop(2, 1);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 3)
      && (results[1] == 0);
}
