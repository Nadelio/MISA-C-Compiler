_start:
	cal main_
	exit

sbmk "puts_(str: i8t*): i16t"
##
## Parameters:
## > a0 - str, is i8t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
puts_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_LINE_STRING
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret

sbmk "putchar_(c: i16t): i16t"
##
## Parameters:
## > a0 - c, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
putchar_:
	sub sp, 8
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	lde i16t, t2, -4
	mov t1, t2
	sbx t1, t1, 0, 8
	add t2, fp, -8
	mov t3, 0
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 0
	add t2, fp, -8
	mov t3, 1
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	add t1, fp, -8
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_STRING
	mov t0, a0
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	add sp, 8
	ret

sbmk "getchar_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
getchar_:
	sub sp, 4
	lod u32t, t1, g___gc_pos
	lod u32t, t2, g___gc_len
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	psh t0
	psh t1
	syscall SYS_GET_TERMINAL_INPUT_SIZE
	mov t2, a0
	pop t1
	pop t0
	mov t1, t2
	mov ea, fp
	ste u32t, -4, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -4
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L2
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 4
	ret
__L2:
__L3:
	mov ea, fp
	lde u32t, t1, -4
	mov t2, 256
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L4
	mov t1, 256
	mov ea, fp
	ste u32t, -4, t1
	mov t0, t1
__L4:
__L5:
	psh t0
	psh t1
	tpa t0, g___gc_buf
	mov ea, fp
	lde u32t, t3, -4
	mov t1, t3
	sbx t1, t1, 0, 16
	mov a1, t1
	mov a0, t0
	tpr a0
	syscall SYS_READ_TERMINAL_INPUT
	mov t2, a0
	pop t1
	pop t0
	mov t1, t2
	str u32t, g___gc_len, t1
	mov t0, t1
	mov t1, 0
	str u32t, g___gc_pos, t1
	mov t0, t1
__L0:
__L1:
	lod u32t, t1, g___gc_pos
	lod u32t, t2, g___gc_len
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L6
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 4
	ret
__L6:
__L7:
	tpa t3, g___gc_buf
	lod u32t, t5, g___gc_pos
	mov t4, t5
	inc t5
	str u32t, g___gc_pos, t5
	add t3, t4
	mov ea, t3
	lde i8t, t2, 0
	mov t1, t2
	ubx t1, t1, 0, 8
	mov t0, t1
	sbx t0, t0, 0, 16
	mov a0, t0
	add sp, 4
	ret

sbmk "_copy_name(slot: u32t*, src: i8t*): void"
##
## Parameters:
## > a0 - slot, is u32t*
## > a1 - src, is i8t*
## Returns: NONE
## Additional Implementation Notes:
_copy_name:
	sub sp, 12
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov t0, 0
	mov ea, fp
	ste i16t, -12, t0
__L8:
	mov ea, fp
	lde u32t, t2, -8
	mov ea, fp
	lde i16t, t3, -12
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L10
	mov ea, fp
	lde i16t, t2, -12
	mov t4, 64
	mov t5, 1
	sub t3, t4, t5
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L10:
	cmp neq, t0, zr
	jfs __L9
	mov ea, fp
	lde u32t, t2, -8
	mov ea, fp
	lde i16t, t3, -12
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov ea, fp
	lde u32t, t3, -4
	mov ea, t3
	lde u32t, t2, 12
	mov ea, fp
	lde i16t, t3, -12
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -12
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -12, t1
	jmp __L8
__L9:
	mov t1, 0
	mov ea, fp
	lde u32t, t3, -4
	mov ea, t3
	lde u32t, t2, 12
	mov ea, fp
	lde i16t, t3, -12
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	add sp, 12
	ret

sbmk "fopen_(filename: i8t*, mode: i8t*): u32t*"
##
## Parameters:
## > a0 - filename, is i8t*
## > a1 - mode, is i8t*
## Returns:
## < a0 - return value, is u32t*
## Additional Implementation Notes:
fopen_:
	sub sp, 28
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov t0, 0
	mov ea, fp
	ste u32t, -16, t0
	mov t1, 0
	mov ea, fp
	ste i16t, -12, t1
	mov t0, t1
__L11:
	mov ea, fp
	lde i16t, t1, -12
	mov t2, 8
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L13
	tpa t3, g___file_pool
	mov ea, fp
	lde i16t, t4, -12
	mul t4, 80
	add t3, t4
	mov t2, t3
	mov ea, t2
	lde i16t, t1, 78
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L14
	tpa t3, g___file_pool
	mov ea, fp
	lde i16t, t4, -12
	mul t4, 80
	add t3, t4
	mov t2, t3
	mov t1, t2
	mov ea, fp
	ste u32t, -16, t1
	mov t0, t1
	jmp __L13
__L14:
__L15:
__L12:
	mov ea, fp
	lde i16t, t1, -12
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -12, t1
	jmp __L11
__L13:
	mov ea, fp
	lde u32t, t1, -16
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L16
	mov t0, 0
	mov a0, t0
	add sp, 28
	ret
__L16:
__L17:
	mov ea, fp
	lde u32t, t2, -8
	mov t3, 0
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 114
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L18
	mov t1, 0
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
	jmp __L19
__L18:
	mov ea, fp
	lde u32t, t2, -8
	mov t3, 0
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 119
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L20
	mov t1, 1
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
	jmp __L21
__L20:
	mov ea, fp
	lde u32t, t2, -8
	mov t3, 0
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 97
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L22
	mov t1, 2
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
	jmp __L23
__L22:
	mov t0, 0
	mov a0, t0
	add sp, 28
	ret
__L23:
__L21:
__L19:
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L24
	psh t0
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	cal MFS.open
	mov t1, a0
	pop t0
	mov ea, fp
	ste u32t, -24, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -24
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L26
	mov t0, 0
	mov a0, t0
	add sp, 28
	ret
__L26:
__L27:
	jmp __L25
__L24:
	mov ea, fp
	lde u32t, t1, -4
	mov a0, t1
	cal MFS.create
	mov t0, a0
	psh t0
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	cal MFS.open
	mov t1, a0
	pop t0
	mov ea, fp
	ste u32t, -24, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -24
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L28
	mov t0, 0
	mov a0, t0
	add sp, 28
	ret
__L28:
__L29:
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 1
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L30
	mov ea, fp
	lde u32t, t1, -4
	tpa t2, g___null_buf
	mov t3, 0
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.write
	mov t0, a0
__L30:
__L31:
__L25:
	mov ea, fp
	lde u32t, t1, -24
	mov ea, fp
	lde u32t, t3, -16
	mov t2, t3
	mov ea, t2
	ste u32t, 0, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	lde u32t, t3, -16
	mov t2, t3
	mov ea, t2
	ste u32t, 4, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	lde u32t, t3, -16
	mov t2, t3
	mov ea, t2
	ste i16t, 8, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -20
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	ste i16t, 76, t1
	mov t0, t1
	mov t1, 1
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	ste i16t, 78, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, fp
	lde u32t, t2, -4
	mov a1, t2
	mov a0, t1
	cal _copy_name
	mov t0, a0
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 2
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L32
	psh t0
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	lde u32t, t0, 12
	mov a0, t0
	cal _get_file_size
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -28, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t3, -28
	mov t4, 0
	cmp lt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L34
	mov t2, 0
	mov t1, t2
	jmp __L35
__L34:
	mov ea, fp
	lde i32t, t3, -28
	mov t2, t3
	mov t1, t2
__L35:
	mov ea, fp
	lde u32t, t3, -16
	mov t2, t3
	mov ea, t2
	ste u32t, 4, t1
	mov t0, t1
__L32:
__L33:
	mov ea, fp
	lde u32t, t2, -16
	mov t1, t2
	mov t0, t1
	mov a0, t0
	add sp, 28
	ret

sbmk "fclose_(stream: u32t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fclose_:
	sub sp, 8
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	mov t0, t1
	mov ea, fp
	ste u32t, -8, t0
	mov ea, fp
	lde u32t, t2, -4
	cmp eq, t2, zr
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L38
	mov ea, fp
	lde u32t, t3, -8
	mov ea, t3
	lde i16t, t2, 78
	cmp eq, t2, zr
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L38:
	cmp eq, t0, zr
	jtr __L36
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 8
	ret
__L36:
__L37:
	mov t1, 0
	mov ea, fp
	lde u32t, t2, -8
	mov ea, t2
	ste i16t, 78, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	lde u32t, t2, -4
	mov ea, t2
	ste u32t, 0, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	lde u32t, t2, -4
	mov ea, t2
	ste i16t, 8, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	lde u32t, t2, -4
	mov ea, t2
	ste u32t, 4, t1
	mov t0, t1
	mov t0, 0
	mov a0, t0
	add sp, 8
	ret

sbmk "remove_(filename: i8t*): i16t"
##
## Parameters:
## > a0 - filename, is i8t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
remove_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	psh t0
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	cal MFS.delete
	mov t1, a0
	pop t0
	mov t0, t1
	mov a0, t0
	add sp, 4
	ret

sbmk "rename_(old_name: i8t*, new_name: i8t*): i16t"
##
## Parameters:
## > a0 - old_name, is i8t*
## > a1 - new_name, is i8t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
rename_:
	sub sp, 20
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	psh t0
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	cal _get_file_size
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -12, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L39
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 20
	ret
__L39:
__L40:
	psh t0
	mov ea, fp
	lde u32t, t0, -8
	mov a0, t0
	cal MFS.create
	mov t1, a0
	pop t0
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L41
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 20
	ret
__L41:
__L42:
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L43
	psh t0
	mov ea, fp
	lde i32t, t2, -12
	mov t0, t2
	mov a0, t0
	cal malloc
	mov t1, a0
	pop t0
	mov ea, fp
	ste u32t, -16, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -16
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L45
	mov ea, fp
	lde u32t, t1, -8
	mov a0, t1
	cal MFS.delete
	mov t0, a0
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 20
	ret
__L45:
__L46:
	mov ea, fp
	lde u32t, t1, -4
	mov ea, fp
	lde u32t, t2, -16
	mov ea, fp
	lde i32t, t4, -12
	mov t3, t4
	sbx t3, t3, 0, 16
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.read
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -8
	mov ea, fp
	lde u32t, t2, -16
	mov ea, fp
	lde i32t, t4, -12
	mov t3, t4
	sbx t3, t3, 0, 16
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.write
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -16
	mov a0, t1
	cal free
	mov t0, a0
__L43:
__L44:
	psh t0
	psh t1
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	cal MFS.delete
	mov t2, a0
	pop t1
	pop t0
	mov t1, t2
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t0, -20
	mov a0, t0
	add sp, 20
	ret

sbmk "feof_(stream: u32t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
feof_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L47
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret
__L47:
__L48:
	mov ea, fp
	lde u32t, t3, -4
	mov ea, t3
	lde i16t, t2, 8
	mov t3, 1
	and t1, t2, t3
	cmp neq, t1, zr
	jfs __L49
	mov t1, 1
	mov t0, t1
	jmp __L50
__L49:
	mov t1, 0
	mov t0, t1
__L50:
	mov a0, t0
	add sp, 4
	ret

sbmk "ferror_(stream: u32t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
ferror_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L51
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret
__L51:
__L52:
	mov ea, fp
	lde u32t, t3, -4
	mov ea, t3
	lde i16t, t2, 8
	mov t3, 2
	and t1, t2, t3
	cmp neq, t1, zr
	jfs __L53
	mov t1, 1
	mov t0, t1
	jmp __L54
