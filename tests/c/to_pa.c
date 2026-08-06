#include <misa.h>

void test2(char *s) { syscall(SYS_PRINT_STRING, to_pa(s)); }
