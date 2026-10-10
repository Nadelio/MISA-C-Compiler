int first(int count, int values[count])
{
	typedef int Row[count];
	Row local;
	local[0] = values[0];
	return local[0];
}

int main(void)
{
	int values[2] = { 5, 6 };
	return first(2, values) == 5 ? 0 : 1;
}