_start:
	cal main_
	exit

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	sub sp, 8
	mov t1, 24
	mov a0, t1
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	mov t1, 25
	mov a0, t1
	syscall SYS_GET_MOUSE_BUTTON_INPUT
	mov t0, a0
	mov ea, fp
	ste i16t, -8, t0
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov ea, fp
	lde i16t, t1, -8
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 8
	ret

