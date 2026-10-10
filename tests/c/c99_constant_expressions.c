enum Values {
	BASE = 2,
	SHIFTED = (BASE + 1) << 2,
	CHOSEN = SHIFTED > 10 ? SHIFTED : 10
};

static int global_value = CHOSEN + sizeof(char);
static int values[(BASE * 2) + 1] = { [CHOSEN / 4] = BASE + 5 };

int main(void)
{
	switch (global_value) {
	case (3 * 4) + 1:
		return values[3] == 7 ? 0 : 1;
	default:
		return 2;
	}
}