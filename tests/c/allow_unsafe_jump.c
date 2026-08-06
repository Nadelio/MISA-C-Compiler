#include <misa.h>

int main(void) {
    syscall(SYS_ALLOW_UNSAFE_JUMP);
    println_int(99);
    return 0;
}
