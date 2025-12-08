#include "sharevalue.h"
#include "lookup.h"

int share_value(/* secret */ int ids[], int qty[], int len)
{
  int share_val = 0;
  int i = 0;

  while (i < len) 
  {
    int id = ids[i];

    /* Begin of sensitive region */

    if (id == SPECIAL_SHARE)
    {
      int val = lookup_val(id) * qty[i];

      share_val = share_val + val;
    }

    /* End of sensitive region */

    i++;
  }

  return share_val;
}
