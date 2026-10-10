struct Nested {
	int values[2];
	struct {
		int left;
		int right;
	} pair;
};

struct Nested global_nested = { 1, 2, 3, 4 };

int main(void)
{
	struct Nested local_nested = { 5, 6, 7, 8 };
	return global_nested.values[1] == 2 && global_nested.pair.right == 4 &&
	       local_nested.values[0] == 5 && local_nested.pair.left == 7 ? 0 : 1;
}