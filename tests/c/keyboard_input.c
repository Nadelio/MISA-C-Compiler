#include "misa.h"

int input = 0;

void keyboard_input(void) {
    input = get_keyboard_input();
    if (input == KEY_ESC) {
        println_string("ESCAPED!");
    }
    exit();
}

int main(void) {
    return 0;
}
