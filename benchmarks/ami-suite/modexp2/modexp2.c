#include "modexp2.h"

#define MOD 7

int modexp2(int y, /* secret */ int k)
{
  int r = 1;

  for (int i = 0; i < (sizeof(int) * 8); i++)
  {
    /* Begin of sensitive region */

    if ((k % 2) == 1)
    {
      r = (r * y) % MOD;
    }

    /* End of sensitive region */

    y = (y * y) % MOD;
    k >>= 1;
  }

  return r % MOD;
}
