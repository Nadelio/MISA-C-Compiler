void test(void) {
    syscall(SYS_PRINT_INT, 42);
    syscall(SYS_DRAW_RECT, 10, 20, 100, 50, 15);
    int t = syscall(SYS_GET_INPUT);
}

int main(void) {
    test();
    return 0;
}
