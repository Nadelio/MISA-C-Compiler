#include "misa.h"

int global_x = 100;
char *greeting;

int max(int a, int b) {
    if (a > b) return a;
    return b;
}

int sum_array(int *arr, int size) {
    int i;
    int s;
    s = 0;
    for (i = 0; i < size; i = i + 1) {
        s = s + arr[i];
    }
    return s;
}

char foo[3] = { 0, 1 };

int main() {
    int arr[5] = { 1, 2, 3, 3 }; // array initializer
    int result;
    greeting = "hello";
    arr[3] = 4;
    result = sum_array(arr, 4);
    println_string(greeting);
    println_int(result);
    return max(result, global_x);
}
