#if !defined(__STDC__) || __STDC__ != 1
#error __STDC__ is missing
#endif

#if __STDC_VERSION__ != 199901L
#error wrong C standard version
#endif

#if !defined(__LINE__) || !defined(__FILE__) || !defined(__DATE__) || !defined(__TIME__)
#error required predefined macro is missing
#endif

_Pragma("MISA test pragma")

#define SUM(a, b) ((a) + \
(b))

#line 100 "virtual_source.c"
int main(void)
{
	char *file = __FILE__;
	char *date = __DATE__;
	char *time = __TIME__;
	int line = __LINE__;
	return SUM(file[0] == 'v', line == 105) == 2 && date[0] && time[0] ? 0 : 1;
}