#include "triangle.h"

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
  results[0] = triangle(1, 2);
  results[1] = triangle(2, 1);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 7)
      && (results[1] == 3);
}
