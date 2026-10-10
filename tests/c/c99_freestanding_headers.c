#include <float.h>
#include <iso646.h>
#include <limits.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

static int sum(int count, ...)
{
	va_list arguments;
	int result = 0;
	va_start(arguments, count);
	while (count-- > 0)
		result += va_arg(arguments, int);
	va_end(arguments);
	return result;
}

int main(void)
{
	bool ranges = CHAR_BIT == 8 and INT_MAX == INT16_MAX and
	              sizeof(size_t) == sizeof(void *) and FLT_RADIX == 2;
	return ranges && sum(3, 4, 5, 6) == 15 ? 0 : 1;
}