__L53:
	mov t1, 0
	mov t0, t1
__L54:
	mov a0, t0
	add sp, 4
	ret

sbmk "fseek_(stream: u32t*, offset: i32t, whence: i16t): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## > a1 - offset, is i32t
## > a2 - whence, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fseek_:
	sub sp, 24
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste i32t, -8, a1
	mov ea, fp
	ste i16t, -12, a2
	mov ea, fp
	lde u32t, t1, -4
	mov t0, t1
	mov ea, fp
	ste u32t, -16, t0
	mov ea, fp
	lde u32t, t2, -4
	cmp eq, t2, zr
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L57
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 78
	cmp eq, t2, zr
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L57:
	cmp eq, t0, zr
	jtr __L55
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 24
	ret
__L55:
__L56:
	mov ea, fp
	lde i16t, t1, -12
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L58
	mov ea, fp
	lde i32t, t1, -8
	mov ea, fp
	ste i32t, -24, t1
	mov t0, t1
	jmp __L59
__L58:
	mov ea, fp
	lde i16t, t1, -12
	mov t2, 1
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L60
	mov ea, fp
	lde u32t, t4, -4
	mov ea, t4
	lde u32t, t3, 4
	mov t2, t3
	mov ea, fp
	lde i32t, t3, -8
	add t1, t2, t3
	mov ea, fp
	ste i32t, -24, t1
	mov t0, t1
	jmp __L61
__L60:
	psh t0
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	lde u32t, t0, 12
	mov a0, t0
	cal _get_file_size
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -20, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t4, -20
	mov t5, 0
	cmp lt, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	jfs __L62
	mov t3, 0
	mov t2, t3
	jmp __L63
__L62:
	mov ea, fp
	lde i32t, t3, -20
	mov t2, t3
__L63:
	mov ea, fp
	lde i32t, t3, -8
	add t1, t2, t3
	mov ea, fp
	ste i32t, -24, t1
	mov t0, t1
__L61:
__L59:
	mov ea, fp
	lde i32t, t1, -24
	mov t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L64
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 24
	ret
__L64:
__L65:
	mov ea, fp
	lde i32t, t2, -24
	mov t1, t2
	mov ea, fp
	lde u32t, t2, -4
	mov ea, t2
	ste u32t, 4, t1
	mov t0, t1
	mov t2, 1
	not t1, t2
	mov ea, fp
	lde u32t, t3, -4
	mov ea, t3
	lde i16t, t2, 8
	and t3, t2, t1
	mov ea, fp
	lde u32t, t1, -4
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	mov t0, 0
	mov a0, t0
	add sp, 24
	ret

sbmk "ftell_(stream: u32t*): i32t"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
ftell_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L66
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 4
	ret
__L66:
__L67:
	mov ea, fp
	lde u32t, t2, -4
	mov ea, t2
	lde u32t, t1, 4
	mov t0, t1
	mov a0, t0
	add sp, 4
	ret

sbmk "rewind_(stream: u32t*): void"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns: NONE
## Additional Implementation Notes:
rewind_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L68
	add sp, 4
	ret
__L68:
__L69:
	mov t1, 0
	mov ea, fp
	lde u32t, t2, -4
	mov ea, t2
	ste u32t, 4, t1
	mov t0, t1
	mov t3, 1
	mov t4, 2
	orr t2, t3, t4
	not t1, t2
	mov ea, fp
	lde u32t, t3, -4
	mov ea, t3
	lde i16t, t2, 8
	and t3, t2, t1
	mov ea, fp
	lde u32t, t1, -4
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	add sp, 4
	ret

sbmk "fread_(ptr: void*, size: u32t, count: u32t, stream: u32t*): u32t"
##
## Parameters:
## > a0 - ptr, is void*
## > a1 - size, is u32t
## > a2 - count, is u32t
## > a3 - stream, is u32t*
## Returns:
## < a0 - return value, is u32t
## Additional Implementation Notes:
fread_:
	sub sp, 52
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	ste u32t, -12, a2
	mov ea, fp
	ste u32t, -16, a3
	mov ea, fp
	lde u32t, t1, -16
	mov t0, t1
	mov ea, fp
	ste u32t, -20, t0
	mov ea, fp
	lde u32t, t4, -16
	cmp eq, t4, zr
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jtr __L74
	mov ea, fp
	lde u32t, t5, -20
	mov ea, t5
	lde i16t, t4, 78
	cmp eq, t4, zr
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L74:
	mov t1, t2
	cmp neq, t1, zr
	jtr __L73
	mov ea, fp
	lde u32t, t3, -8
	mov t4, 0
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L73:
	mov t0, t1
	cmp neq, t0, zr
	jtr __L72
	mov ea, fp
	lde u32t, t2, -12
	mov t3, 0
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L72:
	cmp eq, t0, zr
	jtr __L70
	mov t0, 0
	mov a0, t0
	add sp, 52
	ret
__L70:
__L71:
	mov ea, fp
	lde u32t, t2, -8
	mov ea, fp
	lde u32t, t3, -12
	mul t1, t2, t3
	mov ea, fp
	ste u32t, -24, t1
	mov t0, t1
	psh t0
	mov ea, fp
	lde u32t, t2, -20
	mov ea, t2
	lde u32t, t0, 12
	mov a0, t0
	cal _get_file_size
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -28, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t1, -28
	mov t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L75
	mov t1, 2
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 8
	orr t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	mov t0, 0
	mov a0, t0
	add sp, 52
	ret
__L75:
__L76:
	mov ea, fp
	lde i32t, t2, -28
	mov t1, t2
	mov ea, fp
	ste u32t, -32, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	lde u32t, t1, 4
	mov ea, fp
	lde u32t, t2, -32
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L77
	mov t1, 1
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 8
	orr t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	mov t0, 0
	mov a0, t0
	add sp, 52
	ret
__L77:
__L78:
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde u32t, t2, 4
	mov ea, fp
	lde u32t, t3, -24
	add t1, t2, t3
	mov ea, fp
	ste u32t, -36, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -36
	mov ea, fp
	lde u32t, t2, -32
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L79
	mov ea, fp
	lde u32t, t1, -32
	mov ea, fp
	ste u32t, -36, t1
	mov t0, t1
__L79:
__L80:
	psh t0
	mov ea, fp
	lde u32t, t0, -36
	mov a0, t0
	cal malloc
	mov t1, a0
	pop t0
	mov ea, fp
	ste u32t, -40, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -40
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L81
	mov t1, 2
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 8
	orr t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	mov t0, 0
	mov a0, t0
	add sp, 52
	ret
__L81:
__L82:
	psh t0
	psh t1
	mov ea, fp
	lde u32t, t1, -20
	mov ea, t1
	lde u32t, t0, 12
	mov ea, fp
	lde u32t, t1, -40
	mov ea, fp
	lde u32t, t4, -36
	mov t3, t4
	sbx t3, t3, 0, 16
	mov a2, t3
	mov a1, t1
	mov a0, t0
	cal MFS.read
	mov t2, a0
	pop t1
	pop t0
	mov t1, t2
	mov ea, fp
	ste u32t, -44, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -44
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde u32t, t2, 4
	cmp lteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L83
	mov ea, fp
	lde u32t, t1, -40
	mov a0, t1
	cal free
	mov t0, a0
	mov t1, 1
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 8
	orr t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	mov t0, 0
	mov a0, t0
	add sp, 52
	ret
__L83:
__L84:
	mov ea, fp
	lde u32t, t2, -44
	mov ea, fp
	lde u32t, t4, -16
	mov ea, t4
	lde u32t, t3, 4
	sub t1, t2, t3
	mov ea, fp
	ste u32t, -48, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t3, -48
	mov ea, fp
	lde u32t, t4, -24
	cmp ltu, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L85
	mov ea, fp
	lde u32t, t2, -48
	mov t1, t2
	jmp __L86
__L85:
	mov ea, fp
	lde u32t, t2, -24
	mov t1, t2
__L86:
	mov ea, fp
	ste u32t, -52, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -4
	mov ea, fp
	lde u32t, t4, -40
	mov t3, t4
	mov ea, fp
	lde u32t, t5, -16
	mov ea, t5
	lde u32t, t4, 4
	add t2, t3, t4
	mov ea, fp
	lde u32t, t3, -52
	mov a2, t3
	mov a1, t2
	mov a0, t1
	tpr a0
	tpr a1
	syscall SYS_MEM_COPY
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -40
	mov a0, t1
	cal free
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -52
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde u32t, t2, 4
	add t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste u32t, 4, t3
	mov t0, t3
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	lde u32t, t1, 4
	mov ea, fp
	lde u32t, t2, -32
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L87
	mov t1, 1
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 8
	orr t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
__L87:
__L88:
	mov ea, fp
	lde u32t, t1, -52
	mov ea, fp
	lde u32t, t2, -8
	div t0, t1, t2
	mov a0, t0
	add sp, 52
	ret

sbmk "fwrite_(ptr: void*, size: u32t, count: u32t, stream: u32t*): u32t"
##
## Parameters:
## > a0 - ptr, is void*
## > a1 - size, is u32t
## > a2 - count, is u32t
## > a3 - stream, is u32t*
## Returns:
## < a0 - return value, is u32t
## Additional Implementation Notes:
fwrite_:
	sub sp, 40
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	ste u32t, -12, a2
	mov ea, fp
	ste u32t, -16, a3
	mov ea, fp
	lde u32t, t1, -16
	mov t0, t1
	mov ea, fp
	ste u32t, -20, t0
	mov ea, fp
	lde u32t, t4, -16
	cmp eq, t4, zr
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jtr __L93
	mov ea, fp
	lde u32t, t5, -20
	mov ea, t5
	lde i16t, t4, 78
	cmp eq, t4, zr
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L93:
	mov t1, t2
	cmp neq, t1, zr
	jtr __L92
	mov ea, fp
	lde u32t, t3, -8
	mov t4, 0
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L92:
	mov t0, t1
	cmp neq, t0, zr
	jtr __L91
	mov ea, fp
	lde u32t, t2, -12
	mov t3, 0
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L91:
	cmp eq, t0, zr
	jtr __L89
	mov t0, 0
	mov a0, t0
	add sp, 40
	ret
__L89:
__L90:
	mov ea, fp
	lde u32t, t2, -8
	mov ea, fp
	lde u32t, t3, -12
	mul t1, t2, t3
	mov ea, fp
	ste u32t, -24, t1
	mov t0, t1
	psh t0
	mov ea, fp
	lde u32t, t2, -20
	mov ea, t2
	lde u32t, t0, 12
	mov a0, t0
	cal _get_file_size
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -28, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t3, -28
	mov t4, 0
	cmp lt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L94
	mov t2, 0
	mov t1, t2
	jmp __L95
__L94:
	mov ea, fp
	lde i32t, t3, -28
	mov t2, t3
	mov t1, t2
__L95:
	mov ea, fp
	ste u32t, -32, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde u32t, t2, 4
	mov ea, fp
	lde u32t, t3, -24
	add t1, t2, t3
	mov ea, fp
	ste u32t, -36, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -36
	mov ea, fp
	lde u32t, t2, -32
	cmp ltu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L96
	mov ea, fp
	lde u32t, t1, -32
	mov ea, fp
	ste u32t, -36, t1
	mov t0, t1
