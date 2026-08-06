#include <misa.h>

int main(void) {
    char* test = "Hello, World!";
    println_string(test);
    println_int(0);
    println_float(0.0f);
    print_string(test);
    print_int(0);
    print_float(0);
    return 0;
}