struct Pair {
	int left;
	int right;
};

struct Pair *pair = &(struct Pair){ .left = 4, .right = 8 };
int *values = (int[]){ 3, 5, 7 };

int main(void)
{
	return pair->left == 4 && pair->right == 8 && values[2] == 7 ? 0 : 1;
}