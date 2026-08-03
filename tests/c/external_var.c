#include "misa.h"
#include "tests/c/cell_width.asm"
#include "tests/c/local_func.asm"

extern char CELL_WIDTH;
extern struct Player player;
extern struct Player player2;

extern void foo.somefunc();

char get_width() {
    foo.somefunc();
    return CELL_WIDTH;
}

int main(void) {
    print_int(player.x);
    print_int(player.y);
    player.y = 10;
    player2.y = 5;
}