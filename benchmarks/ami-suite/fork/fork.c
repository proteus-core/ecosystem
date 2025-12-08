#include "fork.h"

int fork(/* secret */ int a, int b)
{
  int result = 3;

  /* Begin of sensitive region */

  if (a < b)
  {
    result = a + 2;
  }

  /* End of sensitive region */

  return result;
}
