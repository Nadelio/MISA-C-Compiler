bmk "TOP"
_start:
	cal main_
	exit

sbmk "line_start_(position: i16t): i16t"
##
## Parameters:
## > a0 - position, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
line_start_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
__L0:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 0
	cmp gt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L2
	tpa t3, g__text
	mov ea, fp
	lde i16t, t5, -4
	mov t6, 1
	sub t4, t5, t6
	add t3, t4
	mov ea, t3
	lde i8t, t2, 0
	mov t3, 10
	cmp neq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L2:
	cmp neq, t0, zr
	jfs __L1
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	dec t1
	mov ea, fp
	ste i16t, -4, t1
	jmp __L0
__L1:
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	add sp, 4
	ret

sbmk "next_line_(position: i16t): i16t"
##
## Parameters:
## > a0 - position, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
next_line_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
__L3:
	mov ea, fp
	lde i16t, t2, -4
	lod i16t, t3, g__text_length
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L5
	tpa t3, g__text
	mov ea, fp
	lde i16t, t4, -4
	add t3, t4
	mov ea, t3
	lde i8t, t2, 0
	mov t3, 10
	cmp neq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L5:
	cmp neq, t0, zr
	jfs __L4
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	jmp __L3
__L4:
	mov ea, fp
	lde i16t, t1, -4
	lod i16t, t2, g__text_length
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L6
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
__L6:
__L7:
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	add sp, 4
	ret

sbmk "previous_line_(position: i16t): i16t"
##
## Parameters:
## > a0 - position, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
previous_line_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
	psh t0
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	cal line_start_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L8
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret
__L8:
__L9:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 1
	sub t1, t2, t3
	mov a0, t1
	cal line_start_
	mov t0, a0
	mov a0, t0
	add sp, 4
	ret

sbmk "position_on_line_(start: i16t, column: i16t): i16t"
##
## Parameters:
## > a0 - start, is i16t
## > a1 - column, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
position_on_line_:
	sub sp, 12
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste i16t, -8, a1
	mov ea, fp
	lde i16t, t0, -4
	mov ea, fp
	ste i16t, -12, t0
__L10:
	mov ea, fp
	lde i16t, t3, -12
	lod i16t, t4, g__text_length
	cmp lt, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jfs __L13
	tpa t4, g__text
	mov ea, fp
	lde i16t, t5, -12
	add t4, t5
	mov ea, t4
	lde i8t, t3, 0
	mov t4, 10
	cmp neq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L13:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L12
	mov ea, fp
	lde i16t, t2, -8
	mov t3, 0
	cmp gt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L12:
	cmp neq, t0, zr
	jfs __L11
	mov ea, fp
	lde i16t, t1, -12
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -12, t1
	mov ea, fp
	lde i16t, t1, -8
	mov t0, t1
	dec t1
	mov ea, fp
	ste i16t, -8, t1
	jmp __L10
__L11:
	mov ea, fp
	lde i16t, t0, -12
	mov a0, t0
	add sp, 12
	ret

sbmk "keep_cursor_visible_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
keep_cursor_visible_:
	sub sp, 8
	lod i16t, t1, g__cursor
	lod i16t, t2, g__top_line
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L14
	psh t0
	lod i16t, t0, g__cursor
	mov a0, t0
	cal line_start_
	mov t1, a0
	pop t0
	str i16t, g__top_line, t1
	mov t0, t1
__L14:
__L15:
	mov t1, 0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	lod i16t, t1, g__top_line
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
__L16:
	mov ea, fp
	lde i16t, t2, -8
	lod i16t, t3, g__cursor
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L18
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 24
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L18:
	cmp neq, t0, zr
	jfs __L17
	tpa t2, g__text
	mov ea, fp
	lde i16t, t3, -8
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 10
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L19
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
__L19:
__L20:
	mov ea, fp
	lde i16t, t1, -8
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -8, t1
	jmp __L16
__L17:
__L21:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 24
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L22
	psh t0
	lod i16t, t0, g__top_line
	mov a0, t0
	cal next_line_
	mov t1, a0
	pop t0
	str i16t, g__top_line, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	dec t1
	mov ea, fp
	ste i16t, -4, t1
	jmp __L21
__L22:
	add sp, 8
	ret

sbmk "insert_character_(character: i16t): void"
##
## Parameters:
## > a0 - character, is i16t
## Returns: NONE
## Additional Implementation Notes:
insert_character_:
	sub sp, 8
	mov ea, fp
	ste i16t, -4, a0
	lod i16t, t1, g__text_length
	mov t3, 2048
	mov t4, 1
	sub t2, t3, t4
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L23
	add sp, 8
	ret
__L23:
__L24:
	lod i16t, t1, g__text_length
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
__L25:
	mov ea, fp
	lde i16t, t1, -8
	lod i16t, t2, g__cursor
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L26
	tpa t2, g__text
	mov ea, fp
	lde i16t, t4, -8
	mov t5, 1
	sub t3, t4, t5
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	tpa t2, g__text
	mov ea, fp
	lde i16t, t3, -8
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -8
	mov t0, t1
	dec t1
	mov ea, fp
	ste i16t, -8, t1
	jmp __L25
__L26:
	mov ea, fp
	lde i16t, t1, -4
	tpa t2, g__text
	lod i16t, t3, g__cursor
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	lod i16t, t1, g__text_length
	mov t0, t1
	inc t1
	str i16t, g__text_length, t1
	lod i16t, t1, g__cursor
	mov t0, t1
	inc t1
	str i16t, g__cursor, t1
	mov t1, 0
	tpa t2, g__text
	lod i16t, t3, g__text_length
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__save_failed, t1
	mov t0, t1
	cal keep_cursor_visible_
	mov t0, a0
	add sp, 8
	ret

sbmk "erase_before_cursor_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
erase_before_cursor_:
	sub sp, 4
	lod i16t, t1, g__cursor
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L27
	add sp, 4
	ret
