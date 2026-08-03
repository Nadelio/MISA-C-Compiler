unsigned char __code[4];

int main() {
    __code[0] = 0;
    __code[1] = 0xA;
    __code[2] = 0;
    __code[3] = 0; // this code will fail because there is not ret instruction
    void (*print_int)(int a) = __code;
    print_int(42);
    return 0;
}