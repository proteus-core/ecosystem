#include "lookup.h"

int lookup_val(/* secret */ int id)
{
  if (id < 10)
  {
    return 2 * (id + 1);
  }

  return 7;
}
