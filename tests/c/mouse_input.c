#include <misa.h>

int main(void) {
    int x = get_mouse_x();
    int y = get_mouse_y();
    int btn = get_mouse_button_input();
    println_int(x);
    println_int(y);
    if (btn & MOUSE_BTN_LEFT)   println_int(MOUSE_BTN_LEFT);
    if (btn & MOUSE_BTN_RIGHT)  println_int(MOUSE_BTN_RIGHT);
    if (btn & MOUSE_BTN_MIDDLE) println_int(MOUSE_BTN_MIDDLE);
    if (btn & MOUSE_BTN_WHEEL_UP)   println_int(MOUSE_BTN_WHEEL_UP);
    if (btn & MOUSE_BTN_WHEEL_DOWN) println_int(MOUSE_BTN_WHEEL_DOWN);
    return 0;
}
