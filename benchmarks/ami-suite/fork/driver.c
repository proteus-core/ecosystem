#include "fork.h"

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
  results[0] = fork(2, 3);
  results[1] = fork(3, 2);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 4)
      && (results[1] == 3);
}
