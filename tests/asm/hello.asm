_start:
	cal main_
	exit

main_:
	tpa t1, __str_0
	tpa t2, __str_1
	mov a1, t2
	mov a0, t1
	cal printf
	mov t0, a0
	ret

__str_0:	emb string "%s\n"
__str_1:	emb string "Hello, World!"

# printf(fmt, ...) — supports %d/%i, %s, %f, %c, %%
# a0: format string (absolute address, callers use tpa)
# a1..a8: variadic arguments (up to 8)
# returns 0

printf:
	vpsh s0..s2

	# Save up to 8 varargs to a stack array before any syscall clobbers them
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

	mov s0, a0	# fmt pointer (absolute, advances each char)
	mov s1, sp	# next-vararg pointer (advances by 4 per consumed arg)
	mov s2, 0	# return value

.loop:
	mov ea, s0
	lde u8t, t0, 0
	cmp eq, t0, 0
	jtr .done
	cmp eq, t0, 37	# '%'
	jtr .percent
	# Regular character: write into char buffer and print
	str u8t, __printf_char_buf, t0
	mov a0, __printf_char_buf
	syscall SYS_PRINT_STRING
	inc s0
	jmp .loop

.percent:
	inc s0
	mov ea, s0
	lde u8t, t0, 0
	cmp eq, t0, 100	# 'd'
	jtr .fmt_d
	cmp eq, t0, 105	# 'i'
	jtr .fmt_d
	cmp eq, t0, 115	# 's'
	jtr .fmt_s
	cmp eq, t0, 102	# 'f'
	jtr .fmt_f
	cmp eq, t0, 99	# 'c'
	jtr .fmt_c
	cmp eq, t0, 37	# '%%'
	jtr .fmt_percent
	# Unknown specifier: emit the literal '%' and reprocess the current char
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
	# Arg is an absolute address; SYS_PRINT_STRING wants pa-relative
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
	mov a1, 0	# 0 = use default decimal precision
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

# Two-byte buffer: [char][null]; only byte 0 is written at runtime
__printf_char_buf:	emb u8t 0, 0
