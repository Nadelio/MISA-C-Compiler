unsigned char __code[4];

int main() {
    __code[0] = 6;
    __code[1] = 0;
    __code[2] = 0;
    __code[3] = 2;
    void (*print_int)(int a) = __code;
    print_int(42);
    return 0;
}