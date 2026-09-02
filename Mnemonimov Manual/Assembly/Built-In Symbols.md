# Built-In Symbols

---

## General Constants

Common built-in constants:

| Keyword | Value |
|---------|-------|
| `true` | 1 |
| `false` | 0 |
| `PI` | 3.1415926... |
| `TAU` | 6.2831853... |
| `EXP1` | 2.7182818... |
| `INF` | Positive Infinity |
| `NAN` | Not a Number |

---

## ABI Constants

| Keyword | Value |
|---------|-------|
| `SCREEN_WIDTH` | 320 |
| `SCREEN_HEIGHT` | 240 |
| `MAX_TERMINAL_INPUT_SIZE` | 256 |

---

## Button Constants

Constants representing the button input bitfield. Used as masks in bitwise operations to test which buttons are pressed:

| Keyword | Value |
|---------|-------|
| `BTN_SELECT` | 512 |
| `BTN_START` | 256 |
| `BTN_LEFT` | 128 |
| `BTN_RIGHT` | 64 |
| `BTN_UP` | 32 |
| `BTN_DOWN` | 16 |
| `BTN_A` | 8 |
| `BTN_B` | 4 |
| `BTN_X` | 2 |
| `BTN_Y` | 1 |

You can view and adjust the console's keybindings in the Settings menu, accessible via the cog icon in the top-right corner.

---

## Mouse Button Constants

Constants representing the mouse input bitfield. Used as masks in bitwise operations to test which mouse buttons are pressed:

| Keyword | Value |
|---------|-------|
| `MOUSE_BTN_LEFT` | 1 |
| `MOUSE_BTN_RIGHT` | 2 |
| `MOUSE_BTN_MIDDLE` | 4 |
| `MOUSE_BTN_WHEEL_UP` | 8 |
| `MOUSE_BTN_WHEEL_DOWN` | 16 |

---

## Keyboard Event Constants

Constants representing the keyboard input bitfield. Used as masks in bitwise operations to test which flags are set:

| Keyword | Value |
|---------|-------|
| `KBE_PRESSED` | 1 |
| `KBE_REPEAT` | 2 |
| `KBE_CTRL` | 4 |
| `KBE_SHIFT` | 8 |
| `KBE_ALT` | 16 |

---

## Special Key Constants

Constants representing keyboard input codes for keys that do not use ASCII codes:

| Keyword | Value |
|---------|-------|
| `KEY_TAB` | `0x80` |
| `KEY_BACKSPACE` | `0x81` |
| `KEY_ENTER` | `0x82` |
| `KEY_ESC` | `0x83` |
| `KEY_CTRL` | `0x84` |
| `KEY_SHIFT` | `0x85` |
| `KEY_ALT` | `0x86` |
| `KEY_LEFT` | `0x87` |
| `KEY_RIGHT` | `0x88` |
| `KEY_UP` | `0x89` |
| `KEY_DOWN` | `0x8a` |
| `KEY_INSERT` | `0x8b` |
| `KEY_DELETE` | `0x8c` |
| `KEY_HOME` | `0x8d` |
| `KEY_END` | `0x8e` |
| `KEY_PAGE_UP` | `0x8f` |
| `KEY_PAGE_DOWN` | `0x90` |

If you are looking for keyboard input codes of printable keys, see [ASCII Table](../Assembly/Types%20and%20Files.md).

---

## Variables

Built-in variables exposing the internal assembler state:

| Keyword | Value |
|---------|-------|
| `$` | Assembler Address |

The assembler address is commonly used for computing offsets and struct sizes.
