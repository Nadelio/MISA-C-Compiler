inline int inline_only(int value)
{
	return value + 1;
}

extern inline int external_definition(int value)
{
	return value + 2;
}

int main(void)
{
	return inline_only(1) + external_definition(1) == 5 ? 0 : 1;
}