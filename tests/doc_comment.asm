_start:
	cal main_
	exit

sbmk "foo_(): void"
## This prints "foo" to the console
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
## This also increments the global variable X
foo_:
	tpa t1, __str_0
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_STRING
	mov t0, a0
	lod i32t, t1, g__x
	mov t0, t1
	inc t1
	str i32t, g__x, t1
	ret

sbmk "beep_(a: i32t): i32t"
## prints the given number `a`
## Parameters:
## > a0 - some number
## Returns:
## < a0 - The sum of the global variable `x` and `a`
## Additional Implementation Notes:
## This function also increments the global variable x
beep_:
	sub sp, 4
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	lde i32t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	lod i32t, t1, g__x
	mov t0, t1
	inc t1
	str i32t, g__x, t1
	lod i32t, t1, g__x
	mov ea, fp
	lde i32t, t2, -4
	add t0, t1, t2
	mov a0, t0
	add sp, 4
	ret

sbmk "multiple_params_(a: i32t, message: i8t*): void"
## prints `a` first, then `message`
## Parameters:
## > a0 - a, is i32t
## > a1 - message, is i8t*
## Returns: NONE
## Additional Implementation Notes:
multiple_params_:
	sub sp, 8
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	lde i32t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	mov ea, fp
	lde u32t, t1, -8
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_STRING
	mov t0, a0
	add sp, 8
	ret

g__x:	emb i32t 0
__str_0:	emb string "foo"
