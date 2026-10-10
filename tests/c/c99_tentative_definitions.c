int counter;
int counter;
int counter = 7;

extern int total;
int total;

static int internal_value;
extern int internal_value;

int main(void)
{
	return counter == 7 && total == 0 && internal_value == 0 ? 0 : 1;
}