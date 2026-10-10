struct Item {
	int values[2];
};

struct Item items[1] = {
	[0].values[2] = 1,
	[0].missing = 2
};

int main(void)
{
	return 0;
}