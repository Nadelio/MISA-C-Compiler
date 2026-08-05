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
	mov t1, 23
	mov a0, t1
	syscall SYS_ALLOW_UNSAFE_JUMP
	mov t0, a0
	mov t1, 99
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t0, 0
	mov a0, t0
	ret

