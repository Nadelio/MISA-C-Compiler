# Input

## Reacting to User Input
Mnemonimov implements three types of input: button, mouse, and terminal.

---

## Button Input
The primary input mechanism of Mnemonimov is its virtual buttons. The console emulates a common set of controller buttons, including the directional pad (D-pad), face buttons (ABXY), Select, and Start.

By default, all buttons are mapped to your keyboard, but you can change the keybindings and map them to other keys and even to a physical controller.

Programs can react to button input through the `_input` process and by using the system call `SYS_GET_INPUT` to fethc the input state. You can then use bitmasking to check whether a specific button is pressed.

See [Built-in Symbols](../Assembly/Built-In%20Symbols.md) for a list of button constants, and for instructions to view and modify their keybindings.

---

## Mouse Input
Mnemonimov supports mouse input for creating programs with graphical user interfaces.

The mouse position can be obtained with the system call `SYS_GET_MOUSE_POSITION`, which returns the mouse position in screen coordinates.

Mouse button input works just like the virtual button input. Programs can react to mouse button input through the `_mouse_button_input` process and by using the system call `SYS_GET_MOUSE_BUTTON_INPUT` to fetch the input state. You can then use bitmasking to check whether a specific button is pressed.

See [Built-in Symbols](../Assembly/Built-In%20Symbols.md) for a list of mouse button constants.

---

## Terminal Input
The terminal can be used to pass strings to the VM, enabling the creation of CLI programs. When a line starting with a slash character (`/`) is entered in the terminal, it is sent to the VM instead of being interpreted as a command.

Programs can react to terminal input through the `_terminal_input` process. Use the system call `SYS_READ_TERMINAL_INPUT` to read the input line into memory as a null-terminated ASCII string, with a maximum length of `MAX_TERMINAL_INPUT_SIZE` bytes, including the null byte. You can also obtain the string size beforehand using `SYS_GET_TERMINAL_INPUT_SIZE`.

Terminal input is managed by the VM as FIFO (first-in, first-out) queue. Reading an input line into memory removes it from the queue. Notes that the kernal keeps scheduling new `_terminal_input` processes until the queue is empty.

This sample code prints the input sting back to the terminal:
```
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