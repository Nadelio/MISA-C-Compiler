#include "types.h"

// arithmetic
u32t abs(i32t a);
i16t div(i16t numerator, i16t denominator);

// rng
void srand(u16t seed);
i16t rand(void);

// arrays
void qsort(void* array, u32t num_elements, u32t size_of_elements, i16t(*compare_fn)(const void* a, const void* b));

// string -> numeric
f32t atof(string str);
i16t atoi(string str); // ascii to int
i32t atol(string str); // ascii to long


// memory management
void* calloc(u32t count, u32t size); // not sure what the diff between count and size is ngl
void* malloc(u32t size);
void* realloc(void* block, u32t new_size);
void free(void* block);