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
	vpsh s0..s3

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
	mov s3, 0

.loop:
	mov ea, s0
	lde u8t, t0, 0
	cmp eq, t0, 0
	jtr .flush_done
	cmp eq, t0, 37
	jtr .flush_percent
	cal .buf_char
	inc s0
	jmp .loop

.flush_percent:
	cal .flush_lit
	# note: fall through to percent intended

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
	mov t0, 37
	cal .buf_char
	jmp .loop

.fmt_d:
	cal .flush_lit
	mov ea, s1
	lde i32t, a0, 0
	add s1, 4
	syscall SYS_PRINT_INT
	inc s0
	jmp .loop

.fmt_s:
	cal .flush_lit
	mov ea, s1
	lde u32t, t0, 0
	add s1, 4
	tpr a0, t0
	syscall SYS_PRINT_STRING
	inc s0
	jmp .loop

.fmt_f:
	cal .flush_lit
	mov ea, s1
	lde f32t, a0, 0
	add s1, 4
	mov a1, 0
	syscall SYS_PRINT_FLOAT
	inc s0
	jmp .loop

.fmt_c:
	mov ea, s1
	lde u8t, t0, 3						
	add s1, 4
	cal .buf_char
	inc s0
	jmp .loop

.fmt_percent:
	mov t0, 37
	cal .buf_char
	inc s0
	jmp .loop

.flush_done:
	cal .flush_lit
	jmp @done+
@done:
	mov a0, s2
	add sp, 32
	vpop s0..s2
	ret

# buffer one byte into __printf_lit_buf, flushing first if full
# s3 is fill pos, safe up to 63 buf chars, 64 kept for null terminator
# needed for .flush_lit
.buf_char:
	cea __printf_lit_buf, s3, 1
	ste u8t, 0, t0
	inc s3
	cmp lt, s3, 63
	jtr @done+
	cal .flush_lit
@done:
	ret

# null terminates and prints buf, then resets buf, no-op if no buf
.flush_lit:
	cmp eq, s3, 0
	jtr @done+
	cea __printf_lit_buf, s3, 1
	mov t1, 0
	ste u8t, 0, t1
	mov a0, __printf_lit_buf
	syscall SYS_PRINT_STRING
	mov s3, 0
@done:
	ret

__printf_lit_buf:	res u8t 64
