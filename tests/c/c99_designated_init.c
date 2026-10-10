enum { OFFSET = 1 };

int global_values[6] = { [OFFSET + 1] = 7, [2 * 2 + 1] = 9 };
int inferred_values[] = { [1 << 1 | 1] = 4 };

int main(void)
{
	int local_values[5] = { [1] = 3, 8, [4] = 9 };
	return global_values[2] + global_values[5] +
	       inferred_values[3] + local_values[1] +
	       local_values[2] + local_values[4] == 40 ? 0 : 1;
}