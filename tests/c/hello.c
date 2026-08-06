#include "../../MISA Libraries/printf.asm"

extern int printf(const char *fmt, ...);

void main(void) {
    printf("%s\n", "Hello, World!");
}