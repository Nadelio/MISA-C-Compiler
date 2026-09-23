#include <misa.h>
#include <mfs/mfs.h>

#define TEXT_CAPACITY 2048
#define GLYPH_WIDTH 5
#define GLYPH_HEIGHT 7
#define CELL_WIDTH 6
#define CELL_HEIGHT 9
#define TEXT_X 7
#define TEXT_Y 20
#define VISIBLE_ROWS 24
#define FILE_ROWS 20

#define LUMA_BACKGROUND 18
#define LUMA_HEADER 42
#define LUMA_TEXT 230
#define LUMA_MUTED 145
#define LUMA_CURSOR 255

char text[TEXT_CAPACITY];
char filename[64];
int text_length = 0;
int cursor = 0;
int top_line = 0;
int previous_mouse_buttons = 0;
int filesystem_ready = 0;
int save_failed = 0;
int file_picker = 0;
int file_count = 0;
int selected_file = 0;
int first_file = 0;
char listed_filename[64];

unsigned char font[480] = {
	0,0,0,0,0, 0,0,95,0,0, 0,7,0,7,0, 20,127,20,127,20,
	36,42,127,42,18, 35,19,8,100,98, 54,73,85,34,80, 0,5,3,0,0,
	0,28,34,65,0, 0,65,34,28,0, 20,8,62,8,20, 8,8,62,8,8,
	0,80,48,0,0, 8,8,8,8,8, 0,96,96,0,0, 32,16,8,4,2,
	62,81,73,69,62, 0,66,127,64,0, 66,97,81,73,70, 33,65,69,75,49,
	24,20,18,127,16, 39,69,69,69,57, 60,74,73,73,48, 1,113,9,5,3,
	54,73,73,73,54, 6,73,73,41,30, 0,54,54,0,0, 0,86,54,0,0,
	8,20,34,65,0, 20,20,20,20,20, 0,65,34,20,8, 2,1,81,9,6,
	50,73,121,65,62, 126,17,17,17,126, 127,73,73,73,54, 62,65,65,65,34,
	127,65,65,34,28, 127,73,73,73,65, 127,9,9,9,1, 62,65,73,73,122,
	127,8,8,8,127, 0,65,127,65,0, 32,64,65,63,1, 127,8,20,34,65,
	127,64,64,64,64, 127,2,12,2,127, 127,4,8,16,127, 62,65,65,65,62,
	127,9,9,9,6, 62,65,81,33,94, 127,9,25,41,70, 70,73,73,73,49,
	1,1,127,1,1, 63,64,64,64,63, 31,32,64,32,31, 63,64,56,64,63,
	99,20,8,20,99, 7,8,112,8,7, 97,81,73,69,67, 0,127,65,65,0,
	2,4,8,16,32, 0,65,65,127,0, 4,2,1,2,4, 64,64,64,64,64,
	0,1,2,4,0, 32,84,84,84,120, 127,72,68,68,56, 56,68,68,68,32,
	56,68,68,72,127, 56,84,84,84,24, 8,126,9,1,2, 12,82,82,82,62,
	127,8,4,4,120, 0,68,125,64,0, 32,64,68,61,0, 127,16,40,68,0,
	0,65,127,64,0, 124,4,24,4,120, 124,8,4,4,120, 56,68,68,68,56,
	124,20,20,20,8, 8,20,20,24,124, 124,8,4,4,8, 72,84,84,84,32,
	4,63,68,64,32, 60,64,64,32,124, 28,32,64,32,28, 60,64,48,64,60,
	68,40,16,40,68, 12,80,80,80,60, 68,100,84,76,68, 0,8,54,65,0,
	0,0,127,0,0, 0,65,54,8,0, 8,4,8,16,8, 0,0,0,0,0
};

int line_start(int position) {
	while (position > 0 && text[position - 1] != '\n')
		position--;
	return position;
}