__L27:
__L28:
	lod i16t, t2, g__cursor
	mov t3, 1
	sub t1, t2, t3
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
__L29:
	mov ea, fp
	lde i16t, t1, -4
	lod i16t, t2, g__text_length
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L30
	tpa t2, g__text
	mov ea, fp
	lde i16t, t4, -4
	mov t5, 1
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	tpa t2, g__text
	mov ea, fp
	lde i16t, t3, -4
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	jmp __L29
__L30:
	lod i16t, t1, g__cursor
	mov t0, t1
	dec t1
	str i16t, g__cursor, t1
	lod i16t, t1, g__text_length
	mov t0, t1
	dec t1
	str i16t, g__text_length, t1
	mov t1, 0
	str i16t, g__save_failed, t1
	mov t0, t1
	cal keep_cursor_visible_
	mov t0, a0
	add sp, 4
	ret

sbmk "erase_at_cursor_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
erase_at_cursor_:
	sub sp, 4
	lod i16t, t1, g__cursor
	lod i16t, t2, g__text_length
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L31
	add sp, 4
	ret
__L31:
__L32:
	lod i16t, t1, g__cursor
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
__L33:
	mov ea, fp
	lde i16t, t1, -4
	lod i16t, t2, g__text_length
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L34
	tpa t2, g__text
	mov ea, fp
	lde i16t, t4, -4
	mov t5, 1
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	tpa t2, g__text
	mov ea, fp
	lde i16t, t3, -4
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	jmp __L33
__L34:
	lod i16t, t1, g__text_length
	mov t0, t1
	dec t1
	str i16t, g__text_length, t1
	mov t1, 0
	str i16t, g__save_failed, t1
	mov t0, t1
	add sp, 4
	ret

sbmk "shifted_character_(character: i16t): i16t"
##
## Parameters:
## > a0 - character, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
shifted_character_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 97
	cmp gte, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L37
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 122
	cmp lte, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L37:
	cmp eq, t0, zr
	jtr __L35
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 32
	sub t0, t1, t2
	mov a0, t0
	add sp, 4
	ret
__L35:
__L36:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 49
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L38
	mov t0, 33
	mov a0, t0
	add sp, 4
	ret
__L38:
__L39:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 50
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L40
	mov t0, 64
	mov a0, t0
	add sp, 4
	ret
__L40:
__L41:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 51
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L42
	mov t0, 35
	mov a0, t0
	add sp, 4
	ret
__L42:
__L43:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 52
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L44
	mov t0, 36
	mov a0, t0
	add sp, 4
	ret
__L44:
__L45:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 53
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L46
	mov t0, 37
	mov a0, t0
	add sp, 4
	ret
__L46:
__L47:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 54
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L48
	mov t0, 94
	mov a0, t0
	add sp, 4
	ret
__L48:
__L49:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 55
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L50
	mov t0, 38
	mov a0, t0
	add sp, 4
	ret
__L50:
__L51:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 56
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L52
	mov t0, 42
	mov a0, t0
	add sp, 4
	ret
__L52:
__L53:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 57
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L54
	mov t0, 40
	mov a0, t0
	add sp, 4
	ret
__L54:
__L55:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 48
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L56
	mov t0, 41
	mov a0, t0
	add sp, 4
	ret
__L56:
__L57:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 45
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L58
	mov t0, 95
	mov a0, t0
	add sp, 4
	ret
__L58:
__L59:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 61
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L60
	mov t0, 43
	mov a0, t0
	add sp, 4
	ret
__L60:
__L61:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 91
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L62
	mov t0, 123
	mov a0, t0
	add sp, 4
	ret
__L62:
__L63:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 93
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L64
	mov t0, 125
	mov a0, t0
	add sp, 4
	ret
__L64:
__L65:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 92
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L66
	mov t0, 124
	mov a0, t0
	add sp, 4
	ret
__L66:
__L67:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 59
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L68
	mov t0, 58
	mov a0, t0
	add sp, 4
	ret
__L68:
__L69:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 39
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L70
	mov t0, 34
	mov a0, t0
	add sp, 4
	ret
__L70:
__L71:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 44
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L72
	mov t0, 60
	mov a0, t0
	add sp, 4
	ret
__L72:
__L73:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 46
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L74
	mov t0, 62
	mov a0, t0
	add sp, 4
	ret
__L74:
__L75:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 47
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L76
	mov t0, 63
	mov a0, t0
	add sp, 4
	ret
__L76:
__L77:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 96
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L78
	mov t0, 126
	mov a0, t0
	add sp, 4
	ret
__L78:
__L79:
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	add sp, 4
	ret

sbmk "make_filename_(number: i16t): void"
##
## Parameters:
## > a0 - number, is i16t
## Returns: NONE
## Additional Implementation Notes:
make_filename_:
	sub sp, 24
	mov ea, fp
	ste i16t, -4, a0
	mov t0, 0
	mov ea, fp
	ste i16t, -20, t0
	mov t0, 0
	mov ea, fp
	ste i16t, -24, t0
__L80:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L81
	mov t2, 48
	mov ea, fp
	lde i16t, t4, -4
	mov t5, 10
	rem t3, t4, t5
	add t1, t2, t3
	add t2, fp, -16
	mov ea, fp
	lde i16t, t3, -20
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -20
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -20, t1
	mov t1, 10
	mov ea, fp
	lde i16t, t2, -4
	div t3, t2, t1
	mov ea, fp
	ste i16t, -4, t3
	mov t0, t3
	jmp __L80
__L81:
__L82:
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L83
	mov ea, fp
	lde i16t, t1, -20
	mov t0, t1
	dec t1
	mov ea, fp
	ste i16t, -20, t1
	add t2, fp, -16
	mov ea, fp
	lde i16t, t3, -20
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	tpa t2, g__filename
	mov ea, fp
	lde i16t, t3, -24
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -24
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -24, t1
	jmp __L82