__L96:
__L97:
	psh t0
	mov ea, fp
	lde u32t, t0, -36
	mov a0, t0
	cal malloc
	mov t1, a0
	pop t0
	mov ea, fp
	ste u32t, -40, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -40
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L98
	mov t1, 2
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde i16t, t2, 8
	orr t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste i16t, 8, t3
	mov t0, t3
	mov t0, 0
	mov a0, t0
	add sp, 40
	ret
__L98:
__L99:
	mov ea, fp
	lde u32t, t1, -32
	mov t2, 0
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L100
	mov ea, fp
	lde u32t, t2, -20
	mov ea, t2
	lde u32t, t1, 12
	mov ea, fp
	lde u32t, t2, -40
	mov ea, fp
	lde u32t, t4, -32
	mov t3, t4
	sbx t3, t3, 0, 16
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.read
	mov t0, a0
__L100:
__L101:
	mov ea, fp
	lde u32t, t2, -16
	mov ea, t2
	lde u32t, t1, 4
	mov ea, fp
	lde u32t, t2, -32
	cmp gteu, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L102
	mov ea, fp
	lde u32t, t3, -40
	mov t2, t3
	mov ea, fp
	lde u32t, t3, -32
	add t1, t2, t3
	mov ea, fp
	lde u32t, t4, -16
	mov ea, t4
	lde u32t, t3, 4
	mov ea, fp
	lde u32t, t4, -32
	sub t2, t3, t4
	mov t3, 0
	mov a2, t3
	mov a1, t2
	mov a0, t1
	tpr a0
	syscall SYS_MEM_SET
	mov t0, a0
__L102:
__L103:
	mov ea, fp
	lde u32t, t3, -40
	mov t2, t3
	mov ea, fp
	lde u32t, t4, -16
	mov ea, t4
	lde u32t, t3, 4
	add t1, t2, t3
	mov ea, fp
	lde u32t, t3, -4
	mov t2, t3
	mov ea, fp
	lde u32t, t3, -24
	mov a2, t3
	mov a1, t2
	mov a0, t1
	tpr a0
	tpr a1
	syscall SYS_MEM_COPY
	mov t0, a0
	mov ea, fp
	lde u32t, t2, -20
	mov ea, t2
	lde u32t, t1, 12
	mov ea, fp
	lde u32t, t2, -40
	mov ea, fp
	lde u32t, t4, -36
	mov t3, t4
	sbx t3, t3, 0, 16
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.write
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -40
	mov a0, t1
	cal free
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -24
	mov ea, fp
	lde u32t, t3, -16
	mov ea, t3
	lde u32t, t2, 4
	add t3, t2, t1
	mov ea, fp
	lde u32t, t1, -16
	mov ea, t1
	ste u32t, 4, t3
	mov t0, t3
	mov ea, fp
	lde u32t, t0, -12
	mov a0, t0
	add sp, 40
	ret

sbmk "fgetc_(stream: u32t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fgetc_:
	sub sp, 12
	mov ea, fp
	ste u32t, -4, a0
	psh t0
	add t2, fp, -8
	mov t0, t2
	mov t2, 1
	mov t3, 1
	mov ea, fp
	lde u32t, t4, -4
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal fread_
	mov t1, a0
	pop t0
	mov ea, fp
	ste u32t, -12, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t2, -12
	mov t3, 1
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	jfs __L104
	mov ea, fp
	lde u8t, t2, -8
	mov t1, t2
	sbx t1, t1, 0, 16
	mov t0, t1
	jmp __L105
__L104:
	mov t2, 1
	neg t1, t2
	mov t0, t1
__L105:
	mov a0, t0
	add sp, 12
	ret

sbmk "fputc_(c: i16t, stream: u32t*): i16t"
##
## Parameters:
## > a0 - c, is i16t
## > a1 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fputc_:
	sub sp, 12
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	ubx t0, t0, 0, 8
	mov ea, fp
	ste u8t, -12, t0
	psh t0
	psh t1
	add t1, fp, -12
	mov t0, t1
	mov t1, 1
	mov t3, 1
	mov ea, fp
	lde u32t, t4, -8
	mov a3, t4
	mov a2, t3
	mov a1, t1
	mov a0, t0
	cal fwrite_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 1
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	jfs __L106
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	jmp __L107
__L106:
	mov t2, 1
	neg t1, t2
	mov t0, t1
__L107:
	mov a0, t0
	add sp, 12
	ret

sbmk "getc_(stream: u32t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
getc_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	mov a0, t1
	cal fgetc_
	mov t0, a0
	mov a0, t0
	add sp, 4
	ret

sbmk "putc_(c: i16t, stream: u32t*): i16t"
##
## Parameters:
## > a0 - c, is i16t
## > a1 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
putc_:
	sub sp, 8
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	lde i16t, t1, -4
	mov ea, fp
	lde u32t, t2, -8
	mov a1, t2
	mov a0, t1
	cal fputc_
	mov t0, a0
	mov a0, t0
	add sp, 8
	ret

sbmk "fgets_(str: i8t*, n: i16t, stream: u32t*): i8t*"
##
## Parameters:
## > a0 - str, is i8t*
## > a1 - n, is i16t
## > a2 - stream, is u32t*
## Returns:
## < a0 - return value, is i8t*
## Additional Implementation Notes:
fgets_:
	sub sp, 20
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste i16t, -8, a1
	mov ea, fp
	ste u32t, -12, a2
	mov t0, 0
	mov ea, fp
	ste i16t, -16, t0
	mov ea, fp
	lde i16t, t1, -8
	mov t2, 0
	cmp lte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L108
	mov t0, 0
	mov a0, t0
	add sp, 20
	ret
__L108:
__L109:
__L110:
	mov ea, fp
	lde i16t, t1, -16
	mov ea, fp
	lde i16t, t3, -8
	mov t4, 1
	sub t2, t3, t4
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L111
	psh t0
	mov ea, fp
	lde u32t, t0, -12
	mov a0, t0
	cal fgetc_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -20
	mov t3, 1
	neg t2, t3
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L112
	jmp __L111
__L112:
__L113:
	mov ea, fp
	lde i16t, t2, -20
	mov t1, t2
	sbx t1, t1, 0, 8
	mov ea, fp
	lde u32t, t2, -4
	mov ea, fp
	lde i16t, t4, -16
	mov t3, t4
	inc t4
	mov ea, fp
	ste i16t, -16, t4
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 10
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L114
	jmp __L111
__L114:
__L115:
	jmp __L110
__L111:
	mov ea, fp
	lde i16t, t2, -16
	mov t3, 0
	cmp eq, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L118
	psh t0
	mov ea, fp
	lde u32t, t0, -12
	mov a0, t0
	cal feof_
	mov t1, a0
	pop t0
	cmp neq, t1, zr
	sel t0, 1, 0
__L118:
	cmp eq, t0, zr
	jtr __L116
	mov t0, 0
	mov a0, t0
	add sp, 20
	ret
__L116:
__L117:
	mov t1, 0
	mov ea, fp
	lde u32t, t2, -4
	mov ea, fp
	lde i16t, t3, -16
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	add sp, 20
	ret

sbmk "fputs_(str: i8t*, stream: u32t*): i16t"
##
## Parameters:
## > a0 - str, is i8t*
## > a1 - stream, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fputs_:
	sub sp, 12
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov t0, 0
	mov ea, fp
	ste u32t, -12, t0
__L119:
	mov ea, fp
	lde u32t, t1, -4
	mov ea, fp
	lde u32t, t2, -12
	add t1, t2
	mov ea, t1
	lde i8t, t0, 0
	cmp neq, t0, zr
	jfs __L120
	mov ea, fp
	lde u32t, t1, -12
	mov t0, t1
	inc t1
	mov ea, fp
	ste u32t, -12, t1
	jmp __L119
__L120:
	psh t0
	psh t1
	mov ea, fp
	lde u32t, t0, -4
	mov t1, 1
	mov ea, fp
	lde u32t, t3, -12
	mov ea, fp
	lde u32t, t4, -8
	mov a3, t4
	mov a2, t3
	mov a1, t1
	mov a0, t0
	cal fwrite_
	mov t2, a0
	pop t1
	pop t0
	mov ea, fp
	lde u32t, t3, -12
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	jfs __L121
	mov t1, 0
	mov t0, t1
	jmp __L122
__L121:
	mov t2, 1
	neg t1, t2
	mov t0, t1
__L122:
	mov a0, t0
	add sp, 12
	ret

sbmk "fprintf_(stream: u32t*, format: i8t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## > a1 - format, is i8t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fprintf_:
	sub sp, 8
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	lde u32t, t1, -4
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -8
	mov t0, t1
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 8
	ret

sbmk "fscanf_(stream: u32t*, format: i8t*): i16t"
##
## Parameters:
## > a0 - stream, is u32t*
## > a1 - format, is i8t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
fscanf_:
	sub sp, 8
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	lde u32t, t1, -4
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -8
	mov t0, t1
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 8
	ret

sbmk "main_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
main_:
	sub sp, 4
	psh t0
	cal MFS.load
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L123
	tpa t1, __str_125
	mov a0, t1
	cal printf
	mov t0, a0
	cal MFS.format
	mov t0, a0
__L123:
__L124:
	tpa t1, __str_126
	mov a0, t1
	cal MFS.create
	mov t0, a0
	tpa t1, __str_126
	tpa t2, __str_127
	mov t3, 16
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.write
	mov t0, a0
	psh t0
	tpa t0, __str_126
	tpa t2, g__read_buf
	mov t3, 128
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal MFS.read
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	tpa t1, __str_128
	mov ea, fp
	lde i16t, t2, -4
	tpa t3, g__read_buf
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal printf
	mov t0, a0
	tpa t1, __str_126
	tpa t2, __str_129
	mov t3, 17
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal MFS.write
	mov t0, a0
	psh t0
	tpa t0, __str_126
	tpa t2, g__read_buf
	mov t3, 128
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal MFS.read
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	tpa t1, __str_130
	tpa t2, g__read_buf
	mov a1, t2
	mov a0, t1
	cal printf
	mov t0, a0
	tpa t1, __str_126
	mov a0, t1
	cal MFS.delete
	mov t0, a0
	psh t0
	tpa t0, __str_126
	tpa t2, g__read_buf
	mov t3, 128
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal MFS.read
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov t3, 1
	neg t2, t3
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L131
	tpa t1, __str_133
	mov a0, t1
	cal printf
	mov t0, a0
__L131:
__L132:
	add sp, 4
	ret

g___file_pool:	res u32t 160, 0
g___null_buf:	res i8t 1, 0
g___gc_buf:	res i8t 257, 0
g___gc_pos:	emb u32t 0
g___gc_len:	emb u32t 0
g__read_buf:	res i8t 128, 0
__str_125:	emb string "No filesystem found, formatting...\n"
__str_126:	emb string "hello.txt"
__str_127:	emb string "Hello from MFS!"
__str_128:	emb string "Read %d bytes: %s\n"
__str_129:	emb string "Updated content."
__str_130:	emb string "After write: %s\n"
__str_133:	emb string "File deleted successfully.\n"

bmk "MFS - About"

