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
	sub sp, 16
	mov t1, 8
	mov t2, 256
	orr t0, t1, t2
	mov ea, fp
	ste i16t, -4, t0
	mov t1, 1
	mov t2, 8
	orr t0, t1, t2
	mov ea, fp
	ste i16t, -8, t0
	mov t0, 37
	mov ea, fp
	ste i16t, -12, t0
	mov t1, 1
	mov t2, 2
	orr t0, t1, t2
	mov ea, fp
	ste i16t, -16, t0
	mov ea, fp
	lde i16t, t3, -4
	mov t2, t3
	cmp neq, t2, zr
	jfs __L4
	mov ea, fp
	lde i16t, t3, -8
	cmp neq, t3, zr
	sel t2, 1, 0
__L4:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L3
	mov ea, fp
	lde i16t, t2, -12
	cmp neq, t2, zr
	sel t1, 1, 0
__L3:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L2
	mov ea, fp
	lde i16t, t1, -16
	cmp neq, t1, zr
	sel t0, 1, 0
__L2:
	cmp eq, t0, zr
	jtr __L0
	mov t0, 1
	mov a0, t0
	add sp, 16
	ret
__L0:
__L1:
	mov t0, 0
	mov a0, t0
	add sp, 16
	ret

