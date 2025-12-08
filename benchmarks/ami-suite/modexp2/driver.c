#include "modexp2.h"

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
  results[0] = modexp2(10, 1);
  results[1] = modexp2(10, 15);
  results[2] = modexp2(10, 42);
  results[3] = modexp2(10, 142);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 3)
      && (results[1] == 6)
      && (results[2] == 1)
      && (results[3] == 4);
}
