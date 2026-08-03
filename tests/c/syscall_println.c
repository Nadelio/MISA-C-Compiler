void test_string(char *s) {
    syscall(SYS_PRINT_LINE_STRING, to_pa(s));
}

int main(void) {
    syscall(SYS_PRINT_LINE_INT, 42);
    syscall(SYS_PRINT_LINE_FLOAT, 3.14, 2);
    test_string("hello");
    return 0;
}
