#include <limits.h>

int main(void)
{
	unsigned short us = USHRT_MAX;
	unsigned int ui = 1U;
	long sl = -1L;
	unsigned long ul = 1UL;

	if (sizeof(32767) != sizeof(int)) return 1;
	if (sizeof(32768) != sizeof(long)) return 2;
	if (sizeof(65535U) != sizeof(unsigned int)) return 3;
	if (sizeof(65536U) != sizeof(unsigned long)) return 4;
	if (sizeof(1.0) != sizeof(double)) return 5;
	if (sizeof(1.0f) != sizeof(float)) return 6;
	if (077 != 63) return 7;
	ui = us + us;
	sl = ui + sl;
	ul = sl + ul;
	return 0;
}
