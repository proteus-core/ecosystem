#ifndef twofish_H
#define twofish_H

#include <stdint.h>

void twofish_key_schedule(/* secret */ const uint8_t key[], int length);

#endif
