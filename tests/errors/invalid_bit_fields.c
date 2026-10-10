struct Invalid {
	float floating : 2;
	unsigned int too_wide : 17;
	unsigned int named_zero : 0;
	unsigned int negative : -1;
};

int main(void)
{
	return 0;
}