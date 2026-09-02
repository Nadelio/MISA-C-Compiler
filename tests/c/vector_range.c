#include <misa.h>

int main() {
    float a[3] = { 1.0, 2.0, 3.0 };
    float b[3] = { 4.0, 5.0, 6.0 };
    float c[3];
    c[0] = a[0] + b[0];
    c[1] = a[1] + b[1];
    c[2] = a[2] + b[2];
    
    println_float(c[0], 2);
    println_float(c[1], 2);
    println_float(c[2], 2);
    return 0;
}
