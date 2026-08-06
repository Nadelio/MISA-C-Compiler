#include "misa.h"

#define BTN_X  100
#define BTN_Y   90
#define BTN_W  120
#define BTN_H   60

#define PIXEL_SCALE 3

#define LUMA_BG      16
#define LUMA_BTN     70
#define LUMA_HOVER  120
#define LUMA_BORDER 220
#define LUMA_TEXT   255

int counter  = 0;
int prev_btn = 0;

unsigned char font[50] = {
    7,5,5,5,7,
    2,6,2,2,7,
    7,1,7,4,7,
    7,1,7,1,7,
    5,5,7,1,1,
    7,4,7,1,7,
    7,4,7,5,7,
    7,1,1,1,1,
    7,5,7,5,7,
    7,5,7,1,7
};

void draw_digit(int d, int x, int y) {
    int row;
    int col;
    for (row = 0; row < 5; row++) {
        int mask = font[d * 5 + row];
        for (col = 0; col < 3; col++) {
            if (mask & (4 >> col))
                draw_rect(x + col * (PIXEL_SCALE + 1),
                          y + row * (PIXEL_SCALE + 1),
                          PIXEL_SCALE, PIXEL_SCALE, LUMA_TEXT);
        }
    }
}

void draw_number(int n, int cx, int top_y) {
    int digits[8];
    int count = 0;
    int tmp;
    if (n == 0) {
        digits[0] = 0;
        count = 1;
    } else {
        tmp = n;
        while (tmp > 0 && count < 8) {
            digits[count] = tmp % 10;
            count++;
            tmp /= 10;
        }
    }

    // digit_w = 3 * PIXEL_SCALE + 2 (pixel columns + inner gaps)
    // slot_w  = digit_w + 2         (+ gap between digits)
    int digit_w = 3 * PIXEL_SCALE + 2;
    int slot_w  = digit_w + 2;
    int total_w = (count - 1) * slot_w + digit_w;
    int start_x = cx - total_w / 2;
    int i;
    for (i = count - 1; i >= 0; i--)
        draw_digit(digits[i], start_x + (count - 1 - i) * slot_w, top_y);
}

void draw_impl(void) {
    int mx    = get_mouse_x();
    int my    = get_mouse_y();
    int hover = mx >= BTN_X && mx < BTN_X + BTN_W
             && my >= BTN_Y && my < BTN_Y + BTN_H;

    draw_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, LUMA_BG);

    draw_rect(BTN_X, BTN_Y, BTN_W, BTN_H, hover ? LUMA_HOVER : LUMA_BTN);

    draw_rect(BTN_X,             BTN_Y,             BTN_W, 2,     LUMA_BORDER);
    draw_rect(BTN_X,             BTN_Y + BTN_H - 2, BTN_W, 2,     LUMA_BORDER);
    draw_rect(BTN_X,             BTN_Y,             2,     BTN_H, LUMA_BORDER);
    draw_rect(BTN_X + BTN_W - 2, BTN_Y,             2,     BTN_H, LUMA_BORDER);

    // number height = 5 rows * PIXEL_SCALE + 4 inner gaps
    int num_h = 5 * PIXEL_SCALE + 4;
    draw_number(counter, BTN_X + BTN_W / 2, BTN_Y + (BTN_H - num_h) / 2);
}

void mouse_btn_impl(void) {
    int btn = get_mouse_button_input();
    int mx  = get_mouse_x();
    int my  = get_mouse_y();
    // increment on the rising edge of the left button only
    if ((btn & MOUSE_BTN_LEFT) && !(prev_btn & MOUSE_BTN_LEFT))
        if (mx >= BTN_X && mx < BTN_X + BTN_W && my >= BTN_Y && my < BTN_Y + BTN_H)
            counter++;
    prev_btn = btn;
}

void draw(void) {
    draw_impl();
    exit();
}

void mouse_button_input(void) {
    mouse_btn_impl();
    exit();
}

int main(void) {
    return 0;
}