_start:
	cal main_
	exit

main_:
	sub sp, 4
	tpa t0, __str_0
	add t14, fp, -4
	mov ea, t14
	ste u32t, 0, t0
	add t14, fp, -4
	mov ea, t14
	lde u32t, t1, 0
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_STRING
	mov t0, a0
	mov t1, 0
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	mov t1, 0.0
	mov a0, t1
	syscall SYS_PRINT_FLOAT
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret

__str_0:	emb string "Hello, World!"
