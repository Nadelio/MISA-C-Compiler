_start:
	cal main_
	exit

main_:
	mov t1, 3.14159
	mov t2, 2
	mov a1, t2
	mov a0, t1
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	mov t1, 2.71828
	mov t2, 4
	mov a1, t2
	mov a0, t1
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	mov t1, 1.0
	mov t2, 0
	mov a1, t2
	mov a0, t1
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	mov t0, 0
	mov a0, t0
	ret

