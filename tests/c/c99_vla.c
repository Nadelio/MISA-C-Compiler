int sum(int count)
{
	int values[count];
	int bytes = sizeof values;
	count = 1;
	for (int index = 0; index < bytes / sizeof(int); index++)
		values[index] = index + 1;
	return values[0] + values[2] + bytes;
}

int main(void)
{
	return sum(3) == 10 ? 0 : 1;
}