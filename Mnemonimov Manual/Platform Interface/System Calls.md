# Requesting Services From the Kernel

A system call, or syscall, is a mechanism for requesting a service from the kernel, like printing a string or getting the current system time. Use the `syscall` instruction with one of the available system calls as operand to invoke it.

Arguments are passed to system calls through the argument registers, which are used for the return values as well. In the reference below, floating-point arguments and return values are indicated with the `f_` prefix. Note that the assembler does not implicitly convert operands to the types expected by instructions or system calls. If a value is intended to be a float, always write it as a floating-point literal by including the decimal part. See *No Implicit Casting of Operands* in the [Literals](../Assembly/Literals.md) chapter for details.

Unless noted otherwise, integer arguments and return values are interpreted as signed.

---

## Printing

**SYS_PRINT_INT**
Prints a signed integer value to the terminal without[^1] a trailing newline.
Args: `a0:value`

**SYS_PRINT_LINE_INT**
Prints a signed integer value to the terminal, followed by a newline.
Args: `a0:value`

**SYS_PRINT_FLOAT**
Prints a floating-point value to the terminal without[^1] a trailing newline. A default precision is used when `decimal_places` is `0`.
Args: `a0:f_value, a1:decimal_places`

**SYS_PRINT_LINE_FLOAT**
Prints a floating-point value to the terminal, followed by a newline. A default precision is used when `decimal_places` is `0`.
Args: `a0:f_value, a1:decimal_places`

**SYS_PRINT_STRING**
Prints a null-terminated string to the terminal without[^1] a trailing newline.
The `address` operand is pa-relative.
Args: `a0:address`

**SYS_PRINT_LINE_STRING**
Prints a null-terminated string to the terminal, followed by a newline.
The `address` operand is pa-relative.
Args: `a0:address`

[^1]: System calls without a trailing newline only affect user output. System messages always appear on a new line.

---

## Graphics

**SYS_DRAW_RECT**
Draws a rectangle to the screen.
Args: `a0:pos_x, a1:pos_y, a2:size_x, a3:size_y, a4:luma`

**SYS_DRAW_TEXTURE**
Draws a texture to the screen. Bits 1 and 0 of `flags` control X and Y mirroring, respectively.
The `address` operand is pa-relative.
Args: `a0:address, a1:pos_x, a2:pos_y, a3:flags`

**SYS_DRAW_TEXTURE_REGION**
Draws a rectangular region of a texture to the screen. Bits 1 and 0 of `flags` control X and Y mirroring, respectively.
The `address` operand is pa-relative.
Args: `a0:address, a1:pos_x, a2:pos_y, a3:region_pos_x, a4:region_pos_y, a5:region_size_x, a6:region_size_y, a7:flags`

**SYS_PRESERVE_BACK_BUFFER**
Preserves the back buffer when exiting the `_draw` process, instead of clearing it. Applies only to the current frame.

**SYS_PRESERVE_FRONT_BUFFER**
Preserves the front buffer when exiting the `_draw` process, instead of replacing it with the back buffer. Applies only to the current frame.

---

## Input

**SYS_GET_INPUT**
Gets the current user input state. See [Built-In Symbols](../Assembly/Built-In%20Symbols.md) for a list of button constants.
Returns: `a0:input_state`

**SYS_GET_MOUSE_POSITION**
Gets the current mouse position in screen coordinates.
Returns: `a0:pos_x, a1:pos_y`

**SYS_GET_MOUSE_BUTTON_INPUT**
Gets the current mouse button input state. See [Built-In Symbols](../Assembly/Built-In%20Symbols.md) for a list of mouse button constants.
Returns: `a0:mouse_button_input_state`

**SYS_GET_TERMINAL_INPUT_SIZE**
Gets the size of the next string in the terminal input queue, including the null-termination byte. Returns a `0` if the terminal input queue is empty.
Returns: `a0:string_size`

**SYS_READ_TERMINAL_INPUT**
Reads the next terminal input string into memory, removing it from the terminal input queue. If the destination buffer is larger than the input string, the remaining bytes are filled with `0`. If it is smaller, an exception is thrown.
The address `dst_address` is pa-relative. The return value includes the null-termination byte.
Returns `0` if the terminal input queue is empty.
Args: `a0:dst_address, a1:size`
Returns: `a0:string_size`

---

## Memory

**SYS_STORAGE_READ**
Loads a span of data from storage into memory.
The address `dst_address` is pa-relative.
Args: `a0:dst_address, a1:src_address, a2:size`

**SYS_STORAGE_WRITE**
Writes a span of data from memory to storage.
The address `src_address` is pa-relative.
Args: `a0:dst_address, a1:src_address, a2:size`

**SYS_MEM_COPY**
Copies a span of memory from one address to another. Supports overlapping memory ranges.
The addresses `dst_address` and `src_address` are pa-relative.
Args: `a0:dst_address, a1:src_address, a2:size`

**SYS_MEM_SET**
Sets a span of memory to a constant byte value.
The `address` operand is pa-relative.
Args: `a0:address, a1:size, a2:value`

---

## Time

**SYS_GET_UNIX_TIME**
Gets the current Unix time.
Returns: `a0:unix_time`

**SYS_GET_RUNNING_TIME**
Gets the elapsed time in seconds since the VM started.
Returns: `a0:f_running_time`

**SYS_GET_UPDATE_DELTA**
Gets the elapsed time in seconds since the last `_update` process execution.
Returns: `a0:f_update_delta`

**SYS_GET_DRAW_DELTA**
Gets the elapsed time in seconds since the last `_draw` process execution.
Returns: `a0:f_draw_delta`

---

## Other

**SYS_SET_RNG_SEED**
Sets the integer seed used by the random number generator (RNG). The RNG is initialized with a random seed at VM startup.
Args: `a0:seed`

**SYS_ALLOW_UNSAFE_JUMP**
Allows the next Control Flow instruction to transfer control to an address that may not point to the start of an instruction. This is intended for advanced use cases and should not be used during normal operation.