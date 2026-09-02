#ifndef MISA_H
#define MISA_H

#define SCREEN_WIDTH            320
#define SCREEN_HEIGHT           240
#define MAX_TERMINAL_INPUT_SIZE 256

#define BTN_SELECT 512
#define BTN_START 256
#define BTN_LEFT 128
#define BTN_RIGHT 64
#define BTN_UP 32
#define BTN_DOWN 16
#define BTN_A 8
#define BTN_B 4
#define BTN_X 2
#define BTN_Y 1

#define MOUSE_BTN_LEFT       1
#define MOUSE_BTN_RIGHT      2
#define MOUSE_BTN_MIDDLE     4
#define MOUSE_BTN_WHEEL_UP   8
#define MOUSE_BTN_WHEEL_DOWN 16

#define KBE_PRESSED 1
#define KBE_REPEAT 2
#define KBE_CTRL 4
#define KBE_SHIFT 8
#define KBE_ALT 16

#define KEY_TAB 0x09
#define KEY_BACKSPACE 0x08
#define KEY_ENTER 0x0d
#define KEY_ESC 0x1b
#define KEY_CTRL 0x11
#define KEY_SHIFT 0x10
#define KEY_ALT 0x12
#define KEY_LEFT 0x25
#define KEY_RIGHT 0x27
#define KEY_UP 0x26
#define KEY_DOWN 0x28
#define KEY_INSERT 0x2d
#define KEY_DELETE 0x2e
#define KEY_HOME 0x24
#define KEY_END 0x23
#define KEY_PAGE_UP 0x21
#define KEY_PAGE_DOWN 0x22

#define SYS_PRINT_INT               0
#define SYS_PRINT_LINE_INT          1
#define SYS_PRINT_FLOAT             2
#define SYS_PRINT_LINE_FLOAT        3
#define SYS_PRINT_STRING            4
#define SYS_PRINT_LINE_STRING       5
#define SYS_DRAW_RECT               6
#define SYS_DRAW_TEXTURE            7
#define SYS_DRAW_TEXTURE_REGION     8
#define SYS_PRESERVE_BACK_BUFFER    9
#define SYS_PRESERVE_FRONT_BUFFER   10
#define SYS_GET_INPUT               11
#define SYS_GET_TERMINAL_INPUT_SIZE 12
#define SYS_READ_TERMINAL_INPUT     13
#define SYS_STORAGE_READ            14
#define SYS_STORAGE_WRITE           15
#define SYS_MEM_COPY                16
#define SYS_MEM_SET                 17
#define SYS_GET_UNIX_TIME           18
#define SYS_GET_RUNNING_TIME        19
#define SYS_GET_UPDATE_DELTA        20
#define SYS_GET_DRAW_DELTA          21
#define SYS_SET_RNG_SEED            22
#define SYS_ALLOW_UNSAFE_JUMP       23
#define SYS_GET_MOUSE_POSITION      24
#define SYS_GET_MOUSE_BUTTON_INPUT  25
#define SYS_GET_KEYBOARD_INPUT      26

extern void print_int(int value);
extern void println_int(int value);
extern void print_float(float value, int decimal_places);
extern void println_float(float value, int decimal_places);
extern void print_string(char *str);
extern void println_string(char *str);

extern void draw_rect(int x, int y, int w, int h, int luma);
extern void draw_texture(void *addr, int x, int y, int flags);
extern void draw_texture_region(void *addr, int x, int y, int rx, int ry, int rw, int rh, int flags);
extern void preserve_back_buffer(void);
extern void preserve_front_buffer(void);

extern int get_input(void);
extern int get_mouse_x(void);
extern int get_mouse_y(void);
extern int get_mouse_button_input(void);
extern int get_keyboard_input(void);
extern int get_terminal_input_size(void);
extern int read_terminal_input(char *buf, int size);

extern void storage_read(void *dst, void *src, int size);
extern void storage_write(void *dst, void *src, int size);
extern void mem_copy(void *dst, void *src, int size);
extern void mem_set(void *dst, int value, int size);

extern int   get_unix_time(void);
extern float get_running_time(void);
extern float get_update_delta(void);
extern float get_draw_delta(void);
extern void  set_rng_seed(int seed);

extern int  syscall(int id, ...);
extern int  to_pa(void *ptr);
extern void yield(void);

#endif
