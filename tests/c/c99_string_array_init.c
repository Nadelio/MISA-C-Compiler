char global_text[] = "abc";

int main(void)
{
	char local_text[4] = "xy";
	return global_text[3] == 0 && local_text[0] == 'x' &&
	       local_text[1] == 'y' && local_text[2] == 0 ? 0 : 1;
}