__L83:
	mov t1, 46
	tpa t2, g__filename
	mov ea, fp
	lde i16t, t3, -24
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 116
	tpa t2, g__filename
	mov ea, fp
	lde i16t, t4, -24
	mov t5, 1
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 120
	tpa t2, g__filename
	mov ea, fp
	lde i16t, t4, -24
	mov t5, 2
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 116
	tpa t2, g__filename
	mov ea, fp
	lde i16t, t4, -24
	mov t5, 3
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 0
	tpa t2, g__filename
	mov ea, fp
	lde i16t, t4, -24
	mov t5, 4
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	add sp, 24
	ret

sbmk "save_document_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
save_document_:
	sub sp, 8
	lod i16t, t1, g__filesystem_ready
	cmp eq, t1, zr
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L84
	mov t1, 1
	str i16t, g__save_failed, t1
	mov t0, t1
	add sp, 8
	ret
__L84:
__L85:
	tpa t2, g__filename
	mov t3, 0
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L86
	psh t0
	psh t1
	cal MFS.count
	mov t2, a0
	pop t1
	pop t0
	mov t3, 1
	add t1, t2, t3
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	cal make_filename_
	mov t0, a0
__L88:
	psh t0
	tpa t0, g__filename
	mov a0, t0
	cal MFS.open
	mov t1, a0
	pop t0
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L89
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	cal make_filename_
	mov t0, a0
	jmp __L88
__L89:
	psh t0
	tpa t0, g__filename
	mov a0, t0
	cal MFS.create
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -8
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L90
	mov t1, 0
	tpa t2, g__filename
	mov t3, 0
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 1
	str i16t, g__save_failed, t1
	mov t0, t1
	add sp, 8
	ret
__L90:
__L91:
__L86:
__L87:
	psh t0
	tpa t0, g__filename
	tpa t2, g__text
	lod i16t, t3, g__text_length
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal MFS.write
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t2, -8
	mov t3, 0
	cmp neq, t2, t3
	sel t1, 1, 0
	str i16t, g__save_failed, t1
	mov t0, t1
	add sp, 8
	ret

sbmk "open_file_picker_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
open_file_picker_:
	psh t0
	cal MFS.count
	mov t1, a0
	pop t0
	str i16t, g__file_count, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__selected_file, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__first_file, t1
	mov t0, t1
	mov t1, 1
	str i16t, g__file_picker, t1
	mov t0, t1
	ret

sbmk "keep_file_selected_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
keep_file_selected_:
	lod i16t, t1, g__selected_file
	lod i16t, t2, g__first_file
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L92
	lod i16t, t1, g__selected_file
	str i16t, g__first_file, t1
	mov t0, t1
__L92:
__L93:
	lod i16t, t1, g__selected_file
	lod i16t, t3, g__first_file
	mov t4, 20
	add t2, t3, t4
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L94
	lod i16t, t3, g__selected_file
	mov t4, 20
	sub t2, t3, t4
	mov t3, 1
	add t1, t2, t3
	str i16t, g__first_file, t1
	mov t0, t1
__L94:
__L95:
	ret

sbmk "open_selected_file_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
open_selected_file_:
	sub sp, 4
	lod i16t, t2, g__selected_file
	mov t3, 0
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L98
	lod i16t, t2, g__selected_file
	lod i16t, t3, g__file_count
	cmp gte, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L98:
	cmp eq, t0, zr
	jtr __L96
	add sp, 4
	ret
__L96:
__L97:
	psh t0
	lod i16t, t0, g__selected_file
	tpa t2, g__filename
	mov t3, 64
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal MFS.get_name
	mov t1, a0
	pop t0
	mov t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L99
	mov t1, 1
	str i16t, g__save_failed, t1
	mov t0, t1
	add sp, 4
	ret
__L99:
__L100:
	psh t0
	tpa t0, g__filename
	tpa t2, g__text
	mov t4, 2048
	mov t5, 1
	sub t3, t4, t5
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
	mov t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L101
	mov t1, 0
	tpa t2, g__filename
	mov t3, 0
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 1
	str i16t, g__save_failed, t1
	mov t0, t1
	add sp, 4
	ret
__L101:
__L102:
	mov ea, fp
	lde i16t, t1, -4
	str i16t, g__text_length, t1
	mov t0, t1
	mov t1, 0
	tpa t2, g__text
	lod i16t, t3, g__text_length
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__cursor, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__top_line, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__save_failed, t1
	mov t0, t1
	mov t1, 0
	str i16t, g__file_picker, t1
	mov t0, t1
	add sp, 4
	ret

sbmk "move_cursor_up_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
move_cursor_up_:
	sub sp, 8
	lod i16t, t1, g__cursor
	mov a0, t1
	cal line_start_
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	lod i16t, t1, g__cursor
	mov ea, fp
	lde i16t, t2, -4
	sub t0, t1, t2
	mov ea, fp
	ste i16t, -8, t0
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L103
	psh t0
	psh t1
	lod i16t, t1, g__cursor
	mov a0, t1
	cal previous_line_
	mov t0, a0
	pop t1
	mov ea, fp
	lde i16t, t2, -8
	mov a1, t2
	mov a0, t0
	cal position_on_line_
	mov t1, a0
	pop t0
	str i16t, g__cursor, t1
	mov t0, t1
__L103:
__L104:
	cal keep_cursor_visible_
	mov t0, a0
	add sp, 8
	ret

