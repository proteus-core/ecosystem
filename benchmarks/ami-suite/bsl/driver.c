#include "bsl.h"

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
  static char password[BSL_PASSWORD_LENGTH] = "0123456789ABCDEF";

  results[0] = BSL430_unlock_BSL(password);

  password[2] = 'X';
  results[1] = BSL430_unlock_BSL(password);

  password[7] = 'X';
  password[8] = 'X';
  results[2] = BSL430_unlock_BSL(password);

  password[10] = 'X';
  password[11] = 'X';
  results[3] = BSL430_unlock_BSL(password);
  
  password[2] = '2';
  password[7] = '7';
  password[8] = '8';
  password[10] = 'A';
  password[11] = 'B';
  results[4] = BSL430_unlock_BSL(password);

  return 0;
}

int __attribute__ ((noinline))
verify_benchmark (int r)
{
  return (results[0] == SUCCESSFUL_OPERATION)
      && (results[1] == BSL_PASSWORD_ERROR)
      && (results[2] == BSL_PASSWORD_ERROR)
      && (results[3] == BSL_PASSWORD_ERROR)
      && (results[4] == SUCCESSFUL_OPERATION);
}
