#include "switch.h"

static int results[17];

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
  results[ 0] = switch_case(0x0001);
  results[ 1] = switch_case(0x0002);
  results[ 2] = switch_case(0x0003);
  results[ 3] = switch_case(0x0004);
  results[ 4] = switch_case(0x0005);
  results[ 5] = switch_case(0x0006);
  results[ 6] = switch_case(0x0007);
  results[ 7] = switch_case(0x0008);
  results[ 8] = switch_case(0x0009);
  results[ 9] = switch_case(0x000a);
  results[10] = switch_case(0x000b);
  results[11] = switch_case(0x000c);
  results[12] = switch_case(0x000d);
  results[13] = switch_case(0x000e);
  results[14] = switch_case(0x000f);
  results[15] = switch_case(0x0010);

  /* None of the cases (there is no default) */
  results[16] = switch_case(0x0000);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[ 0] ==  1)
      && (results[ 1] ==  2)
      && (results[ 2] ==  3)
      && (results[ 3] ==  4)
      && (results[ 4] ==  5)
      && (results[ 5] ==  6)
      && (results[ 6] ==  7)
      && (results[ 7] ==  8)
      && (results[ 8] ==  9)
      && (results[ 9] == 10)
      && (results[10] == 11)
      && (results[11] == 12)
      && (results[12] == 13)
      && (results[13] == 14)
      && (results[14] == 15)
      && (results[15] == 16)
//      && (results[16] == 0xffffffff)
      ;
}
