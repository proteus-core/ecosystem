#include "keypad.h"

#include <stdint.h>

typedef uint16_t key_state_t;

static int         count     = 0;
static key_state_t key_state = 0;
static int         pin_idx   = 0;
static int         keymap[NB_KEYS] =
  {'1','4','7','0','2','5','8','F','3','6','9','E','A','B','C','D'};

/* Put the pin in a dedicated section so that it can be found when evaluating
 * the correctness of the hardened forms.
 */
static volatile char pin[PIN_LEN];

static key_state_t read_key_state()
{
  key_state_t result;

  switch (count++)
  {
    case 0: result = 0x00; break;
    case 1: result = 0x01; break;
    case 2: result = 0x01; break;
    case 3: result = 0x00; break;
    case 4: result = 0x02; break;
    case 5: result = 0x00; break;
    case 6: result = 0x04; break;
    case 7: result = 0x00; break;
    case 8: result = 0x08; break;
    case 9: result = 0x00; break;
    case 10: result = 0x10; break;

    default: result = 0x00; break;
  }

  return result;
}

void keypad_init(void)
{
  count     = 0;
  key_state = 0;
  pin_idx   = 0;
}

/*
 * The start-to-end timing of this function only reveals the number of times the
 * if statement was executed (i.e. the number of keys that were down), which is
 * also explicitly returned. By carefully interrupting the function each for
 * loop iteration, an untrusted ISR can learn the value of the secret PIN code.
 */
int keypad_poll(void)
{
  int key_mask = 0x1;

  key_state_t new_key_state = read_key_state();

  /* Store down keys in private PIN array. */
  for (int key = 0; key < NB_KEYS; key++)
  {
    int is_pressed  = (new_key_state & key_mask);
    int was_pressed = (key_state & key_mask);

    /* Begin of sensitive region */

    if ( is_pressed /* INTERRUPT SHOULD ARRIVE HERE */
         && !was_pressed && (pin_idx < PIN_LEN))
    {
      pin[pin_idx++] = keymap[key];
    }
    /* .. OR HERE. */

    /* End of sensitive region */

    key_mask = key_mask << 1;
  }

  key_state = new_key_state;

  return (PIN_LEN - pin_idx);
}
