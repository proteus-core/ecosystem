#include "bsl.h"

#define LOCKED   0x00
#define UNLOCKED 0xA5A4
static unsigned LockedStatus = LOCKED;

/*
 * The C code below is based on the invulnerable password comparison routine of
 *  the latest TI BSL v9.
 */

/*******************************************************************************
*Function:    BSL430_unlock_BSL
*Description: Causes the BSL to compare the data buffer against the BSL password
*             BSL state will be UNLOCKED if successful
*Parameters:
*             char* data           A pointer to an array containing the password
*Returns:
*             SUCCESSFUL_OPERATION  All data placed into data array successfully
*             BSL_PASSWORD_ERROR    Correct Password was not given
*******************************************************************************/
char BSL430_unlock_BSL(/* secret */ char * data)
{
  int    i;
  int    retValue = 0;
  int    result;

#if 0
  const char * ivt = (char *) INTERRUPT_VECTOR_START;
#else
  const char * ivt = "0123456789ABCDEF";
#endif

  for (i=0; i <= (INTERRUPT_VECTOR_END - INTERRUPT_VECTOR_START); i++, ivt++)
  {
#ifdef V2_2_09
  /* To prevent timing side-channels, versions from v2.2.09 onwards uses a
   * password comparison loop based on XOR, as recommended in Goodspeed2008 to
   * prevent timing side-channels. */
    retValue |=  *ivt ^ data[i];
#else
   /* This vulnerable version is based on published asm code from v2.12.
    * as explained in
    * https://github.com/jovanbulck/nemesis/blob/master/sancus/bsl/sm-bsl.c */

    /* Begin of sensitive region */

    if (*ivt != data[i])
    {
      retValue |= 0x40;
    }

    /* End of sensitive region */

#endif
  }

  if (retValue == 0)
  {
    LockedStatus = UNLOCKED;

    result = SUCCESSFUL_OPERATION;
  }
  else
  {
    LockedStatus = LOCKED;

    result = BSL_PASSWORD_ERROR;
  }

  return result;
}
