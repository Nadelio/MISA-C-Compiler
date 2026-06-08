_start:
	cal main_
	exit

test2_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov t1, 2
	psh t0
	psh t1
	mov ea, fp
	lde u32t, t0, -4
	mov a0, t0
	tpr a0
	mov t2, a0
	pop t1
	pop t0
	mov a1, t2
	mov a0, t1
	mov a0, a1
	syscall SYS_PRINT_STRING
	mov t0, a0
	add sp, 4
	ret

