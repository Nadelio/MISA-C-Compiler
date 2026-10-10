struct Cell {
	int value;
};

struct Row {
	struct Cell cells[3];
};

struct Row global_rows[2] = {
	[1].cells[2].value = 17
};

int main(void)
{
	struct Row local_row = {
		.cells[1].value = 9
	};
	return global_rows[1].cells[2].value == 17 &&
	       local_row.cells[1].value == 9 ? 0 : 1;
}