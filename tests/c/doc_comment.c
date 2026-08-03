int x = 0;

/// @brief This prints "foo" to the console
/// @details This also increments the global variable X
void foo() {
    print_string("foo");
    x++;
    return;
}

/// @brief prints the given number `a`
/// @param a some number
/// @return The sum of the global variable `x` and `a`
/// @details This function also increments the global variable x
int beep(int a) {
    print_int(a);
    x++;
    return x + a;
}

/// @brief prints `a` first, then `message`
/// @param a 
/// @param message 
void multiple_params(int a, char* message) {
    print_int(a);
    print_string(message);
    return;
}