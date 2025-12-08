#include "ifthenloop.h"

static int v;

__attribute__((noinline))
static void foo(int i)
{
  v++;
}

/* secret */ int ifthenloop(/* secret */ int a, int b)
{
  v = 0;

  /* Begin of sensitive region */

  if (a < b)
  {
    int i;

    #pragma clang loop unroll(disable)
    for (i=0; i<3; i++)
    {
      foo(i);
    }
  }

  /* End of sensitive region */

  return v;
}
