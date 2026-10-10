int bound;
typedef int FileVla[bound];

int main(void)
{
	int count = 3;
	static int static_vla[count];
	extern int extern_vla[count];
	return 0;
}