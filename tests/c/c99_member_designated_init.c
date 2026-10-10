struct Point {
	int x;
	int y;
};

union Number {
	int small;
	long large;
};

struct Point global_point = { .y = 9, .x = 4 };
union Number global_number = { .large = 12 };

int main(void)
{
	struct Point local_point = { .y = 7, .x = 3 };
	return global_point.x + global_point.y + global_number.large +
	       local_point.x + local_point.y == 35 ? 0 : 1;
}