# MFS (Mnemonimov File System)
# A simple FAT-based filesystem layered over Mnemonimov storage.
#
# Default storage layout (1 block = 128 bytes):
#   Block 0:       Superblock
#   Blocks 1..4:   FAT  (256 u16 entries covering all data blocks)
#   Blocks 5..8:   Root directory  (variable-length entries)
#   Blocks 9..264: Data  (256 blocks, 32 KB total)
#
# Directory entries are variable-length and 2-byte aligned:
#   +0  u16  rec_len      total bytes occupied by this entry
#   +2  u8   name_len     length of name field (not null-terminated)
#   +3  u8   flags        bit 0: in-use
#   +4  u16  first_block  first FAT-chained data block (MFS_FAT_EOF = none)
#   +6  u32  file_size    file size in bytes
#   +10 u8[] name         name_len bytes
#
# Deleted entries keep their rec_len so directory walks remain intact.
# MFS.create reuses a deleted entry when its rec_len fits the new name.
#
# Public API (all in a0 unless noted):
#   MFS.format  - write a fresh filesystem to storage
#   MFS.load    - load an existing filesystem; returns MFS_ERR_INVALID on bad magic
#   MFS.open    - find file by name; returns pa-rel dirent pointer or 0
#   MFS.create  - create a new empty file entry
#   MFS.read    - read file data into a buffer; returns bytes read or -1
#   MFS.write   - replace file data from a buffer
#   MFS.delete  - delete a file and free its blocks
#
# Call MFS.format once to initialise, then MFS.load on every subsequent startup.
# The FAT and directory are kept in the MFS_DATA buffers; every mutating call
# flushes the affected buffer(s) back to storage before returning.

bmk "MFS - Constants"

def MFS_BLOCK_SIZE       128
def MFS_BLOCK_SIZE_LOG2  7
def MFS_FAT_START_BLOCK  1
def MFS_FAT_BLOCK_COUNT  4
def MFS_DIR_START_BLOCK  5
def MFS_DIR_BLOCK_COUNT  4
def MFS_DATA_START_BLOCK 9
def MFS_DATA_BLOCK_COUNT 256

def MFS_MAGIC    0x4D465300
def MFS_VERSION  1

def MFS_FAT_FREE 0x0000
def MFS_FAT_EOF  0xFFFF

# Superblock field offsets
def MFS_SB_MAGIC           0
def MFS_SB_VERSION         4
def MFS_SB_BLOCK_SIZE_LOG2 5
def MFS_SB_BLOCK_COUNT     6
def MFS_SB_FAT_START       8
def MFS_SB_FAT_BLOCK_COUNT 10
def MFS_SB_DIR_START       12
def MFS_SB_DIR_BLOCK_COUNT 14
def MFS_SB_DATA_START      16
def MFS_SB_FREE_COUNT      18

# Directory entry field offsets
def MFS_DIRENT_REC_LEN     0
def MFS_DIRENT_NAME_LEN    2
def MFS_DIRENT_FLAGS       3
def MFS_DIRENT_FIRST_BLOCK 4
def MFS_DIRENT_FILE_SIZE   6
def MFS_DIRENT_NAME        10
def MFS_DIRENT_HEADER_SIZE 10
def MFS_DIRENT_MIN_REC_LEN 12    # 10-byte header + 1-char name + 1 alignment pad

def MFS_FLAG_IN_USE 0x01

# Return codes
def MFS_OK            0
def MFS_ERR_NOT_FOUND 1
def MFS_ERR_NO_SPACE  2
def MFS_ERR_EXISTS    3
def MFS_ERR_INVALID   4

bmk "MFS - Data"

MFS_DATA:
    .superblock: res u8t MFS_BLOCK_SIZE
    .fat_buf:    res u8t MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
    .dir_buf:    res u8t MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
    .block_buf:  res u8t MFS_BLOCK_SIZE

bmk "MFS - Internals"

MFS_INTERNAL:

    sbmk "fat_alloc(): block_index | MFS_FAT_EOF"
    # Find and mark a free data block. Returns its index, or MFS_FAT_EOF if full.
    # < a0: block index, or MFS_FAT_EOF
    .fat_alloc:
        psh s0
        mov s0, 0
        @loop:
            cmp gte, s0, MFS_DATA_BLOCK_COUNT
            jtr @not_found+
            cea MFS_DATA.fat_buf, s0, 2
            lde u16t, t0, 0
            cmp eq, t0, MFS_FAT_FREE
            jtr @found+
            inc s0
            jmp @loop-
        @not_found:
            mov a0, MFS_FAT_EOF
            jmp @done+
        @found:
            ste u16t, 0, MFS_FAT_EOF    # mark allocated but end-of-chain
            mov a0, s0
        @done:
        pop s0
        ret

    sbmk "fat_get(block): next_block"
    # Read a FAT entry.
    # > a0: block index
    # < a0: FAT entry value (MFS_FAT_EOF at end of chain)
    .fat_get:
        cea MFS_DATA.fat_buf, a0, 2
        lde u16t, a0, 0
        ret

    sbmk "fat_set(block, value)"
    # Write a FAT entry.
    # > a0: block index, a1: value
    .fat_set:
        cea MFS_DATA.fat_buf, a0, 2
        ste u16t, 0, a1
        ret

    sbmk "fat_flush()"
    # Flush the FAT buffer to storage.
    .fat_flush:
        mov a0, MFS_FAT_START_BLOCK * MFS_BLOCK_SIZE
        mov a1, MFS_DATA.fat_buf
        mov a2, MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
        syscall SYS_STORAGE_WRITE
        ret

    sbmk "dir_flush()"
    # Flush the directory buffer to storage.
    .dir_flush:
        mov a0, MFS_DIR_START_BLOCK * MFS_BLOCK_SIZE
        mov a1, MFS_DATA.dir_buf
        mov a2, MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        syscall SYS_STORAGE_WRITE
        ret

    sbmk "fat_free_chain(first_block)"
    # Release all blocks in a FAT chain back to free.
    # > a0: first block index
    .fat_free_chain:
        vpsh s0..s1
        mov s0, a0
        @loop:
            cmp eq, s0, MFS_FAT_EOF
            jtr @done+
            cmp eq, s0, MFS_FAT_FREE
            jtr @done+
            cea MFS_DATA.fat_buf, s0, 2
            lde u16t, s1, 0             # s1 = next block before freeing
            ste u16t, 0, MFS_FAT_FREE
            mov s0, s1
            jmp @loop-
        @done:
        vpop s0..s1
        ret

    sbmk "name_eq(dirent, query): bool"
    # Compare a dirent's name against a null-terminated query string.
    # > a0: pa-rel dirent pointer
    # > a1: pa-rel null-terminated query string
    # < a0: 1 if equal, 0 otherwise
    .name_eq:
        vpsh s0..s3
        # s0 = dirent name_len
        # s1 = pa-rel ptr to dirent name bytes
        # s2 = pa-rel ptr to query string
        # s3 = byte index
        cea a0, 0, 1
        lde u8t, s0, MFS_DIRENT_NAME_LEN
        add s1, a0, MFS_DIRENT_NAME
        mov s2, a1
        mov s3, 0
        @loop:
            cea s2, 0, 1
            lde u8t, t0, 0
            cmp eq, t0, 0
            jtr @query_end+
            cmp gte, s3, s0
            jtr @not_equal+
            cea s1, s3, 1
            lde u8t, t1, 0
            cmp neq, t0, t1
            jtr @not_equal+
            inc s2
            inc s3
            jmp @loop-
        @query_end:
            cmp eq, s3, s0
            jfs @not_equal+
            mov a0, 1
            jmp @done+
        @not_equal:
            mov a0, 0
        @done:
        vpop s0..s3
        ret

    sbmk "dirent_find(name): dirent | 0"
    # Walk the directory buffer and return a pa-rel pointer to the named entry.
    # > a0: pa-rel null-terminated filename
    # < a0: pa-rel dirent pointer, or 0 if not found
    .dirent_find:
        vpsh s0..s3
        # s0 = scan cursor, s1 = dir buf end, s2 = query name, s3 = rec_len
        mov s0, MFS_DATA.dir_buf
        mov s1, MFS_DATA.dir_buf + MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov s2, a0
        @loop:
            sub t0, s1, s0
            cmp lt, t0, MFS_DIRENT_MIN_REC_LEN
            jtr @not_found+
            cea s0, 0, 1
            lde u16t, s3, MFS_DIRENT_REC_LEN
            cmp eq, s3, 0
            jtr @not_found+
            lde u8t, t0, MFS_DIRENT_FLAGS
            and t0, MFS_FLAG_IN_USE
            cmp eq, t0, 0
            jtr @advance+
            mov a0, s0
            mov a1, s2
            cal .name_eq
            cmp eq, a0, 1
            jtr @found+
            @advance:
            add s0, s3
            jmp @loop-
        @not_found:
            mov a0, 0
            jmp @done+
        @found:
            mov a0, s0
        @done:
        vpop s0..s3
        ret

bmk "MFS - Public API"

