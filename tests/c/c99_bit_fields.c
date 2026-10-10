struct Flags {
	unsigned int low : 3;
	unsigned int high : 5;
	unsigned int : 0;
	signed int delta : 4;
};

struct Flags global_flags = { .high = 6, .low = 2, .delta = -1 };

int main(void)
{
	struct Flags flags = { 1, 2, -2 };
	struct Flags *pointer = &flags;
	if (global_flags.low != 2 || global_flags.high != 6 || global_flags.delta != -1)
		return 1;
	if (flags.low != 1 || flags.high != 2 || flags.delta != -2)
		return 1;
	flags.low = 5;
	pointer->high = 17;
	flags.delta = -3;
	return sizeof(struct Flags) == 4 && flags.low == 5 &&
	       flags.high == 17 && flags.delta == -3 ? 0 : 1;
}