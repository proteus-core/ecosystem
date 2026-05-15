#include "support.h"
#include "keypad.h"

void initialise_benchmark(void)
{
    keypad_init();
}

void warm_caches(int heat)
{
    int i;
    for (i = 0; i < heat; i++) {
        keypad_init();
        (void) keypad_poll();
    }
}

int benchmark(void)
{
    keypad_init();
    return keypad_poll();
}

int verify_benchmark(int result)
{
    (void) result;
    return -1;
}
