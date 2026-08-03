_start:
	cal main_
	exit

foo_:
	sub sp, 4
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	lde i32t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	mov ea, fp
	lde i32t, t0, -4
	mov a0, t0
	add sp, 4
	ret

