static inline int increment(int value);
static inline int increment(int value)
{
	return value + 1;
}

int main(void)
{
	return increment(4) == 5 ? 0 : 1;
}