sbmk "move_cursor_down_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
move_cursor_down_:
	sub sp, 12
	lod i16t, t1, g__cursor
	mov a0, t1
	cal line_start_
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	lod i16t, t1, g__cursor
	mov ea, fp
	lde i16t, t2, -4
	sub t0, t1, t2
	mov ea, fp
	ste i16t, -8, t0
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	cal next_line_
	mov t0, a0
	mov ea, fp
	ste i16t, -12, t0
	mov ea, fp
	lde i16t, t2, -12
	lod i16t, t3, g__text_length
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L107
	mov ea, fp
	lde i16t, t4, -12
	lod i16t, t5, g__text_length
	cmp eq, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L109
	lod i16t, t4, g__text_length
	mov t5, 0
	cmp gt, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L109:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L108
	tpa t4, g__text
	lod i16t, t6, g__text_length
	mov t7, 1
	sub t5, t6, t7
	add t4, t5
	mov ea, t4
	lde i8t, t3, 0
	mov t4, 10
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L108:
	cmp neq, t1, zr
	sel t0, 1, 0
__L107:
	cmp eq, t0, zr
	jtr __L105
	psh t0
	mov ea, fp
	lde i16t, t0, -12
	mov ea, fp
	lde i16t, t2, -8
	mov a1, t2
	mov a0, t0
	cal position_on_line_
	mov t1, a0
	pop t0
	str i16t, g__cursor, t1
	mov t0, t1
__L105:
__L106:
	cal keep_cursor_visible_
	mov t0, a0
	add sp, 12
	ret

sbmk "draw_character_(character: i16t, x: i16t, y: i16t, luma: i16t): void"
##
## Parameters:
## > a0 - character, is i16t
## > a1 - x, is i16t
## > a2 - y, is i16t
## > a3 - luma, is i16t
## Returns: NONE
## Additional Implementation Notes:
draw_character_:
	sub sp, 32
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste i16t, -8, a1
	mov ea, fp
	ste i16t, -12, a2
	mov ea, fp
	ste i16t, -16, a3
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 32
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L112
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 127
	cmp gt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L112:
	cmp eq, t0, zr
	jtr __L110
	mov t1, 63
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
__L110:
__L111:
	mov ea, fp
	lde i16t, t3, -4
	mov t4, 32
	sub t2, t3, t4
	mov t3, 5
	mul t1, t2, t3
	mov ea, fp
	ste i16t, -32, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
__L113:
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 5
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L115
	tpa t2, g__font
	mov ea, fp
	lde i16t, t4, -32
	mov ea, fp
	lde i16t, t5, -20
	add t3, t4, t5
	add t2, t3
	mov ea, t2
	lde u8t, t1, 0
	mov ea, fp
	ste i16t, -28, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	ste i16t, -24, t1
	mov t0, t1
__L116:
	mov ea, fp
	lde i16t, t1, -24
	mov t2, 7
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L118
	mov ea, fp
	lde i16t, t1, -28
	mov t3, 1
	mov ea, fp
	lde i16t, t4, -24
	sll t2, t3, t4
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L119
	mov ea, fp
	lde i16t, t2, -8
	mov ea, fp
	lde i16t, t3, -20
	add t1, t2, t3
	mov ea, fp
	lde i16t, t3, -12
	mov ea, fp
	lde i16t, t4, -24
	add t2, t3, t4
	mov t3, 1
	mov t4, 1
	mov ea, fp
	lde i16t, t5, -16
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
__L119:
__L120:
__L117:
	mov ea, fp
	lde i16t, t1, -24
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -24, t1
	jmp __L116
__L118:
	yield
	mov t0, a0
__L114:
	mov ea, fp
	lde i16t, t1, -20
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -20, t1
	jmp __L113
__L115:
	add sp, 32
	ret

sbmk "draw_string_(value: i8t*, x: i16t, y: i16t, luma: i16t): void"
##
## Parameters:
## > a0 - value, is i8t*
## > a1 - x, is i16t
## > a2 - y, is i16t
## > a3 - luma, is i16t
## Returns: NONE
## Additional Implementation Notes:
draw_string_:
	sub sp, 20
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste i16t, -8, a1
	mov ea, fp
	ste i16t, -12, a2
	mov ea, fp
	ste i16t, -16, a3
	mov t0, 0
	mov ea, fp
	ste i16t, -20, t0
__L121:
	mov ea, fp
	lde u32t, t2, -4
	mov ea, fp
	lde i16t, t3, -20
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L122
	mov ea, fp
	lde u32t, t2, -4
	mov ea, fp
	lde i16t, t3, -20
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov ea, fp
	lde i16t, t2, -8
	mov ea, fp
	lde i16t, t3, -12
	mov ea, fp
	lde i16t, t4, -16
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_character_
	mov t0, a0
	mov t1, 6
	mov ea, fp
	lde i16t, t2, -8
	add t3, t2, t1
	mov ea, fp
	ste i16t, -8, t3
	mov t0, t3
	mov ea, fp
	lde i16t, t1, -20
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -20, t1
	jmp __L121
__L122:
	add sp, 20
	ret

sbmk "draw_file_picker_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
draw_file_picker_:
	sub sp, 8
	mov t0, 0
	mov ea, fp
	ste i16t, -4, t0
	lod i16t, t0, g__first_file
	mov ea, fp
	ste i16t, -8, t0
	mov t1, 0
	mov t2, 0
	mov t3, 320
	mov t4, 240
	mov t5, 18
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 0
	mov t2, 0
	mov t3, 320
	mov t4, 15
	mov t5, 42
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	tpa t1, __str_123
	mov t2, 6
	mov t3, 4
	mov t4, 230
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_string_
	mov t0, a0
	lod i16t, t1, g__file_count
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L124
	tpa t1, __str_126
	mov t2, 7
	mov t3, 20
	mov t4, 145
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_string_
	mov t0, a0
	add sp, 8
	ret
