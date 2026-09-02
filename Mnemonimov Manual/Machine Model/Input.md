# Input

## Reacting to User Input

Mnemonimov implements four types of input: button, mouse, keyboard, and terminal.

---

## Button Input

The primary input mechanism of Mnemonimov is its virtual buttons. The console emulates a common set of controller buttons, including the directional pad (D-pad), face buttons (ABXY), Select, and Start.

By default, all buttons are mapped to your keyboard, but you can change the keybindings and map them to other keys and even to a physical controller.

Programs can react to button input through the `_input` process and by using the system call `SYS_GET_INPUT` to fetch the input state. You can then use bitmasking to check whether a specific button is pressed.

See [Built-In Symbols](../Assembly/Built-In%20Symbols.md) for a list of button constants, and for instructions to view and modify their keybindings.

---

## Mouse Input

Mnemonimov supports mouse input for creating programs with graphical user interfaces.

The mouse position can be obtained with the system call `SYS_GET_MOUSE_POSITION`, which returns the mouse position in screen coordinates.

Mouse button input works just like the virtual button input. Programs can react to mouse button input through the `_mouse_button_input` process and by using the system call `SYS_GET_MOUSE_BUTTON_INPUT` to fetch the input state. You can then use bitmasking to check whether a specific button is pressed.

See [Built-In Symbols](../Assembly/Built-In%20Symbols.md) for a list of mouse button constants.

---

## Keyboard Input

Programs can react to keyboard input through the `_keyboard_input` process and by using the system call `SYS_GET_KEYBOARD_INPUT`, which returns a key code and a bitfield of the input event flags.

Printable keys use ASCII codes, while control and navigation keys have custom codes. See [Built-In Symbols](../Assembly/Built-In%20Symbols.md) for a reference of key codes.

The event flags indicate whether the input is a key press or release, whether it is a repeat event, and which modifier keys (Ctrl, Shift, and Alt) are pressed.

Keyboard input is buffered. Note that the kernel keeps scheduling new `_keyboard_input` processes until the event buffer is empty.

This sample code prints pressed keys to the terminal using a bit manipulation trick to toggle case based on the Shift modifier flag:

```asm
# Prepares a buffer for a one-character string.
buffer: res u8t 2

_keyboard_input:
    # Filters printable key press events.
    syscall SYS_GET_KEYBOARD_INPUT
    and cr, a1, KBE_PRESSED
    jfs @return+
    and cr, a0, 0x80
    jtr @return+

    # Uses the Shift modifier flag to toggle case.
    pbx t0, a1, KBE_SHIFT
    xor t0, 1
    pbd t0, t0, 0x20
    orr a0, t0

    # Writes the char to the string buffer and prints it.
    str u8t, buffer, a0
    mov a0, buffer
    syscall SYS_PRINT_STRING
@return:
    exit
```

---

## Terminal Input

The terminal can be used to pass strings to the VM, enabling the creation of CLI programs. When a line starting with a slash character (`/`) is entered in the terminal, it is sent to the VM instead of being interpreted as a command.

Programs can react to terminal input through the `_terminal_input` process. Use the system call `SYS_READ_TERMINAL_INPUT` to read the input line into memory as a null-terminated ASCII string, with a maximum length of `MAX_TERMINAL_INPUT_SIZE` bytes, including the null byte. You can also obtain the string size beforehand using `SYS_GET_TERMINAL_INPUT_SIZE`.

Terminal input is managed by the VM as a FIFO (first-in, first-out) queue. Reading an input line into memory removes it from the queue. Note that the kernel keeps scheduling new `_terminal_input` processes until the queue is empty.

This sample code prints the input string back to the terminal:

```asm
# Prepares a buffer with the maximum input size.
buffer: res u8t MAX_TERMINAL_INPUT_SIZE

_terminal_input:
    # Reads the terminal input string into memory.
    mov a0, buffer
    mov a1, MAX_TERMINAL_INPUT_SIZE
    syscall SYS_READ_TERMINAL_INPUT

    # Prints the terminal input string.
    mov a0, buffer
    syscall SYS_PRINT_LINE_STRING
    exit
```