int next_line(int position) {
	while (position < text_length && text[position] != '\n')
		position++;
	if (position < text_length)
		position++;
	return position;
}

int previous_line(int position) {
	position = line_start(position);
	if (position == 0)
		return 0;
	return line_start(position - 1);
}

int cursor_column(void) {
	return cursor - line_start(cursor);
}

int position_on_line(int start, int column) {
	int position = start;
	while (position < text_length && text[position] != '\n' && column > 0) {
		position++;
		column--;
	}
	return position;
}

void keep_cursor_visible(void) {
	int row;
	int position;
	if (cursor < top_line)
		top_line = line_start(cursor);
	row = 0;
	position = top_line;
	while (position < cursor && row < VISIBLE_ROWS) {
		if (text[position] == '\n')
			row++;
		position++;
	}
	while (row >= VISIBLE_ROWS) {
		top_line = next_line(top_line);
		row--;
	}
}

void insert_character(int character) {
	int index;
	if (text_length >= TEXT_CAPACITY - 1)
		return;
	index = text_length;
	while (index > cursor) {
		text[index] = text[index - 1];
		index--;
	}
	text[cursor] = character;
	text_length++;
	cursor++;
	text[text_length] = 0;
	save_failed = 0;
	keep_cursor_visible();
}

void erase_before_cursor(void) {
	int index;
	if (cursor == 0)
		return;
	index = cursor - 1;
	while (index < text_length) {
		text[index] = text[index + 1];
		index++;
	}
	cursor--;
	text_length--;
	save_failed = 0;
	keep_cursor_visible();
}

void erase_at_cursor(void) {
	int index;
	if (cursor >= text_length)
		return;
	index = cursor;
	while (index < text_length) {
		text[index] = text[index + 1];
		index++;
	}
	text_length--;
	save_failed = 0;
}

int shifted_character(int character) {
	if (character >= 'a' && character <= 'z')
		return character - 32;
	if (character == '1') return '!';
	if (character == '2') return '@';
	if (character == '3') return '#';
	if (character == '4') return '$';
	if (character == '5') return '%';
	if (character == '6') return '^';
	if (character == '7') return '&';
	if (character == '8') return '*';
	if (character == '9') return '(';
	if (character == '0') return ')';
	if (character == '-') return '_';
	if (character == '=') return '+';
	if (character == '[') return '{';
	if (character == ']') return '}';
	if (character == '\\') return '|';
	if (character == ';') return ':';
	if (character == '\'') return '"';
	if (character == ',') return '<';
	if (character == '.') return '>';
	if (character == '/') return '?';
	if (character == '`') return '~';
	return character;
}

void make_filename(int number) {
	char digits[10];
	int count = 0;
	int index = 0;
	while (number > 0) {
		digits[count] = '0' + number % 10;
		count++;
		number /= 10;
	}
	while (count > 0) {
		count--;
		filename[index] = digits[count];
		index++;
	}
	filename[index] = '.';
	filename[index + 1] = 't';
	filename[index + 2] = 'x';
	filename[index + 3] = 't';
	filename[index + 4] = 0;
}

void save_document(void) {
	int number;
	int result;
	if (!filesystem_ready) {
		save_failed = 1;
		return;
	}
	if (filename[0] == 0) {
		number = MFS.count() + 1;
		make_filename(number);
		while (MFS.open(filename) != 0) {
			number++;
			make_filename(number);
		}
		result = MFS.create(filename);
		if (result != 0) {
			filename[0] = 0;
			save_failed = 1;
			return;
		}
	}
	result = MFS.write(filename, text, text_length);
	save_failed = result != 0;
}

void open_file_picker(void) {
	file_count = MFS.count();
	selected_file = 0;
	first_file = 0;
	file_picker = 1;
}

void keep_file_selected(void) {
	if (selected_file < first_file)
		first_file = selected_file;
	if (selected_file >= first_file + FILE_ROWS)
		first_file = selected_file - FILE_ROWS + 1;
}

