#include "sharevalue.h"

#define S SPECIAL_SHARE

static int results[3];

static int ids1[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
static int ids2[] = {1, S, 3, S, 5, S, 7, S, 9, S};
static int ids3[] = {S, S, S, S, S, S, S, S, S, S};
static int qty[]  = {10, 9, 8, 7, 6, 5, 4, 3, 2, 100};

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
  (void) share_value(ids1, qty, sizeof(ids1)/sizeof(ids1[0]));
  (void) share_value(ids2, qty, sizeof(ids2)/sizeof(ids2[0]));
  (void) share_value(ids3, qty, sizeof(ids3)/sizeof(ids3[0]));

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 7)
      && (results[1] == 868)
      && (results[2] == 1078);
}