__L124:
__L125:
__L127:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 20
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L129
	mov ea, fp
	lde i16t, t2, -8
	lod i16t, t3, g__file_count
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L129:
	cmp neq, t0, zr
	jfs __L128
	mov ea, fp
	lde i16t, t1, -8
	lod i16t, t2, g__selected_file
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L130
	mov t1, 3
	mov t4, 20
	mov ea, fp
	lde i16t, t6, -4
	mov t7, 9
	mul t5, t6, t7
	add t3, t4, t5
	mov t4, 1
	sub t2, t3, t4
	mov t4, 320
	mov t5, 6
	sub t3, t4, t5
	mov t4, 9
	mov t5, 42
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
__L130:
__L131:
	psh t0
	mov ea, fp
	lde i16t, t0, -8
	tpa t2, g__listed_filename
	mov t3, 64
	mov a2, t3
	mov a1, t2
	mov a0, t0
	cal MFS.get_name
	mov t1, a0
	pop t0
	mov t2, 0
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L132
	tpa t1, g__listed_filename
	mov t2, 7
	mov t4, 20
	mov ea, fp
	lde i16t, t6, -4
	mov t7, 9
	mul t5, t6, t7
	add t3, t4, t5
	mov ea, fp
	lde i16t, t6, -8
	lod i16t, t7, g__selected_file
	cmp eq, t6, t7
	sel t5, 1, 0
	cmp neq, t5, zr
	jfs __L134
	mov t5, 255
	mov t4, t5
	jmp __L135
__L134:
	mov t5, 230
	mov t4, t5
__L135:
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_string_
	mov t0, a0
__L132:
__L133:
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	mov ea, fp
	lde i16t, t1, -8
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -8, t1
	jmp __L127
__L128:
	add sp, 8
	ret

sbmk "_draw(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_draw:
	sub sp, 16
	lod i16t, t0, g__top_line
	mov ea, fp
	ste i16t, -4, t0
	mov t0, 0
	mov ea, fp
	ste i16t, -8, t0
	mov t0, 0
	mov ea, fp
	ste i16t, -12, t0
	mov t0, 0
	mov ea, fp
	ste i16t, -16, t0
	lod i16t, t0, g__file_picker
	cmp eq, t0, zr
	jtr __L136
	cal draw_file_picker_
	mov t0, a0
	exit
	mov t0, a0
	add sp, 16
	ret
__L136:
__L137:
	mov t1, 0
	mov t2, 0
	mov t3, 320
	mov t4, 240
	mov t5, 18
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 0
	mov t2, 0
	mov t3, 320
	mov t4, 15
	mov t5, 42
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	lod i16t, t0, g__save_failed
	cmp eq, t0, zr
	jtr __L138
	tpa t1, __str_140
	mov t2, 6
	mov t3, 4
	mov t4, 230
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_string_
	mov t0, a0
	jmp __L139
__L138:
	tpa t2, g__filename
	mov t3, 0
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L141
	tpa t1, g__filename
	mov t2, 6
	mov t3, 4
	mov t4, 230
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_string_
	mov t0, a0
	jmp __L142
__L141:
	tpa t1, __str_143
	mov t2, 6
	mov t3, 4
	mov t4, 145
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_string_
	mov t0, a0
__L142:
__L139:
__L144:
	mov ea, fp
	lde i16t, t2, -8
	mov t3, 24
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L146
	mov ea, fp
	lde i16t, t2, -4
	lod i16t, t3, g__text_length
	cmp lte, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L146:
	cmp neq, t0, zr
	jfs __L145
	mov ea, fp
	lde i16t, t1, -4
	lod i16t, t2, g__cursor
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L147
	mov t2, 7
	mov ea, fp
	lde i16t, t4, -12
	mov t5, 6
	mul t3, t4, t5
	add t1, t2, t3
	mov t3, 20
	mov ea, fp
	lde i16t, t5, -8
	mov t6, 9
	mul t4, t5, t6
	add t2, t3, t4
	mov t3, 1
	mov t4, 7
	mov t5, 255
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 1
	mov ea, fp
	ste i16t, -16, t1
	mov t0, t1
__L147:
__L148:
	mov ea, fp
	lde i16t, t1, -4
	lod i16t, t2, g__text_length
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L149
	jmp __L145
__L149:
__L150:
	tpa t2, g__text
	mov ea, fp
	lde i16t, t3, -4
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t2, 10
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L151
	mov ea, fp
	lde i16t, t1, -8
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -8, t1
	mov t1, 0
	mov ea, fp
	ste i16t, -12, t1
	mov t0, t1
	jmp __L152
__L151:
	mov ea, fp
	lde i16t, t1, -12
	mov t2, 51
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L153
	tpa t2, g__text
	mov ea, fp
	lde i16t, t3, -4
	add t2, t3
	mov ea, t2
	lde i8t, t1, 0
	mov t3, 7
	mov ea, fp
	lde i16t, t5, -12
	mov t6, 6
	mul t4, t5, t6
	add t2, t3, t4
	mov t4, 20
	mov ea, fp
	lde i16t, t6, -8
	mov t7, 9
	mul t5, t6, t7
	add t3, t4, t5
	mov t4, 230
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_character_
	mov t0, a0
__L153:
__L154:
	mov ea, fp
	lde i16t, t1, -12
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -12, t1
__L152:
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	jmp __L144
__L145:
	mov ea, fp
	lde i16t, t3, -16
	cmp eq, t3, zr
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jfs __L158
	lod i16t, t3, g__cursor
	lod i16t, t4, g__text_length
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L158:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L157
	mov ea, fp
	lde i16t, t2, -8
	mov t3, 24
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L157:
	cmp eq, t0, zr
	jtr __L155
	mov t2, 7
	mov ea, fp
	lde i16t, t4, -12
	mov t5, 6
	mul t3, t4, t5
	add t1, t2, t3
	mov t3, 20
	mov ea, fp
	lde i16t, t5, -8
	mov t6, 9
	mul t4, t5, t6
	add t2, t3, t4
	mov t3, 1
	mov t4, 7
	mov t5, 255
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
__L155:
__L156:
	exit
	mov t0, a0
	add sp, 16
	ret

