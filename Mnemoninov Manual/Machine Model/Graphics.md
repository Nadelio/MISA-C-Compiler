# Graphics

## Screen

Mnemonimov has a monochrome 4:3 screen with a resolution of `320 x 240`. The screen size can be referenced using the built-in constants `SCREEN_WIDTH` and `SCREEN_HEIGHT`.

Screen coordinates have their origin at the top-left corner, with the Y axis pointing downward.

---

## Buffers

The screen uses double-buffered rendering. Drawing instructions and graphics-related system calls write exclusively to the back buffer, which resides in memory and can also be written to directly. The front buffer holds the image currently displayed on the screen and is not accessible from memory.

Screen updates are driven by the `_draw` process, which runs at `60 Hz`. When the `_draw` process exits, the back buffer is copied to the front buffer and then cleared. This behavior can be modified on a frame-by-frame basis using the following system calls:
- `SYS_PRESERVE_FRONT_BUFFER`: disables copying the back buffer to the front buffer for the current frame.
- `SYS_PRESERVE_BACK_BUFFER`: disables clearing the back buffer for the current frame.

---

## Luma

MISA implements a custom pixel format named **Luma**, and an accompanying texture format. Luma is a grayscale value that encodes both brightness and binary transparency.

---

## Pixel Encoding

Luma is an 8-bit value stored as a single byte per pixel. Binary transparency and brightness information are encoded as follows:
- value `0` represents full transparency.
- values in the range `[1, 255]` represent brightness.

Because the value zero is reserved for transparency, luma provides `255` brightness levels. When setting a pixel or drawing a texture, pixels with a luma `0` won't be written to the destination buffer.

---

## Texture Format

Luma textures are stored in memory with the format:
- `u16t` width
- `u16t` height
- `width * height` bytes of luma data in row-major order
