#include <misa.h>

int main(void) {
    int i = 5;
    do {
        println_int(i);
        i = i + 1;
    } while (i < 3);

    int j = 0;
    do {
        println_int(j);
        j = j + 1;
    } while (j < 3);

    return 0;
}
