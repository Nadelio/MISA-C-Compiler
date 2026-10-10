struct Shared;
int inspect(struct Shared *value);

struct Shared {
	int value;
};

int inspect(struct Shared *value)
{
	return value->value;
}

int main(void)
{
	struct Shared value = { 9 };
	return inspect(&value) == 9 ? 0 : 1;
}