MFS:

    sbmk "MFS.format()"
    # Write a fresh filesystem to storage and initialise the in-memory buffers.
    .format:
        # Zero all three buffers before writing
        mov a0, MFS_DATA.superblock
        mov a1, MFS_BLOCK_SIZE
        mov a2, 0
        syscall SYS_MEM_SET

        mov a0, MFS_DATA.fat_buf
        mov a1, MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
        mov a2, 0
        syscall SYS_MEM_SET

        mov a0, MFS_DATA.dir_buf
        mov a1, MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov a2, 0
        syscall SYS_MEM_SET

        # Fill superblock fields
        str u32t, MFS_DATA.superblock + MFS_SB_MAGIC,           MFS_MAGIC
        str u8t,  MFS_DATA.superblock + MFS_SB_VERSION,         MFS_VERSION
        str u8t,  MFS_DATA.superblock + MFS_SB_BLOCK_SIZE_LOG2, MFS_BLOCK_SIZE_LOG2
        str u16t, MFS_DATA.superblock + MFS_SB_BLOCK_COUNT,     MFS_DATA_BLOCK_COUNT
        str u16t, MFS_DATA.superblock + MFS_SB_FAT_START,       MFS_FAT_START_BLOCK
        str u16t, MFS_DATA.superblock + MFS_SB_FAT_BLOCK_COUNT, MFS_FAT_BLOCK_COUNT
        str u16t, MFS_DATA.superblock + MFS_SB_DIR_START,       MFS_DIR_START_BLOCK
        str u16t, MFS_DATA.superblock + MFS_SB_DIR_BLOCK_COUNT, MFS_DIR_BLOCK_COUNT
        str u16t, MFS_DATA.superblock + MFS_SB_DATA_START,      MFS_DATA_START_BLOCK
        str u16t, MFS_DATA.superblock + MFS_SB_FREE_COUNT,      MFS_DATA_BLOCK_COUNT

        # Flush superblock, FAT, and directory to storage
        mov a0, 0
        mov a1, MFS_DATA.superblock
        mov a2, MFS_BLOCK_SIZE
        syscall SYS_STORAGE_WRITE

        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        ret

    sbmk "MFS.load(): error"
    # Load the filesystem from storage into the in-memory buffers.
    # Verifies the superblock magic; returns MFS_ERR_INVALID on mismatch.
    # < a0: MFS_OK or MFS_ERR_INVALID
    .load:
        mov a0, MFS_DATA.superblock
        mov a1, 0
        mov a2, MFS_BLOCK_SIZE
        syscall SYS_STORAGE_READ

        lod u32t, t0, MFS_DATA.superblock + MFS_SB_MAGIC
        cmp neq, t0, MFS_MAGIC
        jtr @invalid+

        mov a0, MFS_DATA.fat_buf
        mov a1, MFS_FAT_START_BLOCK * MFS_BLOCK_SIZE
        mov a2, MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
        syscall SYS_STORAGE_READ

        mov a0, MFS_DATA.dir_buf
        mov a1, MFS_DIR_START_BLOCK * MFS_BLOCK_SIZE
        mov a2, MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        syscall SYS_STORAGE_READ

        mov a0, MFS_OK
        ret

        @invalid:
        mov a0, MFS_ERR_INVALID
        ret

    sbmk "MFS.open(name): dirent | 0"
    # Find a file by name. Returns its pa-rel dirent pointer, or 0 if not found.
    # > a0: pa-rel null-terminated filename
    # < a0: pa-rel dirent pointer, or 0
    .open:
        tpr a0
        cal MFS_INTERNAL.dirent_find
        ret

    sbmk "MFS.create(name): error"
    # Create a new empty file entry in the directory.
    # Reuses a deleted entry if one is large enough; otherwise appends.
    # > a0: pa-rel null-terminated filename
    # < a0: MFS_OK, MFS_ERR_EXISTS, or MFS_ERR_NO_SPACE
    .create:
        vpsh s0..s4
        # s0 = filename, s1 = name_len, s2 = needed rec_len
        # s3 = scan cursor, s4 = dir buf end
        tpr a0
        mov s0, a0

        # Compute name_len via strlen
        mov s1, a0
        @strlen:
            cea s1, 0, 1
            lde u8t, t0, 0
            cmp eq, t0, 0
            jtr @strlen_done+
            inc s1
            jmp @strlen-
        @strlen_done:
        sub s1, s0

        # Reject if file already exists
        cal MFS_INTERNAL.dirent_find
        cmp neq, a0, 0
        jtr @exists+

        # needed rec_len = header + name_len, rounded up to 2-byte alignment
        add s2, MFS_DIRENT_HEADER_SIZE, s1
        and t0, s2, 1
        add s2, t0

        mov s3, MFS_DATA.dir_buf
        mov s4, MFS_DATA.dir_buf + MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov a0, 0                           # candidate slot (0 = none yet)

        # First-fit scan for a deleted entry with sufficient rec_len
        @scan:
            sub t0, s4, s3
            cmp lt, t0, MFS_DIRENT_MIN_REC_LEN
            jtr @scan_done+
            cea s3, 0, 1
            lde u16t, t0, MFS_DIRENT_REC_LEN
            cmp eq, t0, 0
            jtr @scan_done+
            lde u8t, t1, MFS_DIRENT_FLAGS
            and t1, MFS_FLAG_IN_USE
            cmp neq, t1, 0
            jtr @advance_scan+              # in-use: skip
            cmp lt, t0, s2
            jtr @advance_scan+              # too small: skip
            cmp neq, a0, 0
            jtr @advance_scan+              # already have a candidate: skip
            mov a0, s3
            @advance_scan:
            add s3, t0
            jmp @scan-
        @scan_done:

        cmp neq, a0, 0
        jtr @write_entry+

        # No free slot found; try to append at end of written entries (s3)
        sub t0, s4, s3
        cmp lt, t0, s2
        jtr @no_space+
        mov a0, s3

        @write_entry:
        mov s3, a0
        cea s3, 0, 1
        ste u16t, MFS_DIRENT_REC_LEN,     s2
        ste u8t,  MFS_DIRENT_NAME_LEN,    s1
        ste u8t,  MFS_DIRENT_FLAGS,       MFS_FLAG_IN_USE
        ste u16t, MFS_DIRENT_FIRST_BLOCK, MFS_FAT_EOF
        ste u32t, MFS_DIRENT_FILE_SIZE,   0
        add a0, s3, MFS_DIRENT_NAME
        mov a1, s0
        mov a2, s1
        syscall SYS_MEM_COPY

        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_OK
        jmp @done+

        @exists:
        mov a0, MFS_ERR_EXISTS
        jmp @done+

        @no_space:
        mov a0, MFS_ERR_NO_SPACE

        @done:
        vpop s0..s4
        ret

    sbmk "MFS.read(name, dst, max): bytes_read | -1"
    # Read a file's data into a buffer.
    # > a0: pa-rel null-terminated filename
    # > a1: pa-rel destination buffer
    # > a2: maximum bytes to read
    # < a0: bytes read, or -1 if file not found
    .read:
        vpsh s0..s5
        # s0 = dst buffer, s1 = max bytes / clamped file size
        # s2 = dirent ptr, s3 = current FAT block index, s4 unused, s5 = bytes read
        tpr a0
        tpr a1
        mov s0, a1
        mov s1, a2

        cal MFS_INTERNAL.dirent_find
        cmp eq, a0, 0
        jtr @not_found+
        mov s2, a0

        cea s2, 0, 1
        lde u16t, s3, MFS_DIRENT_FIRST_BLOCK
        lde u32t, t0, MFS_DIRENT_FILE_SIZE
        cmp lt, t0, s1
        mvc s1, t0                          # s1 = min(file_size, max)

        mov s5, 0                           # bytes read so far

        @loop:
            cmp gte, s5, s1
            jtr @done_reading+
            cmp eq, s3, MFS_FAT_EOF
            jtr @done_reading+

            # Read storage block s3 into block_buf
            add a1, MFS_DATA_START_BLOCK, s3
            sll a1, MFS_BLOCK_SIZE_LOG2
            mov a0, MFS_DATA.block_buf
            mov a2, MFS_BLOCK_SIZE
            syscall SYS_STORAGE_READ

            # Copy min(MFS_BLOCK_SIZE, remaining) bytes to destination
            sub t0, s1, s5
            cmp lt, t0, MFS_BLOCK_SIZE
            jfs @full_block+
            mov t1, t0
            jmp @do_copy+
            @full_block:
            mov t1, MFS_BLOCK_SIZE
            @do_copy:
            add a0, s0, s5
            mov a1, MFS_DATA.block_buf
            mov a2, t1
            syscall SYS_MEM_COPY
            add s5, t1

            # Advance FAT chain
            mov a0, s3
            cal MFS_INTERNAL.fat_get
            mov s3, a0
            jmp @loop-

        @done_reading:
        mov a0, s5
        jmp @done+

        @not_found:
        mov a0, -1

        @done:
        vpop s0..s5
        ret

    sbmk "MFS.write(name, src, size): error"
    # Replace a file's data with the contents of a buffer.
    # Frees the existing chain, allocates new blocks, then flushes FAT and directory.
    # > a0: pa-rel null-terminated filename
    # > a1: pa-rel source buffer
    # > a2: size in bytes
    # < a0: MFS_OK, MFS_ERR_NOT_FOUND, or MFS_ERR_NO_SPACE
    .write:
        vpsh s0..s5
        # s0 = src buffer, s1 = total size to write
        # s2 = dirent ptr, s3 = bytes written
        # s4 = first allocated block, s5 = last allocated block
        tpr a0
        tpr a1
        mov s0, a1
        mov s1, a2

        cal MFS_INTERNAL.dirent_find
        cmp eq, a0, 0
        jtr @not_found+
        mov s2, a0

        # Free the existing FAT chain
        cea s2, 0, 1
        lde u16t, a0, MFS_DIRENT_FIRST_BLOCK
        cmp eq, a0, MFS_FAT_EOF
        jtr @skip_free+
        cal MFS_INTERNAL.fat_free_chain
        @skip_free:

        mov s3, 0
        mov s4, MFS_FAT_EOF             # first block of new chain
        mov s5, MFS_FAT_EOF             # last block of new chain

        @loop:
            cmp gte, s3, s1
            jtr @done_writing+

            cal MFS_INTERNAL.fat_alloc
            cmp eq, a0, MFS_FAT_EOF
            jtr @no_space+

            # Record the first block of the chain
            cmp neq, s4, MFS_FAT_EOF
            jtr @not_first+
            mov s4, a0
            @not_first:

            # Link the previous block to this one
            cmp eq, s5, MFS_FAT_EOF
            jtr @no_prev+
            psh a0
            mov a1, a0
            mov a0, s5
            cal MFS_INTERNAL.fat_set
            pop a0
            @no_prev:
            mov s5, a0

            # Determine bytes to write for this block
            sub t0, s1, s3
            cmp lt, t0, MFS_BLOCK_SIZE
            jfs @full_write+
            mov t1, t0
            jmp @have_count+
            @full_write:
            mov t1, MFS_BLOCK_SIZE
            @have_count:

            # Copy from source into block_buf, zero-padding any remainder
            mov a0, MFS_DATA.block_buf
            add a1, s0, s3
            mov a2, t1
            syscall SYS_MEM_COPY

            cmp gte, t1, MFS_BLOCK_SIZE
            jtr @no_pad+
            add a0, MFS_DATA.block_buf, t1
            sub a1, MFS_BLOCK_SIZE, t1
            mov a2, 0
            syscall SYS_MEM_SET
            @no_pad:

            # Write block_buf to storage
            add a0, MFS_DATA_START_BLOCK, s5
            sll a0, MFS_BLOCK_SIZE_LOG2
            mov a1, MFS_DATA.block_buf
            mov a2, MFS_BLOCK_SIZE
            syscall SYS_STORAGE_WRITE

            add s3, t1
            jmp @loop-

        @done_writing:
        cea s2, 0, 1
        ste u16t, MFS_DIRENT_FIRST_BLOCK, s4
        ste u32t, MFS_DIRENT_FILE_SIZE,   s1
        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_OK
        jmp @done+

        @not_found:
        mov a0, MFS_ERR_NOT_FOUND
        jmp @done+

        @no_space:
        # Roll back any partially allocated blocks
        cmp eq, s4, MFS_FAT_EOF
        jtr @no_rollback+
        mov a0, s4
        cal MFS_INTERNAL.fat_free_chain
        @no_rollback:
        cea s2, 0, 1
        ste u16t, MFS_DIRENT_FIRST_BLOCK, MFS_FAT_EOF
        ste u32t, MFS_DIRENT_FILE_SIZE,   0
        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_ERR_NO_SPACE

        @done:
        vpop s0..s5
        ret

    sbmk "MFS.delete(name): error"
    # Delete a file: frees its FAT chain and clears its in-use flag.
    # The entry's rec_len is preserved so the directory walk stays intact;
    # MFS.create will reuse the slot when writing a file that fits.
    # > a0: pa-rel null-terminated filename
    # < a0: MFS_OK or MFS_ERR_NOT_FOUND
    .delete:
        vpsh s0..s1
        tpr a0
        mov s0, a0

        cal MFS_INTERNAL.dirent_find
        cmp eq, a0, 0
        jtr @not_found+
        mov s1, a0

        cea s1, 0, 1
        lde u16t, a0, MFS_DIRENT_FIRST_BLOCK
        cmp eq, a0, MFS_FAT_EOF
        jtr @skip_free+
        cal MFS_INTERNAL.fat_free_chain
        @skip_free:

        cea s1, 0, 1
        ste u8t, MFS_DIRENT_FLAGS, 0

        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_OK
        jmp @done+

        @not_found:
        mov a0, MFS_ERR_NOT_FOUND

        @done:
        vpop s0..s1
        ret

bmk "TOP"

bmk "Allocator - About"

