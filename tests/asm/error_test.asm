_start:
	cal main_
	exit

main_:
	mov t1, zr
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	ret

