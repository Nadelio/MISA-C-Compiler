_start:
	cal main_
	exit

sbmk "test_string_(s: i8t*): void"
##
## Parameters:
## > a0 - s, is i8t*
## Returns: NONE
## Additional Implementation Notes:
test_string_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov t1, 5
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
	syscall SYS_PRINT_LINE_STRING
	mov t0, a0
	add sp, 4
	ret

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
main_:
	mov t1, 1
	mov t2, 42
	mov a1, t2
	mov a0, t1
	mov a0, a1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t1, 3
	mov t2, 3.14
	mov t3, 2
	mov a2, t3
	mov a1, t2
	mov a0, t1
	mov a0, a1
	mov a1, a2
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	tpa t1, __str_0
	mov a0, t1
	cal test_string_
	mov t0, a0
	mov t0, 0
	mov a0, t0
	ret

__str_0:	emb string "hello"