# Author: @theernie on Discord
# How to use:
#   this general purpose allocator exposes 3 functions for managing dynamic memory.
#   all allocations are 16-byte aligned.
#
#   malloc:
#   > a0: u32t, bytes requested
#   < a0: u32t, pointer to allocated block. NULL if allocation failed
#
#   free:
#   > a0: u32t, pointer to block to free
#
#   realloc:
#   > a0: u32t, pointer to allocated block to reallocate
#   > a1: u32t, amount of bytes to reallocate to
#   < a0: u32t, pointer to reallocated block. NULL if allocation failed
#
#   edge cases:
#     malloc(0)        returns NULL
#     free(NULL)       is a NOP
#     realloc(NULL, n) behaves like malloc(n)
#     realloc(ptr, 0)  behaves like free(ptr)
#
#   customize heap size:
#     default heap size is 512 KiB
#     to customize it, change the value at ALLOC_DATA.HEAP_SIZE
#     the value must be a multiple of 16, else you get undefined behaviour
#
#   fragmentation:
#     fragmentation seems to be a non issue as of my tests,
#     though i dont know how bad it can really get.
#     you can test current fragmentation by calling:
#
#   ALLOC_INTERNAL.fragmentation_index:
#   < a0: f32t, current heap fragmentation from 0.0 (very good) to 1.0 (very bad)
#
#   known issues:
#     if the heap reaches a certain fragmentation,
#     the free list grows too long, so the watchdog kills
#     the allocator before it finishes.
#     currently there are no yields in there to reduce the performance overhead,
#     but if that becomes an issue to you ask @TheErnie on the discord,
#     or add a "yield" into the traversal loops yourself

bmk "Allocator - Structs"

# Allocator Header:
#   prev_info: u32t
#   curr_info: u32t
#   prev_free: u32t (pointer to prev free block)
#   next_free: u32t (pointer to next free block)

ALLOC_HEADER:
    .prev_info: emb u32t 0
    .curr_info: emb u32t 0
    .prev_free: emb u32t 0
    .next_free: emb u32t 0
    def ._PREV_INFO (.prev_info - ALLOC_HEADER)
    def ._CURR_INFO (.curr_info - ALLOC_HEADER)
    def ._PREV_FREE (.prev_free - ALLOC_HEADER)
    def ._NEXT_FREE (.next_free - ALLOC_HEADER)
    def .SIZE ($ - ALLOC_HEADER)
    def .INFO_SIZE 8 # 2 * sizeof(u32t)
    def .INFO_MASK_SIZE ~0x7
    def .INFO_MASK_USED  0x1

bmk "Allocator - Data"

ALLOC_DATA:
    # Must be multiple of 16, else UB
    def .HEAP_SIZE 0x20000000 # 512 MiB
    .HEAP_PADDING: res u8t 16 - ($ & 0b1111)
    .HEAP: res u8t .HEAP_SIZE
    .FREE_LIST: emb u32t 0
    .INITIALIZED: emb u8t false
    def .SENTINEL_START .HEAP
    def .SENTINEL_END .HEAP + .HEAP_SIZE - ALLOC_HEADER.INFO_SIZE

bmk "Allocator - Internals"

ALLOC_INTERNAL:
    .add_free_list:
        # > a0: u32t, pointer to header
        cea a0, ALLOC_HEADER._PREV_FREE, 1
        ste u32t, 0, 0
        lod u32t, t0, ALLOC_DATA.FREE_LIST
        cea a0, ALLOC_HEADER._NEXT_FREE, 1
        ste u32t, 0, t0
        @if_free_list_null:
            cmp eq, t0, 0
            jtr @endif+
            cea t0, ALLOC_HEADER._PREV_FREE, 1
            ste u32t, 0, a0
        @endif:
        str u32t, ALLOC_DATA.FREE_LIST, a0
        ret

    .remove_free_list:
        # > a0: u32t, pointer to header
        cea a0, ALLOC_HEADER._PREV_FREE, 1
        lde u32t, t0, 0
        cea a0, ALLOC_HEADER._NEXT_FREE, 1
        lde u32t, t1, 0
        lod u32t, t2, ALLOC_DATA.FREE_LIST
        @if_free_list_eq_header:
            cmp neq, t2, a0
            jtr @endif+
            str u32t, ALLOC_DATA.FREE_LIST, t1
        @endif:
        @if_prev_free_not_null:
            cmp eq, t0, 0
            jtr @endif+
            cea t0, ALLOC_HEADER._NEXT_FREE, 1
            ste u32t, 0, t1
        @endif:
        @if_next_free_not_null:
            cmp eq, t1, 0
            jtr @endif+
            cea t1, ALLOC_HEADER._PREV_FREE, 1
            ste u32t, 0, t0
        @endif:
        ret

    .header_next:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to next header
        cea a0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        add a0, ALLOC_HEADER.INFO_SIZE
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add a0, t0
        ret

    .header_prev:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to prev header
        cea a0, ALLOC_HEADER._PREV_INFO, 1
        lde u32t, t0, 0
        sub a0, ALLOC_HEADER.INFO_SIZE
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        sub a0, t0
        ret

    .coalesce_next:
        # > a0: u32t, pointer to header
        # < a0:  u8t, bool was coalesced
        #   s0: current header
        #   s1: next header
        #   s2: next next header
        #   s3: new size
        vpsh s0..s3
        mov s0, a0
        cal .header_next
        mov s1, a0
        cal .header_next
        mov s2, a0
        cea s1, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_USED
        @if_header_used:
            cmp eq, t0, 0
            jtr @endif+
            mov a0, false
            jmp @return+
        @endif:
        mov a0, s1
        cal .remove_free_list
        mov s3, ALLOC_HEADER.INFO_SIZE
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add s3, t0
        cea s1, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add s3, t0
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_USED
        orr t0, s3
        cea s2, ALLOC_HEADER._PREV_INFO, 1
        ste u32t, 0, t0
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ~ALLOC_HEADER.INFO_MASK_SIZE
        orr t0, s3
        ste u32t, 0, t0
        mov a0, true
        @return:
        vpop s0..s3
        ret

    .coalesce_prev:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to coalesced header
        #   s0: u32t, pointer to header
        psh s0
        mov s0, a0
        cea s0, ALLOC_HEADER._PREV_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_USED
        @if_not_used:
            cmp eq, t0, 1
            jtr @endif+
            cal .header_prev
            mov s0, a0
            cal .coalesce_next
        @endif:
        mov a0, s0
        pop s0
        ret

    .coalesce:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to coalesced header
        #   s0: u32t, pointer to header
        psh s0
        mov s0, a0
        cal .coalesce_next
        mov a0, s0
        cal .coalesce_prev
        pop s0
        ret

    .initialize:
        mov t0, 0b1
        mov t1, ALLOC_DATA.HEAP_SIZE
        sub t1, 2 * ALLOC_HEADER.INFO_SIZE
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._PREV_INFO, t0
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._CURR_INFO, t1
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._PREV_FREE, 0
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._NEXT_FREE, 0
        str u32t, ALLOC_DATA.SENTINEL_END   + ALLOC_HEADER._PREV_INFO, t1
        str u32t, ALLOC_DATA.SENTINEL_END   + ALLOC_HEADER._CURR_INFO, t0
        mov a0, ALLOC_DATA.SENTINEL_START
        cal .add_free_list
        str u8t, ALLOC_DATA.INITIALIZED, true
        ret

    .find_free_block:
        # > a0: u32t, requested size, pre-aligned
        # < a0: u32t, pointer to header | NULL
        lod u32t, t0, ALLOC_DATA.FREE_LIST
        @while_header_not_null:
            cmp eq, t0, 0
            jtr @endwhile+
            cea t0, ALLOC_HEADER._CURR_INFO, 1
            lde u32t, t1, 0
            and t1, ALLOC_HEADER.INFO_MASK_SIZE
            @if_size_gte_requested:
                cmp lt, t1, a0
                jtr @endif+
                mov a0, t0
                jmp @return+
            @endif:
            cea t0, ALLOC_HEADER._NEXT_FREE, 1
            lde u32t, t0, 0
            jmp @while_header_not_null-
        @endwhile:
        mov a0, 0
        @return:
        ret

    .split_block:
        # > a0: u32t, pointer to header
        # > a1: u32t, requested size, pre-aligned
        # < a0: u32t, pointer to split block header
        #   s0: u32t, pointer to header, a0
        #   s1: u32t, requested size, a1
        #   s2: u32t, split size
        #   s3: u32t, pointer to split block header
        #   s4: u32t, header current info
        vpsh s0..s4
        mov s0, a0
        mov s1, a1
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add t1, s1, ALLOC_HEADER.INFO_SIZE + 16 # 16 byte alignment
        @if_split_size_too_small:
            cmp gte, t0, t1
            jtr @endif+
            mov a0, 0
            jmp @return+
        @endif:
        sub s2, t0, s1
        sub s2, ALLOC_HEADER.INFO_SIZE
        cal .header_next
        cea a0, ALLOC_HEADER._PREV_INFO, 1
        ste u32t, 0, s2
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, s4, 0
        and s4, ALLOC_HEADER.INFO_MASK_USED
        orr s4, s1
        ste u32t, 0, s4
        mov a0, s0
        cal .header_next
        mov s3, a0
        and t0, s4, ALLOC_HEADER.INFO_MASK_USED
        orr t0, s1
        cea s3, ALLOC_HEADER._PREV_INFO, 1
        ste u32t, 0, t0
        cea s3, ALLOC_HEADER._CURR_INFO, 1
        ste u32t, 0, s2
        mov a0, s3
        cal .add_free_list
        mov a0, s3
        cal .coalesce_next
        mov a0, s3
        @return:
        vpop s0..s4
        ret

    .fragmentation_index:
        # < a0: f32t, heap fragmentation index 0.0 (low) to 1.0 (high)
        #   s0: u32t, size of largest free block
        #   s1: u32t, total free heap memory
        #   s2: u32t, pointer to current block
        vpsh s0..s2
        mov s0, 0
        mov s1, 0
        lod u32t, s2, ALLOC_DATA.FREE_LIST
        @while_not_at_end:
            cmp neq, s2, 0
            jfs @endwhile+
            cea s2, ALLOC_HEADER._CURR_INFO, 1
            lde u32t, t0, 0
            cea s2, ALLOC_HEADER._NEXT_FREE, 1
            lde u32t, s2, 0
            cmp gt, t0, s0
            mvc s0, t0
            add s1, t0
            jmp @while_not_at_end-
        @endwhile:
        @if_no_free_memory:
            cmp eq, s1, 0
            jfs @endif+
            mov a0, 0.0
            jmp @return+
        @endif:
        fctf s0
        fctf s1
        fdiv a0,  s0, s1
        fsub a0, 1.0, a0
        @return:
        vpop s0..s2
        ret


bmk "Allocator - Interface"

sbmk "malloc(size: u32): void*"
## Allocates a section of memory
## Parameters:
## > a0 - Requested allocation size in bytes
## Returns:
## < a0 - Pointer to allocation or NULL
## Additional Implementation Notes:
## s0 - saved a0
## s1 - block candidate header
malloc:
    vpsh s0..s1
    mov s0, a0
    @if_size_is_zero:
        cmp eq, s0, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    lod u8t, t0, ALLOC_DATA.INITIALIZED
    @if_not_initialized:
        cmp eq, t0, false
        jfs @endif+
        cal ALLOC_INTERNAL.initialize
    @endif:
    add s0,  0b1111
    and s0, ~0b1111
    @if_overflowed:
        cmp eq, s0, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    mov a0, s0
    cal ALLOC_INTERNAL.find_free_block
    mov s1, a0
    @if_out_of_memory:
        cmp eq, s1, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    mov a1, s0
    cal ALLOC_INTERNAL.split_block
    mov a0, s1
    cal ALLOC_INTERNAL.remove_free_list
    cea s1, ALLOC_HEADER._CURR_INFO, 1
    lde u32t, t0, 0
    orr t0, 0b1
    ste u32t, 0, t0
    mov a0, s1
    cal ALLOC_INTERNAL.header_next
    cea a0, ALLOC_HEADER._PREV_INFO, 1
    lde u32t, t0, 0
    orr t0, 0b1
    ste u32t, 0, t0
    mov a0, s1
    add a0, ALLOC_HEADER.INFO_SIZE
    @if_out_of_heap_bounds:
        cmp gte, a0, ALLOC_DATA.HEAP + ALLOC_DATA.HEAP_SIZE
        jfs @endif+
        break
    @endif:
    @return:
    vpop s0..s1
    ret