sbmk "_keyboard_input(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_keyboard_input:
	sub sp, 12
	syscall SYS_GET_KEYBOARD_INPUT
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	mov t0, a1
	mov ea, fp
	ste i16t, -8, t0
	mov ea, fp
	lde i16t, t3, -8
	mov t4, 1
	and t2, t3, t4
	cmp eq, t2, zr
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L161
	mov ea, fp
	lde i16t, t3, -8
	mov t4, 2
	and t2, t3, t4
	cmp eq, t2, zr
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L161:
	cmp eq, t0, zr
	jtr __L159
	exit
	mov t0, a0
	add sp, 12
	ret
__L159:
__L160:
	lod i16t, t0, g__file_picker
	cmp eq, t0, zr
	jtr __L162
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 131
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L164
	mov t1, 0
	str i16t, g__file_picker, t1
	mov t0, t1
	jmp __L165
__L164:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 137
	cmp eq, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L168
	lod i16t, t2, g__selected_file
	mov t3, 0
	cmp gt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L168:
	cmp eq, t0, zr
	jtr __L166
	lod i16t, t1, g__selected_file
	mov t0, t1
	dec t1
	str i16t, g__selected_file, t1
	cal keep_file_selected_
	mov t0, a0
	jmp __L167
__L166:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 138
	cmp eq, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L171
	lod i16t, t3, g__selected_file
	mov t4, 1
	add t2, t3, t4
	lod i16t, t3, g__file_count
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L171:
	cmp eq, t0, zr
	jtr __L169
	lod i16t, t1, g__selected_file
	mov t0, t1
	inc t1
	str i16t, g__selected_file, t1
	cal keep_file_selected_
	mov t0, a0
	jmp __L170
__L169:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 130
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L172
	cal open_selected_file_
	mov t0, a0
__L172:
__L173:
__L170:
__L167:
__L165:
	exit
	mov t0, a0
	add sp, 12
	ret
__L162:
__L163:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 131
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L174
	cal open_file_picker_
	mov t0, a0
	exit
	mov t0, a0
	add sp, 12
	ret
__L174:
__L175:
	mov ea, fp
	lde i16t, t2, -8
	mov t3, 4
	and t1, t2, t3
	mov t0, t1
	cmp neq, t0, zr
	jfs __L178
	mov ea, fp
	lde i16t, t3, -4
	mov t4, 115
	cmp eq, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jtr __L179
	mov ea, fp
	lde i16t, t3, -4
	mov t4, 83
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L179:
	cmp neq, t1, zr
	sel t0, 1, 0
__L178:
	cmp eq, t0, zr
	jtr __L176
	cal save_document_
	mov t0, a0
	exit
	mov t0, a0
	add sp, 12
	ret
__L176:
__L177:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 135
	cmp eq, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L182
	lod i16t, t2, g__cursor
	mov t3, 0
	cmp gt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L182:
	cmp eq, t0, zr
	jtr __L180
	lod i16t, t1, g__cursor
	mov t0, t1
	dec t1
	str i16t, g__cursor, t1
	jmp __L181
__L180:
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 136
	cmp eq, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L185
	lod i16t, t2, g__cursor
	lod i16t, t3, g__text_length
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L185:
	cmp eq, t0, zr
	jtr __L183
	lod i16t, t1, g__cursor
	mov t0, t1
	inc t1
	str i16t, g__cursor, t1
	jmp __L184
__L183:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 137
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L186
	cal move_cursor_up_
	mov t0, a0
	jmp __L187
__L186:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 138
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L188
	cal move_cursor_down_
	mov t0, a0
	jmp __L189
__L188:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 141
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L190
	psh t0
	lod i16t, t0, g__cursor
	mov a0, t0
	cal line_start_
	mov t1, a0
	pop t0
	str i16t, g__cursor, t1
	mov t0, t1
	jmp __L191
__L190:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 142
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L192
	psh t0
	lod i16t, t0, g__cursor
	mov a0, t0
	cal line_start_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -12, t1
	mov t0, t1
	psh t0
	mov ea, fp
	lde i16t, t0, -12
	mov a0, t0
	cal next_line_
	mov t1, a0
	pop t0
	str i16t, g__cursor, t1
	mov t0, t1
	lod i16t, t2, g__cursor
	mov ea, fp
	lde i16t, t3, -12
	cmp gt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L196
	tpa t3, g__text
	lod i16t, t5, g__cursor
	mov t6, 1
	sub t4, t5, t6
	add t3, t4
	mov ea, t3
	lde i8t, t2, 0
	mov t3, 10
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L196:
	cmp eq, t0, zr
	jtr __L194
	lod i16t, t1, g__cursor
	mov t0, t1
	dec t1
	str i16t, g__cursor, t1
__L194:
__L195:
	jmp __L193
__L192:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 129
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L197
	cal erase_before_cursor_
	mov t0, a0
	jmp __L198
__L197:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 140
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L199
	cal erase_at_cursor_
	mov t0, a0
	jmp __L200
__L199:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 130
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L201
	mov t1, 10
	mov a0, t1
	cal insert_character_
	mov t0, a0
	jmp __L202
__L201:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 128
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L203
	mov t1, 32
	mov a0, t1
	cal insert_character_
	mov t0, a0
	mov t1, 32
	mov a0, t1
	cal insert_character_
	mov t0, a0
	mov t1, 32
	mov a0, t1
	cal insert_character_
	mov t0, a0
	mov t1, 32
	mov a0, t1
	cal insert_character_
	mov t0, a0
	jmp __L204
__L203:
	mov ea, fp
	lde i16t, t3, -4
	mov t4, 32
	cmp gte, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jfs __L208
	mov ea, fp
	lde i16t, t3, -4
	mov t4, 126
	cmp lte, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L208:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L207
	mov ea, fp
	lde i16t, t3, -8
	mov t4, 4
	and t2, t3, t4
	cmp eq, t2, zr
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L207:
	cmp eq, t0, zr
	jtr __L205
	mov ea, fp
	lde i16t, t1, -8
	mov t2, 8
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L209
	psh t0
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	cal shifted_character_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
__L209:
__L210:
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	cal insert_character_
	mov t0, a0
