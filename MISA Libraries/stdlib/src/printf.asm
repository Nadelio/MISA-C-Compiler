sbmk "printf(fmt: char*, varargs: [void*]): void"
## Writes the C string pointed by format to the standard output (stdout).
## If format includes format specifiers (subsequences beginning with %),
## the additional arguments following format are formatted and inserted in
## the resulting string replacing their respective specifiers.
## Parameters:
## > a0 - fmt, is char*
## > a1 - varargs, is [void*]
## Returns: NONE
## Additional Implementation Notes:
## Supports %d, %i, %f, %s, and %% format specifiers
printf:
	vpsh s0..s2

	sub sp, 32
	mov ea, sp
	ste u32t, 0,  a1
	ste u32t, 4,  a2
	ste u32t, 8,  a3
	ste u32t, 12, a4
	ste u32t, 16, a5
	ste u32t, 20, a6
	ste u32t, 24, a7
	ste u32t, 28, a8

	mov s0, a0
	mov s1, sp
	mov s2, 0

.loop:
	mov ea, s0
	lde u8t, t0, 0
	cmp eq, t0, 0
	jtr .done
	cmp eq, t0, 37
	jtr .percent
	str u8t, __printf_char_buf, t0
	mov a0, __printf_char_buf
	syscall SYS_PRINT_STRING
	inc s0
	jmp .loop

.percent:
	inc s0
	mov ea, s0
	lde u8t, t0, 0
	cmp eq, t0, 100
	jtr .fmt_d
	cmp eq, t0, 105
	jtr .fmt_d
	cmp eq, t0, 115
	jtr .fmt_s
	cmp eq, t0, 102
	jtr .fmt_f
	cmp eq, t0, 99
	jtr .fmt_c
	cmp eq, t0, 37	
	jtr .fmt_percent
	str u8t, __printf_char_buf, 37
	mov a0, __printf_char_buf
	syscall SYS_PRINT_STRING
	jmp .loop

.fmt_d:
	mov ea, s1
	lde i32t, a0, 0
	add s1, 4
	syscall SYS_PRINT_INT
	inc s0
	jmp .loop

.fmt_s:
	mov ea, s1
	lde u32t, t0, 0
	add s1, 4
	tpr a0, t0
	syscall SYS_PRINT_STRING
	inc s0
	jmp .loop

.fmt_f:
	mov ea, s1
	lde f32t, a0, 0
	add s1, 4
	mov a1, 0
	syscall SYS_PRINT_FLOAT
	inc s0
	jmp .loop

.fmt_c:
	mov ea, s1
	lde u8t, t0, 0
	add s1, 4
	str u8t, __printf_char_buf, t0
	mov a0, __printf_char_buf
	syscall SYS_PRINT_STRING
	inc s0
	jmp .loop

.fmt_percent:
	str u8t, __printf_char_buf, 37
	mov a0, __printf_char_buf
	syscall SYS_PRINT_STRING
	inc s0
	jmp .loop

.done:
	mov a0, s2
	add sp, 32
	vpop s0..s2
	ret

__printf_char_buf:	emb u8t 0, 0
