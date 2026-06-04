# Built-In Symbols

---

## General Constants

Common built-in constants:

| Keyword        | Value             |
|----------------|-------------------|
| `true`         | 1                 |
| `false`        | 0                 |
| `PI`           | 3.1415926...      |
| `TAU`          | 6.2831853...      |
| `EXP1`         | 2.7182818...      |
| `INF`          | Positive Infinity |
| `NAN`          | Not a Number      |
| `SCREEN_WIDTH` | 320               |
| `SCREEN_HEIGHT`| 240               |

---

## Button Constants

Constants representing the input state. Used as masks in bitwise operations to test which buttons are pressed:

| Keyword      | Value |
|--------------|-------|
| `BTN_SELECT` | 512   |
| `BTN_START`  | 256   |
| `BTN_LEFT`   | 128   |
| `BTN_RIGHT`  | 64    |
| `BTN_UP`     | 32    |
| `BTN_DOWN`   | 16    |
| `BTN_A`      | 8     |
| `BTN_B`      | 4     |
| `BTN_X`      | 2     |
| `BTN_Y`      | 1     |

You can view and adjust the console's keybindings in the Settings menu, accessible via the cog icon in the top-right corner.

---

## Variables

Built-in variables exposing the internal assembler state:

| Keyword | Value              |
|---------|--------------------|
| `$`     | Assembler Address  |

The assembler address is commonly used for computing offsets and struct sizes.
