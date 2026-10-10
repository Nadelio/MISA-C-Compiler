int main(void)
{
	int index = 1;
	int values[2] = { [index] = 1 };
	return values[1];
}