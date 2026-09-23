#include <misa.h>
#include "bad_extern.asm"

extern void foo.somevar();

int main(void) {
    foo.somevar();
    return 0;
}