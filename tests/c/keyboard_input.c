#include "misa.h"

int main(void) {
    int state = BTN_A | BTN_START;
    int mask = KBE_PRESSED | KBE_SHIFT;
    int key = KEY_LEFT;
    int mouse = MOUSE_BTN_LEFT | MOUSE_BTN_RIGHT;

    if (state && mask && key && mouse) {
        return 1;
    }

    return 0;
}
