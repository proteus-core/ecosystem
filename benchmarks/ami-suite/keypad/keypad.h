#ifndef KEYPAD_H
#define KEYPAD_H

#define PIN_LEN     4
#define NB_KEYS     16

void keypad_init(void);

int keypad_poll(void);

#endif
