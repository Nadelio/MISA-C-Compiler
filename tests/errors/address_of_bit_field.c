struct Flags {
	unsigned int enabled : 1;
};

int main(void)
{
	struct Flags flags = { 0 };
	unsigned int *pointer = &flags.enabled;
	return pointer != 0;
}
