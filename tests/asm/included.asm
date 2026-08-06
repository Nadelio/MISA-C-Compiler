_start:
	cal main_
	exit

sbmk "foo_(num: i16t): i16t"
##
## Parameters:
## > a0 - num, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
foo_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	mov ea, fp
	lde i16t, t0, -4
	mov a0, t0
	add sp, 4
	ret