__L205:
__L206:
__L204:
__L202:
__L200:
__L198:
__L193:
__L191:
__L189:
__L187:
__L184:
__L181:
	cal keep_cursor_visible_
	mov t0, a0
	exit
	mov t0, a0
	add sp, 12
	ret

sbmk "_mouse_button_input(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_mouse_button_input:
	sub sp, 28
	syscall SYS_GET_MOUSE_BUTTON_INPUT
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 1
	and t1, t2, t3
	mov t0, t1
	cmp neq, t0, zr
	jfs __L213
	lod i16t, t3, g__previous_mouse_buttons
	mov t4, 1
	and t2, t3, t4
	cmp eq, t2, zr
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L213:
	cmp eq, t0, zr
	jtr __L211
	psh t0
	syscall SYS_GET_MOUSE_POSITION
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
	psh t0
	syscall SYS_GET_MOUSE_POSITION
	mov t1, a1
	pop t0
	mov ea, fp
	ste i16t, -12, t1
	mov t0, t1
	lod i16t, t1, g__file_picker
	mov t0, t1
	cmp neq, t0, zr
	jfs __L216
	mov ea, fp
	lde i16t, t2, -12
	mov t3, 20
	cmp gte, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L216:
	cmp eq, t0, zr
	jtr __L214
	mov ea, fp
	lde i16t, t3, -12
	mov t4, 20
	sub t2, t3, t4
	mov t3, 9
	div t1, t2, t3
	mov ea, fp
	ste i16t, -16, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t2, -16
	mov t3, 20
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L219
	lod i16t, t3, g__first_file
	mov ea, fp
	lde i16t, t4, -16
	add t2, t3, t4
	lod i16t, t3, g__file_count
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L219:
	cmp eq, t0, zr
	jtr __L217
	lod i16t, t2, g__first_file
	mov ea, fp
	lde i16t, t3, -16
	add t1, t2, t3
	str i16t, g__selected_file, t1
	mov t0, t1
	cal open_selected_file_
	mov t0, a0
__L217:
__L218:
	jmp __L215
__L214:
	mov ea, fp
	lde i16t, t1, -12
	mov t2, 20
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L220
	mov ea, fp
	lde i16t, t3, -12
	mov t4, 20
	sub t2, t3, t4
	mov t3, 9
	div t1, t2, t3
	mov ea, fp
	ste i16t, -16, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t3, -8
	mov t4, 7
	sub t2, t3, t4
	mov t3, 6
	div t1, t2, t3
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L222
	mov t1, 0
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
__L222:
__L223:
	lod i16t, t1, g__top_line
	mov ea, fp
	ste i16t, -24, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	ste i16t, -28, t1
	mov t0, t1
__L224:
	mov ea, fp
	lde i16t, t2, -28
	mov ea, fp
	lde i16t, t3, -16
	cmp lt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L226
	mov ea, fp
	lde i16t, t2, -24
	lod i16t, t3, g__text_length
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L226:
	cmp neq, t0, zr
	jfs __L225
	psh t0
	mov ea, fp
	lde i16t, t0, -24
	mov a0, t0
	cal next_line_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i16t, -24, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -28
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -28, t1
	jmp __L224
__L225:
	psh t0
	mov ea, fp
	lde i16t, t0, -24
	mov ea, fp
	lde i16t, t2, -20
	mov a1, t2
	mov a0, t0
	cal position_on_line_
	mov t1, a0
	pop t0
	str i16t, g__cursor, t1
	mov t0, t1
	cal keep_cursor_visible_
	mov t0, a0
__L220:
__L221:
__L215:
__L211:
__L212:
	mov ea, fp
	lde i16t, t1, -4
	str i16t, g__previous_mouse_buttons, t1
	mov t0, t1
	exit
	mov t0, a0
	add sp, 28
	ret

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	psh t0
	cal MFS.load
	mov t1, a0
	pop t0
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L227
	cal MFS.format
	mov t0, a0
__L227:
__L228:
	psh t0
	psh t1
	cal MFS.load
	mov t2, a0
	pop t1
	pop t0
	mov t3, 0
	cmp eq, t2, t3
	sel t1, 1, 0
	str i16t, g__filesystem_ready, t1
	mov t0, t1
	mov t1, 0
	tpa t2, g__text
	mov t3, 0
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t1, 0
	tpa t2, g__filename
	mov t3, 0
	add t2, t3
	mov ea, t2
	ste i8t, 0, t1
	mov t0, t1
	mov t0, 0
	mov a0, t0
	ret

