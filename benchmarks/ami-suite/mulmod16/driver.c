#include "mulmod16.h"

static int results[5];

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
  results[0] = mulmod16(0, 9114);
  results[1] = mulmod16(7906, 0);
  results[2] = mulmod16(7, 8);
  results[3] = mulmod16(267, 13853);
  results[4] = mulmod16(13853, 267);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 56423)
      && (results[1] == 57631)
      && (results[2] == 56)
      && (results[3] == 28679)
      && (results[4] == 28679);
}
