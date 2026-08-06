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
	syscall SYS_GET_TERMINAL_INPUT_SIZE
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	tpa t1, g__buf
	mov ea, fp
	lde i16t, t2, -4
	mov a1, t2
	mov a0, t1
	tpr a0
	syscall SYS_READ_TERMINAL_INPUT
	mov t0, a0
	mov ea, fp
	ste i16t, -8, t0
	tpa t1, g__buf
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_LINE_STRING
	mov t0, a0
	mov ea, fp
	lde i16t, t1, -8
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
__L0:
__L1:
	mov t0, 0
	mov a0, t0
	add sp, 8
	ret

g__buf:	res i8t 256, 0
