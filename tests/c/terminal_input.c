#include <misa.h>

char buf[256];

int main(void) {
    int size = get_terminal_input_size();
    println_int(size);
    if (size > 0) {
        int n = read_terminal_input(buf, size);
        println_string(buf);
        println_int(n);
    }
    return 0;
}
