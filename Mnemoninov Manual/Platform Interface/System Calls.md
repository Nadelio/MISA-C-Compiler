# Requesting Services From the Kernel

A system call, or syscall, is a mechanism for requesting a service from the kernel, like printing a string or getting the current system time. Use the `syscall` instruction with one of the available system calls as operand to invoke it.

Arguments are passed to system calls through the argument registers, which are used for the return values as well. In the reference below, floating-point arguments and return values are indicated with the `f_` prefix.

---

## General

**SYS_PRINT_INT**
Prints an integer value to the terminal.
Args: `a0:value`

**SYS_PRINT_FLOAT**
Prints a floating-point value to the terminal. A default precision is used when `decimal_places` is `0`.
Args: `a0:f_value, a1:decimal_places`

**SYS_PRINT_STRING**
Prints a null-terminated string to the terminal.
The `address` operand is pa-relative.
Args: `a0:address`

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

**SYS_STORAGE_READ**
Loads a span of data from storage into memory.
The address `dst_address` is pa-relative.
Args: `a0:dst_address, a1:src_address, a2:size`

**SYS_STORAGE_WRITE**
Writes a span of data from memory to storage.
The address `src_address` is pa-relative.
Args: `a0:dst_address, a1:src_address, a2:size`

**SYS_MEM_COPY**
Copies a span of memory from one address to another.
The addresses `dst_address` and `src_address` are pa-relative.
Args: `a0:dst_address, a1:src_address, a2:size`

**SYS_MEM_SET**
Sets a span of memory to a constant byte value.
The `address` operand is pa-relative.
Args: `a0:address, a1:size, a2:value`

**SYS_PRESERVE_BACK_BUFFER**
Preserves the back buffer when exiting the `_draw` process, instead of clearing it. Applies only to the current frame.

**SYS_PRESERVE_FRONT_BUFFER**
Preserves the front buffer when exiting the `_draw` process, instead of replacing it with the back buffer. Applies only to the current frame.

---

## Getters

**SYS_GET_INPUT**
Gets the current user input state.
Returns: `a0:input_state`

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

## Setters

**SYS_SET_RNG_SEED**
Sets the integer seed used by the random number generator (RNG). The RNG is initialized with a random seed at VM startup.
Args: `a0:seed`
