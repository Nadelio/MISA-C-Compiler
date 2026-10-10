int main(void)
{
	float _Complex first;
	double _Complex second;
	return sizeof(first) == 8 && sizeof(second) == 8 ? 0 : 1;
}