void open_selected_file(void) {
	int length;
	if (selected_file < 0 || selected_file >= file_count)
		return;
	if (MFS.get_name(selected_file, filename, 64) < 0) {
		save_failed = 1;
		return;
	}
	length = MFS.read(filename, text, TEXT_CAPACITY - 1);
	if (length < 0) {
		filename[0] = 0;
		save_failed = 1;
		return;
	}
	text_length = length;
	text[text_length] = 0;
	cursor = 0;
	top_line = 0;
	save_failed = 0;
	file_picker = 0;
}

void move_cursor_up(void) {
	int start = line_start(cursor);
	int column = cursor - start;
	if (start > 0)
		cursor = position_on_line(previous_line(cursor), column);
	keep_cursor_visible();
}

void move_cursor_down(void) {
	int start = line_start(cursor);
	int column = cursor - start;
	int next = next_line(start);
	if (next < text_length || (next == text_length && text_length > 0 && text[text_length - 1] == '\n'))
		cursor = position_on_line(next, column);
	keep_cursor_visible();
}

void draw_character(int character, int x, int y, int luma) {
	int column;
	int row;
	int bits;
	int offset;
	if (character < 32 || character > 127)
		character = '?';
	offset = (character - 32) * GLYPH_WIDTH;
	for (column = 0; column < GLYPH_WIDTH; column++) {
		bits = font[offset + column];
		for (row = 0; row < GLYPH_HEIGHT; row++)
			if (bits & (1 << row))
				draw_rect(x + column, y + row, 1, 1, luma);
	}
}

void draw_string(char *value, int x, int y, int luma) {
	int index = 0;
	while (value[index] != 0) {
		draw_character(value[index], x, y, luma);
		x += CELL_WIDTH;
		index++;
	}
}

void draw_file_picker(void) {
	int row = 0;
	int file_index = first_file;
	draw_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, LUMA_BACKGROUND);
	draw_rect(0, 0, SCREEN_WIDTH, 15, LUMA_HEADER);
	draw_string("OPEN FILE", 6, 4, LUMA_TEXT);
	if (file_count == 0) {
		draw_string("NO FILES", TEXT_X, TEXT_Y, LUMA_MUTED);
		return;
	}
	while (row < FILE_ROWS && file_index < file_count) {
		if (file_index == selected_file)
			draw_rect(3, TEXT_Y + row * CELL_HEIGHT - 1,
					  SCREEN_WIDTH - 6, CELL_HEIGHT, LUMA_HEADER);
		if (MFS.get_name(file_index, listed_filename, 64) >= 0)
			draw_string(listed_filename, TEXT_X, TEXT_Y + row * CELL_HEIGHT,
						file_index == selected_file ? LUMA_CURSOR : LUMA_TEXT);
		row++;
		file_index++;
	}
}

void draw(void) {
	int position = top_line;
	int row = 0;
	int column = 0;
	int cursor_drawn = 0;
	if (file_picker) {
		draw_file_picker();
		exit();
		return;
	}
	draw_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, LUMA_BACKGROUND);
	draw_rect(0, 0, SCREEN_WIDTH, 15, LUMA_HEADER);
	if (save_failed)
		draw_string("SAVE FAILED", 6, 4, LUMA_TEXT);
	else if (filename[0] != 0)
		draw_string(filename, 6, 4, LUMA_TEXT);
	else
		draw_string("UNTITLED", 6, 4, LUMA_MUTED);
	while (row < VISIBLE_ROWS && position <= text_length) {
		if (position == cursor) {
			draw_rect(TEXT_X + column * CELL_WIDTH, TEXT_Y + row * CELL_HEIGHT,
					  1, GLYPH_HEIGHT, LUMA_CURSOR);
			cursor_drawn = 1;
		}
		if (position == text_length)
			break;
		if (text[position] == '\n') {
			row++;
			column = 0;
		} else {
			if (column < 51)
				draw_character(text[position], TEXT_X + column * CELL_WIDTH,
							   TEXT_Y + row * CELL_HEIGHT, LUMA_TEXT);
			column++;
		}
		position++;
	}
	if (!cursor_drawn && cursor == text_length && row < VISIBLE_ROWS)
		draw_rect(TEXT_X + column * CELL_WIDTH, TEXT_Y + row * CELL_HEIGHT,
				  1, GLYPH_HEIGHT, LUMA_CURSOR);
	exit();
}

