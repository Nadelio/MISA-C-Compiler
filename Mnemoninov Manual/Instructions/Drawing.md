# Drawing

Drawing instructions handle reading and writing luma data. They can get and set pixel luma from the back buffer and textures, and also normalize and denormalize luma values.

---

**`gbpx` → Get Back Buffer Pixel**
Reads a pixel luma from the back buffer.
Operands: `dest, x, y`
Pseudocode: `dest = M[ba + (y * SCREEN_WIDTH) + x]`

**`sbpx` → Set Back Buffer Pixel**
Writes a pixel luma to the back buffer.
Operands: `x, y, luma`
Pseudocode: `M[ba + (y * SCREEN_WIDTH) + x] = luma`

**`gtpx` → Get Texture Pixel**
Reads a pixel luma from a texture. The `address` operand is pa-relative.
Operands: `dest, address, x, y`
Pseudocode: `dest = get_texture_pixel(address, x, y)`

**`stpx` → Set Texture Pixel**
Writes a pixel luma to a texture. The `address` operand is pa-relative.
Operands: `address, x, y, luma`
Pseudocode: `set_texture_pixel(address, x, y, luma)`

**`norm` → Normalize [c]**
Normalizes a byte luma to a float in the range `[0.0, 1.0]`. Since luma `0` encodes transparency, the input range is `[1, 255]`.
Operands: `[dest], value`
Pseudocode: `dest = clamp(value - 1, 0, 254) / 254.0`
[c] Pseudocode: `value = clamp(value - 1, 0, 254) / 254.0`

**`dnrm` → Denormalize [c]**
Converts a normalized float luma to a byte. Since luma `0` encodes transparency, the output range is `[1, 255]`.
Operands: `[dest], value`
Pseudocode: `dest = clamp((int)(value * 254.0 + 1.0), 1, 255)`
[c] Pseudocode: `value = clamp((int)(value * 254.0 + 1.0), 1, 255)`
