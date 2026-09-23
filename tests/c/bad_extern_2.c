#include <misa.h>
#include "bad_extern_2.asm"

extern unsigned int foo.somefunc;

int main(void) {
    return foo.somefunc;
}