void keyboard_input(void) {
	int key = get_keyboard_input();
	int flags = get_keyboard_input_flags();
	int start;
	if (!(flags & KBE_PRESSED) && !(flags & KBE_REPEAT)) {
		exit();
		return;
	}
	if (file_picker) {
		if (key == KEY_ESC)
			file_picker = 0;
		else if (key == KEY_UP && selected_file > 0) {
			selected_file--;
			keep_file_selected();
		} else if (key == KEY_DOWN && selected_file + 1 < file_count) {
			selected_file++;
			keep_file_selected();
		} else if (key == KEY_ENTER)
			open_selected_file();
		exit();
		return;
	}
	if (key == KEY_ESC) {
		open_file_picker();
		exit();
		return;
	}
	if ((flags & KBE_CTRL) && (key == 's' || key == 'S')) {
		save_document();
		exit();
		return;
	}
	if (key == KEY_LEFT && cursor > 0)
		cursor--;
	else if (key == KEY_RIGHT && cursor < text_length)
		cursor++;
	else if (key == KEY_UP)
		move_cursor_up();
	else if (key == KEY_DOWN)
		move_cursor_down();
	else if (key == KEY_HOME)
		cursor = line_start(cursor);
	else if (key == KEY_END) {
		start = line_start(cursor);
		cursor = next_line(start);
		if (cursor > start && text[cursor - 1] == '\n')
			cursor--;
	} else if (key == KEY_BACKSPACE)
		erase_before_cursor();
	else if (key == KEY_DELETE)
		erase_at_cursor();
	else if (key == KEY_ENTER)
		insert_character('\n');
	else if (key == KEY_TAB) {
		insert_character(' ');
		insert_character(' ');
		insert_character(' ');
		insert_character(' ');
	} else if (key >= 32 && key <= 126 && !(flags & KBE_CTRL)) {
		if (flags & KBE_SHIFT)
			key = shifted_character(key);
		insert_character(key);
	}
	keep_cursor_visible();
	exit();
}

void mouse_button_input(void) {
	int buttons = get_mouse_button_input();
	int mouse_x;
	int mouse_y;
	int target_row;
	int target_column;
	int position;
	int row;
	if ((buttons & MOUSE_BTN_LEFT) && !(previous_mouse_buttons & MOUSE_BTN_LEFT)) {
		mouse_x = get_mouse_x();
		mouse_y = get_mouse_y();
		if (file_picker && mouse_y >= TEXT_Y) {
			target_row = (mouse_y - TEXT_Y) / CELL_HEIGHT;
			if (target_row < FILE_ROWS && first_file + target_row < file_count) {
				selected_file = first_file + target_row;
				open_selected_file();
			}
		} else if (mouse_y >= TEXT_Y) {
			target_row = (mouse_y - TEXT_Y) / CELL_HEIGHT;
			target_column = (mouse_x - TEXT_X) / CELL_WIDTH;
			if (target_column < 0)
				target_column = 0;
			position = top_line;
			row = 0;
			while (row < target_row && position < text_length) {
				position = next_line(position);
				row++;
			}
			cursor = position_on_line(position, target_column);
			keep_cursor_visible();
		}
	}
	previous_mouse_buttons = buttons;
	exit();
}

int main(void) {
	if (MFS.load() != 0)
		MFS.format();
	filesystem_ready = MFS.load() == 0;
	text[0] = 0;
	filename[0] = 0;
	return 0;
}
