int g_count;

int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    int i;
    int result;
    g_count = 0;
    for (i = 0; i < 8; i = i + 1) {
        result = fib(i);
        g_count = g_count + 1;
    }
    return result;
}
