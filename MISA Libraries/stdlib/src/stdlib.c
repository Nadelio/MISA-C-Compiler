#include "../include/stdlib.h"
#include "rng.asm"

// rng

extern void srand(u16t seed);
extern i16t rand(void);

// arithmetic

u32t abs(i32t a) {
    return a < 0 ? (u32t)(-a) : (u32t)a;
}

i16t div(i16t numerator, i16t denominator) {
    return numerator / denominator;
}

// arrays

static void _swap(u8t *a, u8t *b, u32t sz) {
    u32t i;
    u8t tmp;
    for (i = 0; i < sz; i++) {
        tmp = a[i]; a[i] = b[i]; b[i] = tmp;
    }
}

static void _qsort_r(u8t *base, u32t lo, u32t hi, u32t sz,
                     i16t (*cmp)(const void *, const void *)) {
    u32t i, j;
    if (lo >= hi) return;
    i = lo;
    for (j = lo; j < hi; j++) {
        if (cmp(base + j * sz, base + hi * sz) <= 0) {
            _swap(base + i * sz, base + j * sz, sz);
            i++;
        }
    }
    _swap(base + i * sz, base + hi * sz, sz);
    if (i > lo) _qsort_r(base, lo, i - 1, sz, cmp);
    _qsort_r(base, i + 1, hi, sz, cmp);
}

void qsort(void *array, u32t num_elements, u32t size_of_elements,
           i16t (*compare_fn)(const void *a, const void *b)) {
    if (num_elements < 2) return;
    _qsort_r((u8t *)array, 0, num_elements - 1, size_of_elements, compare_fn);
}

// string -> numeric

static i16t _sp(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r'; }
static i16t _dg(char c) { return c >= '0' && c <= '9'; }

i16t atoi(string str) {
    i16t result = 0;
    i16t neg = 0;
    while (_sp(*str)) str++;
    if (*str == '-') { neg = 1; str++; } else if (*str == '+') str++;
    while (_dg(*str)) result = result * 10 + (*str++ - '0');
    return neg ? -result : result;
}

i32t atol(string str) {
    i32t result = 0;
    i16t neg = 0;
    while (_sp(*str)) str++;
    if (*str == '-') { neg = 1; str++; } else if (*str == '+') str++;
    while (_dg(*str)) result = result * 10 + (*str++ - '0');
    return neg ? -result : result;
}

f32t atof(string str) {
    f32t result = 0.0;
    f32t frac = 0.1;
    i16t neg = 0;
    i16t in_frac = 0;
    while (_sp(*str)) str++;
    if (*str == '-') { neg = 1; str++; } else if (*str == '+') str++;
    while (*str) {
        if (*str == '.') { in_frac = 1; str++; continue; }
        if (!_dg(*str)) break;
        if (in_frac) { result += (*str - '0') * frac; frac *= 0.1; }
        else result = result * 10.0 + (*str - '0');
        str++;
    }
    return neg ? -result : result;
}

// memory management

void *calloc(u32t count, u32t size) {
    u32t total = count * size;
    void *ptr = malloc(total);
    if (ptr) mem_set(ptr, total, 0);
    return ptr;
}