g__text:	res i8t 2048, 0
g__filename:	res i8t 64, 0
g__text_length:	emb i16t 0
g__cursor:	emb i16t 0
g__top_line:	emb i16t 0
g__previous_mouse_buttons:	emb i16t 0
g__filesystem_ready:	emb i16t 0
g__save_failed:	emb i16t 0
g__file_picker:	emb i16t 0
g__file_count:	emb i16t 0
g__selected_file:	emb i16t 0
g__first_file:	emb i16t 0
g__listed_filename:	res i8t 64, 0
g__font:	emb u8t 0, 0, 0, 0, 0, 0, 0, 95, 0, 0, 0, 7, 0, 7, 0, 20, 127, 20, 127, 20, 36, 42, 127, 42, 18, 35, 19, 8, 100, 98, 54, 73, 85, 34, 80, 0, 5, 3, 0, 0, 0, 28, 34, 65, 0, 0, 65, 34, 28, 0, 20, 8, 62, 8, 20, 8, 8, 62, 8, 8, 0, 80, 48, 0, 0, 8, 8, 8, 8, 8, 0, 96, 96, 0, 0, 32, 16, 8, 4, 2, 62, 81, 73, 69, 62, 0, 66, 127, 64, 0, 66, 97, 81, 73, 70, 33, 65, 69, 75, 49, 24, 20, 18, 127, 16, 39, 69, 69, 69, 57, 60, 74, 73, 73, 48, 1, 113, 9, 5, 3, 54, 73, 73, 73, 54, 6, 73, 73, 41, 30, 0, 54, 54, 0, 0, 0, 86, 54, 0, 0, 8, 20, 34, 65, 0, 20, 20, 20, 20, 20, 0, 65, 34, 20, 8, 2, 1, 81, 9, 6, 50, 73, 121, 65, 62, 126, 17, 17, 17, 126, 127, 73, 73, 73, 54, 62, 65, 65, 65, 34, 127, 65, 65, 34, 28, 127, 73, 73, 73, 65, 127, 9, 9, 9, 1, 62, 65, 73, 73, 122, 127, 8, 8, 8, 127, 0, 65, 127, 65, 0, 32, 64, 65, 63, 1, 127, 8, 20, 34, 65, 127, 64, 64, 64, 64, 127, 2, 12, 2, 127, 127, 4, 8, 16, 127, 62, 65, 65, 65, 62, 127, 9, 9, 9, 6, 62, 65, 81, 33, 94, 127, 9, 25, 41, 70, 70, 73, 73, 73, 49, 1, 1, 127, 1, 1, 63, 64, 64, 64, 63, 31, 32, 64, 32, 31, 63, 64, 56, 64, 63, 99, 20, 8, 20, 99, 7, 8, 112, 8, 7, 97, 81, 73, 69, 67, 0, 127, 65, 65, 0, 2, 4, 8, 16, 32, 0, 65, 65, 127, 0, 4, 2, 1, 2, 4, 64, 64, 64, 64, 64, 0, 1, 2, 4, 0, 32, 84, 84, 84, 120, 127, 72, 68, 68, 56, 56, 68, 68, 68, 32, 56, 68, 68, 72, 127, 56, 84, 84, 84, 24, 8, 126, 9, 1, 2, 12, 82, 82, 82, 62, 127, 8, 4, 4, 120, 0, 68, 125, 64, 0, 32, 64, 68, 61, 0, 127, 16, 40, 68, 0, 0, 65, 127, 64, 0, 124, 4, 24, 4, 120, 124, 8, 4, 4, 120, 56, 68, 68, 68, 56, 124, 20, 20, 20, 8, 8, 20, 20, 24, 124, 124, 8, 4, 4, 8, 72, 84, 84, 84, 32, 4, 63, 68, 64, 32, 60, 64, 64, 32, 124, 28, 32, 64, 32, 28, 60, 64, 48, 64, 60, 68, 40, 16, 40, 68, 12, 80, 80, 80, 60, 68, 100, 84, 76, 68, 0, 8, 54, 65, 0, 0, 0, 127, 0, 0, 0, 65, 54, 8, 0, 8, 4, 8, 16, 8, 0, 0, 0, 0, 0
__str_123:	emb string "OPEN FILE"
__str_126:	emb string "NO FILES"
__str_140:	emb string "SAVE FAILED"
__str_143:	emb string "UNTITLED"

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
#   MFS.count   - return the number of live files
#   MFS.get_name - copy a live file's name by index
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

    sbmk "MFS.count(): count"
    # Count live entries in the root directory.
    # < a0: number of files
    .count:
        vpsh s0..s3
        mov s0, MFS_DATA.dir_buf
        mov s1, MFS_DATA.dir_buf + MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov s2, 0
        @loop:
            sub t0, s1, s0
            cmp lt, t0, MFS_DIRENT_MIN_REC_LEN
            jtr @done+
            cea s0, 0, 1
            lde u16t, s3, MFS_DIRENT_REC_LEN
            cmp eq, s3, 0
            jtr @done+
            lde u8t, t0, MFS_DIRENT_FLAGS
            and t0, MFS_FLAG_IN_USE
            cmp eq, t0, 0
            jtr @advance+
            inc s2
            @advance:
            add s0, s3
            jmp @loop-
        @done:
        mov a0, s2
        vpop s0..s3
        ret

    sbmk "MFS.get_name(index, dst, max): length | -1"
    # Copy the name of a live directory entry into a null-terminated buffer.
    # > a0: zero-based live entry index, a1: destination, a2: buffer size
    # < a0: copied name length, or -1 if the index or buffer is invalid
    .get_name:
        vpsh s0..s7
        mov s0, a0
        tpr a1
        mov s1, a1
        mov s2, a2
        cmp lt, s2, 1
        jtr @not_found+
        mov s3, MFS_DATA.dir_buf
        mov s4, MFS_DATA.dir_buf + MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov s6, 0
        @loop:
            sub t0, s4, s3
            cmp lt, t0, MFS_DIRENT_MIN_REC_LEN
            jtr @not_found+
            cea s3, 0, 1
            lde u16t, s5, MFS_DIRENT_REC_LEN
            cmp eq, s5, 0
            jtr @not_found+
            lde u8t, t0, MFS_DIRENT_FLAGS
            and t0, MFS_FLAG_IN_USE
            cmp eq, t0, 0
            jtr @advance+
            cmp eq, s6, s0
            jtr @found+
            inc s6
            @advance:
            add s3, s5
            jmp @loop-
        @found:
            lde u8t, s7, MFS_DIRENT_NAME_LEN
            sub t0, s2, 1
            cmp lte, s7, t0
            jtr @copy+
            mov s7, t0
            @copy:
            mov a0, s1
            add a1, s3, MFS_DIRENT_NAME
            mov a2, s7
            syscall SYS_MEM_COPY
            cea s1, s7, 1
            ste u8t, 0, 0
            mov a0, s7
            jmp @done+
        @not_found:
            mov a0, -1
        @done:
        vpop s0..s7
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
