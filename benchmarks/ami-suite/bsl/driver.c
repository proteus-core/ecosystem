#include "support.h"
#include "bsl.h"

static char password[BSL_PASSWORD_LENGTH] = "0123456789ABCDEF";

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        (void) BSL430_unlock_BSL(password);
}

int benchmark(void)
{
    return (int) BSL430_unlock_BSL(password);
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
