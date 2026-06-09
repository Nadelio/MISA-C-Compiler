_start:
	cal main_
	exit

sbmk "test_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
test_:
	sub sp, 4
	mov t1, 0
	mov t2, 42
	mov a1, t2
	mov a0, t1
	mov a0, a1
	syscall SYS_PRINT_INT
	mov t0, a0
	mov t1, 3
	mov t2, 10
	mov t3, 20
	mov t4, 100
	mov t5, 50
	mov t6, 15
	mov a5, t6
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	mov a0, a1
	mov a1, a2
	mov a2, a3
	mov a3, a4
	mov a4, a5
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 12
	mov a0, t1
	syscall SYS_GET_INPUT
	mov t0, a0
	mov ea, fp
	ste i32t, -4, t0
	add sp, 4
	ret

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
main_:
	cal test_
	mov t0, a0
	mov t0, 0
	mov a0, t0
	ret

