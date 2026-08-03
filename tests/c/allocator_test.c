#include "../../MISA Libraries/allocator.asm"

extern void* malloc(int);
extern void  free(void*);
extern void* realloc(void*, int);

int main(void) {
    void* mem_block = malloc(sizeof(int) * 2);
    free(mem_block);
    return 0;
}