sbmk "free(mem_block: void*): void"
## Frees a section of memory so that it can be reused later on
## Parameters:
## > a0 - Pointer to the memory block to free
## Returns:
##   Nothing
## Additional Implementation Notes:
## s0 - saved a0
free:
    # > a0: u32t, pointer to free
    #   s0: u32t, a0 saved
    psh s0
    mov s0, a0
    @if_ptr_is_null:
        cmp eq, s0, 0
        jfs @endif+
        jmp @return+
    @endif:
    sub s0, ALLOC_HEADER.INFO_SIZE
    cea s0, ALLOC_HEADER._CURR_INFO, 1
    lde u32t, t0, 0
    xor t0, ALLOC_HEADER.INFO_MASK_USED
    ste u32t, 0, t0
    mov a0, s0
    cal ALLOC_INTERNAL.header_next
    cea a0, ALLOC_HEADER._PREV_INFO, 1
    lde u32t, t0, 0
    xor t0, ALLOC_HEADER.INFO_MASK_USED
    ste u32t, 0, t0
    mov a0, s0
    cal ALLOC_INTERNAL.add_free_list
    mov a0, s0
    cal ALLOC_INTERNAL.coalesce
    @return:
    pop s0
    ret

sbmk "realloc(mem_block: void*, new_size: u32): void*"
## Reallocates a section of memory
## Parameters:
## > a0 - Pointer to allocation
## > a1 - new size in bytes
## Returns:
## < a0 - Pointer to allocation or NULL
## Additional Implementation Notes:
## s0 - saved a0
## s1 - saved a1
## s2 - original block size
realloc:
    vpsh s0..s2
    mov s0, a0
    mov s1, a1
    @if_ptr_is_null:
        cmp eq, s0, 0
        jfs @endif+
        mov a0, s1
        cal malloc
        jmp @return+
    @endif:
    @if_size_is_null:
        cmp eq, s1, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    add s1, 15
    and s1, ~15
    sub s0, ALLOC_HEADER.INFO_SIZE
    cea s0, ALLOC_HEADER._CURR_INFO, 1
    lde u32t, s2, 0
    and s2, ALLOC_HEADER.INFO_MASK_SIZE
    @if_shrinking:
        cmp lte, s1, s2
        jfs @endif+
        mov a0, s0
        mov a1, s1
        cal ALLOC_INTERNAL.split_block
        jmp @return+
    @endif:
    mov a0, s0
    cal ALLOC_INTERNAL.coalesce_next
    @if_coalesced:
        cmp eq, a0, true
        jfs @endif+
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        @if_coalesced_big_enough:
            cmp lte, s1, t0
            jfs @endif_inner+
            mov a0, s0
            mov a1, s1
            cal ALLOC_INTERNAL.split_block
            mov a0, s0
            jmp @return+
        @endif_inner:
    @endif:
    mov a0, s1
    cal malloc
    mov s1, a0
    @if_new_ptr_not_null:
        cmp neq, s1, 0
        jfs @endif+
        mov a1, s0
        mov a2, s2
        syscall SYS_MEM_COPY
    @endif:
    mov a0, s1
    @return:
    vpop s0..s2
    ret

bmk "BOTTOM"

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

# sprintf / snprintf
#
# sprintf(buf, fmt, ...)   a0=buf(abs), a1=fmt(abs), a2..a9=varargs
# snprintf(buf, n, fmt, .) a0=buf(abs), a1=n,        a2=fmt,  a3..a9=varargs
#
# Returns number of characters written (excluding null terminator).

_sprintf_state:
    .buf:     emb u32t 0    # absolute output buffer pointer
    .pos:     emb u32t 0    # current write position
    .limit:   emb u32t 0    # max chars to write (0 = unlimited)
    .int_buf: res u8t 12    # temp for int/hex digit reversal

# Write byte in t0 to buf[pos], respecting limit
_sprintf_putc:
    lod u32t, t1, _sprintf_state.pos
    lod u32t, t2, _sprintf_state.limit
    cmp eq, t2, 0
    jtr @write+
    cmp gte, t1, t2
    jtr @done+
    @write:
    lod u32t, t2, _sprintf_state.buf
    add t2, t1
    mov ea, t2
    ste u8t, 0, t0
    inc t1
    str u32t, _sprintf_state.pos, t1
    @done:
    ret

# Write null-terminated C string from absolute address a0
_sprintf_puts:
    vpsh s0
    mov s0, a0
    @loop:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        cal _sprintf_putc
        inc s0
        jmp @loop-
    @done:
    vpop s0
    ret

# Write signed integer a0
_sprintf_puti:
    vpsh s0..s2
    mov s0, a0
    cmp gte, s0, 0
    jtr @positive+
    mov t0, 45
    cal _sprintf_putc
    neg s0
    @positive:
    cmp neq, s0, 0
    jtr @nonzero+
    mov t0, 48
    cal _sprintf_putc
    jmp @done+
    @nonzero:
    mov s1, _sprintf_state.int_buf + 11
    str u8t, s1, 0
    dec s1
    mov s2, 0
    @digits:
        rem t0, s0, 10
        add t0, 48
        str u8t, s1, t0
        div s0, 10
        dec s1
        inc s2
        cmp neq, s0, 0
        jtr @digits-
    inc s1
    @copy:
        cmp eq, s2, 0
        jtr @done+
        lod u8t, t0, s1
        cal _sprintf_putc
        inc s1
        dec s2
        jmp @copy-
    @done:
    vpop s0..s2
    ret

# Write unsigned integer a0
_sprintf_putu:
    vpsh s0..s2
    mov s0, a0
    cmp neq, s0, 0
    jtr @nonzero+
    mov t0, 48
    cal _sprintf_putc
    jmp @done+
    @nonzero:
    mov s1, _sprintf_state.int_buf + 11
    str u8t, s1, 0
    dec s1
    mov s2, 0
    @digits:
        remu t0, s0, 10
        add t0, 48
        str u8t, s1, t0
        divu s0, 10
        dec s1
        inc s2
        cmp neq, s0, 0
        jtr @digits-
    inc s1
    @copy:
        cmp eq, s2, 0
        jtr @done+
        lod u8t, t0, s1
        cal _sprintf_putc
        inc s1
        dec s2
        jmp @copy-
    @done:
    vpop s0..s2
    ret

# Write unsigned integer a0 as lowercase hex
_sprintf_putx:
    vpsh s0..s2
    mov s0, a0
    cmp neq, s0, 0
    jtr @nonzero+
    mov t0, 48
    cal _sprintf_putc
    jmp @done+
    @nonzero:
    mov s1, _sprintf_state.int_buf + 11
    str u8t, s1, 0
    dec s1
    mov s2, 0
    @digits:
        remu t0, s0, 16
        cmp lt, t0, 10
        jtr @is_dec+
        add t0, 87      # 'a' - 10
        jmp @store+
        @is_dec:
        add t0, 48
        @store:
        str u8t, s1, t0
        divu s0, 16
        dec s1
        inc s2
        cmp neq, s0, 0
        jtr @digits-
    inc s1
    @copy:
        cmp eq, s2, 0
        jtr @done+
        lod u8t, t0, s1
        cal _sprintf_putc
        inc s1
        dec s2
        jmp @copy-
    @done:
    vpop s0..s2
    ret

# Write float a0 (6 decimal places)
_sprintf_putf:
    vpsh s0..s3
    mov s0, a0
    cmp flt, s0, 0.0
    jfs @positive+
    mov t0, 45
    cal _sprintf_putc
    fneg s0
    @positive:
    fcti s1, s0             # s1 = integer part (int)
    mov a0, s1
    cal _sprintf_puti
    mov t0, 46              # '.'
    cal _sprintf_putc
    fctf s2, s1             # s2 = integer part (float)
    fsub s3, s0, s2         # s3 = fractional part
    mov s0, 6
    @frac_loop:
        cmp eq, s0, 0
        jtr @done+
        fmul s3, 10.0
        fcti s2, s3
        add t0, s2, 48
        cal _sprintf_putc
        fctf s1, s2
        fsub s3, s1
        dec s0
        jmp @frac_loop-
    @done:
    vpop s0..s3
    ret

_sprintf_loop:
    @loop:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        cmp eq, t0, 37      # '%'
        jtr @fmt+
        cal _sprintf_putc
        inc s0
        jmp @loop-
    @fmt:
        inc s0
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 100     # 'd'
        jtr @do_d+
        cmp eq, t0, 105     # 'i'
        jtr @do_d+
        cmp eq, t0, 117     # 'u'
        jtr @do_u+
        cmp eq, t0, 115     # 's'
        jtr @do_s+
        cmp eq, t0, 102     # 'f'
        jtr @do_f+
        cmp eq, t0, 99      # 'c'
        jtr @do_c+
        cmp eq, t0, 120     # 'x'
        jtr @do_x+
        cmp eq, t0, 37      # '%'
        jtr @do_pct+
        mov t0, 37
        cal _sprintf_putc
        jmp @adv+
    @do_d:
        mov ea, s1
        lde i32t, a0, 0
        add s1, 4
        cal _sprintf_puti
        jmp @adv+
    @do_u:
        mov ea, s1
        lde u32t, a0, 0
        add s1, 4
        cal _sprintf_putu
        jmp @adv+
    @do_s:
        mov ea, s1
        lde u32t, a0, 0
        add s1, 4
        cal _sprintf_puts
        jmp @adv+
    @do_f:
        mov ea, s1
        lde f32t, a0, 0
        add s1, 4
        cal _sprintf_putf
        jmp @adv+
    @do_c:
        mov ea, s1
        lde u8t, t0, 0
        add s1, 4
        cal _sprintf_putc
        jmp @adv+
    @do_x:
        mov ea, s1
        lde u32t, a0, 0
        add s1, 4
        cal _sprintf_putx
        jmp @adv+
    @do_pct:
        mov t0, 37
        cal _sprintf_putc
    @adv:
        inc s0
        jmp @loop-
    @done:
    ret

sprintf:
    vpsh s0..s1
    sub sp, 32
    mov ea, sp
    ste u32t, 0,  a2
    ste u32t, 4,  a3
    ste u32t, 8,  a4
    ste u32t, 12, a5
    ste u32t, 16, a6
    ste u32t, 20, a7
    ste u32t, 24, a8
    ste u32t, 28, a9

    str u32t, _sprintf_state.buf,   a0
    str u32t, _sprintf_state.pos,   0
    str u32t, _sprintf_state.limit, 0

    mov s0, a1
    mov s1, sp
    cal _sprintf_loop

    # null-terminate
    lod u32t, t0, _sprintf_state.buf
    lod u32t, t1, _sprintf_state.pos
    add t0, t1
    mov ea, t0
    ste u8t, 0, 0

    mov a0, t1
    add sp, 32
    vpop s0..s1
    ret

