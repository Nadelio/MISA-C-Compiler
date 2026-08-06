#include <misa.h>

#define PI_APPROX  3
#define DOUBLE(x)  ((x) + (x))

#define MAX(a, b)  ((a) > (b) ? (a) : (b))
#define MIN(a, b)  ((a) < (b) ? (a) : (b))
#define ABS(x)     ((x) < 0 ? -(x) : (x))
#define SQUARE(x)  ((x) * (x))
#define CLAMP(v, lo, hi) (MAX(MIN((v), (hi)), (lo)))

#define STRINGIFY(x) #x

#define MAKE_VAR(prefix, n) prefix##n

#define FEATURE_A
#undef  FEATURE_B

#ifdef FEATURE_A
#define FEATURE_A_VALUE 10
#else
#define FEATURE_A_VALUE 0
#endif

#ifndef FEATURE_B
#define FEATURE_B_VALUE 20
#else
#define FEATURE_B_VALUE 0
#endif

#define VERSION 2

#if VERSION == 1
#define VERSION_STR "v1"
#elif VERSION == 2
#define VERSION_STR "v2"
#else
#define VERSION_STR "unknown"
#endif

#define OUTER
#define INNER

#ifdef OUTER
#ifdef INNER
#define NESTED_RESULT 42
#else
#define NESTED_RESULT 0
#endif
#else
#define NESTED_RESULT 0
#endif

#if defined(FEATURE_A) && !defined(FEATURE_B)
#define COMBO 99
#else
#define COMBO 0
#endif

int main(void) {
    int MAKE_VAR(x, 0);
    int MAKE_VAR(x, 1);

    println_int(PI_APPROX);
    println_int(DOUBLE(7));

    println_int(MAX(3, 5));
    println_int(MIN(3, 5));
    println_int(ABS(-9));
    println_int(SQUARE(6));
    println_int(CLAMP(15, 0, 10));
    println_int(CLAMP(-5, 0, 10));

    x0 = 3;
    println_int(SQUARE(x0));

    println_int(FEATURE_A_VALUE);
    println_int(FEATURE_B_VALUE);

    println_string(VERSION_STR);

    println_int(NESTED_RESULT);

    println_int(COMBO);

    x1 = 77;
    println_int(x1);

    println_string(STRINGIFY(hello));

    return 0;
}
