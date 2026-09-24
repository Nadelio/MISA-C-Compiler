#include <misa.h>
#include <types.h>
#include "../src/graphics.asm"

extern u8t get_pixel(i32t x, i32t y);
extern void set_pixel(i32t x, i32t y, u8t luma);
extern float normalize_luma(u8t luma);
extern u8t denormalize_luma(float value);