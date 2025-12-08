#include "keypad.h"

static int results[11];

void __attribute__ ((noinline))
initialise_benchmark (void)
{
  keypad_init();
}

void __attribute__ ((noinline))
warm_caches (int  heat)
{
}

int __attribute__ ((noinline))
benchmark (void)
{
  /* With the current mockup, calling keypad_poll ten times in a row
   * covers the full range of execution times.
   */
  results[0] = keypad_poll();
  results[1] = keypad_poll();
  results[2] = keypad_poll();
  results[3] = keypad_poll();
  results[4] = keypad_poll();
  results[5] = keypad_poll();
  results[6] = keypad_poll();
  results[7] = keypad_poll();
  results[8] = keypad_poll();
  results[9] = keypad_poll();

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == 4)
      && (results[1] == 3)
      && (results[2] == 3)
      && (results[3] == 3)
      && (results[4] == 2)
      && (results[5] == 2)
      && (results[6] == 1)
      && (results[7] == 1)
      && (results[8] == 0)
      && (results[9] == 0);
}
