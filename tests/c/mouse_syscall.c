#include "misa.h"

int main(void) {
    int x = syscall(SYS_GET_MOUSE_POSITION);
    int btn = syscall(SYS_GET_MOUSE_BUTTON_INPUT);
    println_int(x);
    println_int(btn);
    return 0;
}
