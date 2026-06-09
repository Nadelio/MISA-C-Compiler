_start:
	cal main_
	exit

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
main_:
	sub sp, 4
	tpa t0, __str_0
	mov ea, fp
	ste u32t, -4, t0
	mov ea, fp
	lde u32t, t1, -4
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
