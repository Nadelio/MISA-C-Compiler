int global_x = 100;
char *greeting;

int max(int a, int b) {
    if (a > b) return a;
    return b;
}

int sum_array(int *arr, int n) {
    int i;
    int s;
    s = 0;
    for (i = 0; i < n; i = i + 1) {
        s = s + arr[i];
    }
    return s;
}

int main() {
    int arr[4];
    int result;
    greeting = "hello";
    arr[0] = 1;
    arr[1] = 2;
    arr[2] = 3;
    arr[3] = 4;
    result = sum_array(arr, 4);
    return max(result, global_x);
}
