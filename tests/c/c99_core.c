#include <stdbool.h>
#include <stdint.h>

#define ADD(first, ...) ((first) + (__VA_ARGS__))

struct Packet {
	int length;
	char data[];
};

static inline _Bool has_data(const char * restrict data)
{
	return data != 0;
}

int main(void)
{
	long count = 0;
	float exact = 0x1.8p+1f;
	uint32_t width = UINT32_C(32);
	count += ADD(has_data(__func__), width == 32);
	return count == 2 && exact == 3.0f ? 0 : 1;
}