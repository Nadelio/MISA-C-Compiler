bmk "TOP"
_start:
	cal main_
	exit

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	sub sp, 8
	mov t0, 5
	mov ea, fp
	ste i16t, -4, t0
__L0:
	mov ea, fp
	lde i16t, t1, -4
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 1
	add t1, t2, t3
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
__L2:
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 3
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jtr __L0
__L1:
	mov t0, 0
	mov ea, fp
	ste i16t, -8, t0
__L3:
	mov ea, fp
	lde i16t, t1, -8
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov ea, fp
	lde i16t, t2, -8
	mov t3, 1
	add t1, t2, t3
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
__L5:
	mov ea, fp
	lde i16t, t1, -8
	mov t2, 3
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jtr __L3
__L4:
	mov t0, 0
	mov a0, t0
	add sp, 8
	ret