snprintf:
    vpsh s0..s1
    sub sp, 32
    mov ea, sp
    ste u32t, 0,  a3
    ste u32t, 4,  a4
    ste u32t, 8,  a5
    ste u32t, 12, a6
    ste u32t, 16, a7
    ste u32t, 20, a8
    ste u32t, 24, a9
    ste u32t, 28, a10

    str u32t, _sprintf_state.buf, a0
    str u32t, _sprintf_state.pos, 0

    # limit = n > 0 ? n - 1 : 0  (reserve one byte for null terminator)
    cmp gt, a1, 0
    jfs @zero_lim+
    sub t0, a1, 1
    str u32t, _sprintf_state.limit, t0
    jmp @do_fmt+
    @zero_lim:
    str u32t, _sprintf_state.limit, 0
    @do_fmt:

    mov s0, a2
    mov s1, sp
    cal _sprintf_loop

    # always null-terminate at buf[min(pos, n-1)]
    lod u32t, t0, _sprintf_state.buf
    lod u32t, t1, _sprintf_state.pos
    cmp gt, a1, 0
    jfs @write_null+
    sub t2, a1, 1
    cmp lt, t1, t2
    jtr @write_null+
    mov t1, t2
    @write_null:
    add t0, t1
    mov ea, t0
    ste u8t, 0, 0

    lod u32t, a0, _sprintf_state.pos
    add sp, 32
    vpop s0..s1
    ret

# _get_file_size(name): u32t | cast(-1)
# Returns size in bytes of a named MFS file, or -1 if not found.
# > a0: filename (C absolute pointer, tpr'd here)
_get_file_size:
    tpr a0
    cal MFS_INTERNAL.dirent_find
    cmp eq, a0, 0
    jtr @not_found+
    cea a0, 0, 1
    lde u32t, a0, MFS_DIRENT_FILE_SIZE
    ret
    @not_found:
    mov a0, -1
    ret

# sscanf / scanf
#
# sscanf(str, fmt, ...)  a0=str(abs), a1=fmt(abs), a2..a9=output ptrs(abs)
# scanf(fmt, ...)        a0=fmt(abs), a1..a9=output ptrs(abs)
#
# Returns number of items successfully matched and assigned.
# Supports: %d %i %u %f %s %c %%

_sscanf_input_buf: res u8t 258   # terminal input buffer for scanf

# input: s0=str ptr(abs), s1=fmt ptr(abs), s2=out ptr stack(abs), s3=match count
_sscanf_loop:

    @loop:
        mov ea, s1
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+

        cmp eq, t0, 37  # '%'
        jtr @fmt+

        # whitespace in fmt: skip all whitespace in input
        cmp eq, t0, 32
        jtr @skip_ws+
        cmp eq, t0, 9
        jtr @skip_ws+
        cmp eq, t0, 10
        jtr @skip_ws+

        # literal character match
        mov ea, s0
        lde u8t, t1, 0
        cmp neq, t0, t1
        jtr @done+
        inc s0
        inc s1
        jmp @loop-

        @skip_ws:
        @ws_lp:
            mov ea, s0
            lde u8t, t1, 0
            cmp eq, t1, 32
            jtr @ws_adv+
            cmp eq, t1, 9
            jtr @ws_adv+
            cmp eq, t1, 10
            jtr @ws_adv+
            cmp eq, t1, 13
            jtr @ws_adv+
            jmp @ws_done+
            @ws_adv: inc s0
            jmp @ws_lp-
        @ws_done:
        inc s1
        jmp @loop-

    @fmt:
        inc s1
        mov ea, s1
        lde u8t, t0, 0
        cmp eq, t0, 100
        jtr @scan_d+
        cmp eq, t0, 105
        jtr @scan_d+
        cmp eq, t0, 117
        jtr @scan_u+
        cmp eq, t0, 115
        jtr @scan_s+
        cmp eq, t0, 102
        jtr @scan_f+
        cmp eq, t0, 99
        jtr @scan_c+
        cmp eq, t0, 37
        jtr @scan_pct+
        jmp @adv+

    @scan_d:
        # skip input whitespace
        @wd:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @wd_adv+
            cmp eq, t0, 9
            jtr @wd_adv+
            cmp eq, t0, 10
            jtr @wd_adv+
            cmp eq, t0, 13
            jtr @wd_adv+
            jmp @wd_done+
            @wd_adv: inc s0
            jmp @wd-
        @wd_done:
        # parse sign
        mov t1, 0
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 45
        jfs @no_neg_d+
        mov t1, 1
        inc s0
        jmp @after_sign_d+
        @no_neg_d:
        cmp eq, t0, 43
        jfs @after_sign_d+
        inc s0
        @after_sign_d:
        # check at least one digit present
        mov ea, s0
        lde u8t, t0, 0
        cmp lt, t0, 48
        jtr @adv+
        cmp gt, t0, 57
        jtr @adv+
        # accumulate digits
        vpsh s4
        mov s4, 0
        @dig_d:
            mov ea, s0
            lde u8t, t0, 0
            cmp lt, t0, 48
            jtr @dig_d_done+
            cmp gt, t0, 57
            jtr @dig_d_done+
            sub t0, 48
            mul s4, 10
            add s4, t0
            inc s0
            jmp @dig_d-
        @dig_d_done:
        cmp eq, t1, 0
        jtr @d_pos+
        neg s4
        @d_pos:
        # store at out ptr
        mov ea, s2
        lde u32t, t0, 0
        add s2, 4
        mov ea, t0
        ste i32t, 0, s4
        vpop s4
        inc s3
        jmp @adv+

    @scan_u:
        @wu:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @wu_adv+
            cmp eq, t0, 9
            jtr @wu_adv+
            cmp eq, t0, 10
            jtr @wu_adv+
            cmp eq, t0, 13
            jtr @wu_adv+
            jmp @wu_done+
            @wu_adv: inc s0
            jmp @wu-
        @wu_done:
        mov ea, s0
        lde u8t, t0, 0
        cmp ltu, t0, 48
        jtr @adv+
        cmp gt, t0, 57
        jtr @adv+
        vpsh s4
        mov s4, 0
        @dig_u:
            mov ea, s0
            lde u8t, t0, 0
            cmp ltu, t0, 48
            jtr @dig_u_done+
            cmp gt, t0, 57
            jtr @dig_u_done+
            sub t0, 48
            mul s4, 10
            add s4, t0
            inc s0
            jmp @dig_u-
        @dig_u_done:
        mov ea, s2
        lde u32t, t0, 0
        add s2, 4
        mov ea, t0
        ste u32t, 0, s4
        vpop s4
        inc s3
        jmp @adv+

    @scan_s:
        @ws2:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @ws2_adv+
            cmp eq, t0, 9
            jtr @ws2_adv+
            cmp eq, t0, 10
            jtr @ws2_adv+
            cmp eq, t0, 13
            jtr @ws2_adv+
            jmp @ws2_done+
            @ws2_adv: inc s0
            jmp @ws2-
        @ws2_done:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        # get output ptr (absolute)
        mov ea, s2
        lde u32t, t1, 0
        add s2, 4
        # copy non-whitespace chars
        @str_cp:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 0
            jtr @str_done+
            cmp eq, t0, 32
            jtr @str_done+
            cmp eq, t0, 9
            jtr @str_done+
            cmp eq, t0, 10
            jtr @str_done+
            cmp eq, t0, 13
            jtr @str_done+
            mov ea, t1
            ste u8t, 0, t0
            inc s0
            inc t1
            jmp @str_cp-
        @str_done:
        mov ea, t1
        ste u8t, 0, 0
        inc s3
        jmp @adv+

    @scan_f:
        @wf:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @wf_adv+
            cmp eq, t0, 9
            jtr @wf_adv+
            cmp eq, t0, 10
            jtr @wf_adv+
            cmp eq, t0, 13
            jtr @wf_adv+
            jmp @wf_done+
            @wf_adv: inc s0
            jmp @wf-
        @wf_done:
        vpsh s4..s6
        mov s4, 0       # negative flag
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 45
        jfs @fno_neg+
        mov s4, 1
        inc s0
        jmp @fafter_sign+
        @fno_neg:
        cmp eq, t0, 43
        jfs @fafter_sign+
        inc s0
        @fafter_sign:
        # integer part
        fctf s5, zr     # s5 = result float (starts at 0.0)
        @fdig_int:
            mov ea, s0
            lde u8t, t0, 0
            cmp lt, t0, 48
            jtr @fdig_int_done+
            cmp gt, t0, 57
            jtr @fdig_int_done+
            sub t0, 48
            fmul s5, 10.0
            fctf s6, t0
            fadd s5, s6
            inc s0
            jmp @fdig_int-
        @fdig_int_done:
        # fractional part
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 46  # '.'
        jfs @fno_frac+
        inc s0
        fctf s6, zr     # s6 = frac multiplier seed
        fadd s6, 0.1    # s6 = 0.1
        @fdig_frac:
            mov ea, s0
            lde u8t, t0, 0
            cmp lt, t0, 48
            jtr @fdig_frac_done+
            cmp gt, t0, 57
            jtr @fdig_frac_done+
            sub t0, 48
            fctf t0, t0
            fmul t0, s6
            fadd s5, t0
            fmul s6, 0.1
            inc s0
            jmp @fdig_frac-
        @fdig_frac_done:
        @fno_frac:
        cmp eq, s4, 0
        jtr @fpos+
        fneg s5
        @fpos:
        mov ea, s2
        lde u32t, t0, 0
        add s2, 4
        mov ea, t0
        ste f32t, 0, s5
        vpop s4..s6
        inc s3
        jmp @adv+

    @scan_c:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        mov ea, s2
        lde u32t, t1, 0
        add s2, 4
        mov ea, t1
        ste u8t, 0, t0
        inc s0
        inc s3
        jmp @adv+

    @scan_pct:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 37
        jfs @done+
        inc s0

    @adv:
        inc s1
        jmp @loop-

    @done:
    ret

sscanf:
    vpsh s0..s3
    sub sp, 32
    mov ea, sp
    ste u32t, 0,  a2
    ste u32t, 4,  a3
    ste u32t, 8,  a4
    ste u32t, 12, a5
    ste u32t, 16, a6
    ste u32t, 20, a7
    ste u32t, 24, a8
    ste u32t, 28, a9

    mov s0, a0
    mov s1, a1
    mov s2, sp
    mov s3, 0
    cal _sscanf_loop
    mov a0, s3

    add sp, 32
    vpop s0..s3
    ret

scanf:
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

    mov s0, a0          # save fmt

    syscall SYS_GET_TERMINAL_INPUT_SIZE
    cmp eq, a0, 0
    jtr @empty+

    psh a0              # save input size
    mov a0, _sscanf_input_buf
    pop a1
    syscall SYS_READ_TERMINAL_INPUT

    # s0=input(abs), s1=fmt(abs), s2=out ptrs(abs), s3=count
    tpa s1, _sscanf_input_buf   # absolute ptr to filled buffer
    swp s0, s1                  # s0=input, s1=fmt
    mov s2, sp
    mov s3, 0
    cal _sscanf_loop
    mov a0, s3
    jmp @done+

    @empty:
    mov a0, 0

    @done:
    add sp, 32
    vpop s0..s3
    ret
