struct Point {
	int x;
	int y;
};

int main(void)
{
	int scalar = (int){ 4 };
	int member = (struct Point){ .y = 7, .x = 3 }.y;
	int element = (int[]){ [2] = 9 }[2];
	return scalar + member + element == 20 ? 0 : 1;
}