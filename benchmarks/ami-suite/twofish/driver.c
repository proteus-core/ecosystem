#include "support.h"
#include <stdint.h>
#include "twofish.h"

static uint8_t key[16] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
};

void initialise_benchmark(void) {}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++)
        twofish_key_schedule(key, sizeof(key) / sizeof(key[0]));
}

int benchmark(void)
{
    twofish_key_schedule(key, sizeof(key) / sizeof(key[0]));
    return 0;
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
