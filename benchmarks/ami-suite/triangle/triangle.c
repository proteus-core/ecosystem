#include "triangle.h"

int triangle(/* secret */ int a, int b)
{
  int result = 3;

  /* Begin of sensitive region */

  if (a < b)
  {
    result = 7;
  }

  /* End of sensitive region */

  return result;
}
