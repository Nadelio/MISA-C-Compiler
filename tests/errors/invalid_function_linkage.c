int duplicate(void)
{
	return 1;
}

int duplicate(void)
{
	return 2;
}

extern int conflict(void);
static int conflict(void);

inline int object;

int main(void)
{
	return 0;
}