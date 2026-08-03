_start:
	cal main_
	exit

main_:
	sub sp, 12
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a0
	mov ea, fp
	ste i32t, -4, t0
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a1
	mov ea, fp
	ste i32t, -8, t0
	syscall SYS_GET_MOUSE_BUTTON_INPUT
	mov t0, a0
	mov ea, fp
	ste i32t, -12, t0
	mov ea, fp
	lde i32t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov ea, fp
	lde i32t, t1, -8
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 1
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L0
	mov t1, 1
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
__L0:
__L1:
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 2
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L2
	mov t1, 2
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
__L2:
__L3:
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 4
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L4
	mov t1, 4
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
__L4:
__L5:
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 8
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L6
	mov t1, 8
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
__L6:
__L7:
	mov ea, fp
	lde i32t, t1, -12
	mov t2, 16
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L8
	mov t1, 16
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
__L8:
__L9:
	mov t0, 0
	mov a0, t0
	add sp, 12
	ret

