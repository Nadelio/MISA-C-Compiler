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
	mov t0, 65535
	ubx t0, t0, 0, 16
	mov ea, fp
	ste u16t, -4, t0
	mov t0, 1
	mov ea, fp
	ste u16t, -8, t0
	mov t1, 1
	neg t0, t1
	mov ea, fp
	ste i32t, -12, t0
	mov t0, 1
	mov ea, fp
	ste u32t, -16, t0
	mov t1, 2
	mov t2, 2
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	mov t0, 1
	mov a0, t0
	add sp, 16
	ret
__L0:
__L1:
	mov t1, 4
	mov t2, 4
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L2
	mov t0, 2
	mov a0, t0
	add sp, 16
	ret
__L2:
__L3:
	mov t1, 2
	mov t2, 2
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L4
	mov t0, 3
	mov a0, t0
	add sp, 16
	ret
__L4:
__L5:
	mov t1, 4
	mov t2, 4
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L6
	mov t0, 4
	mov a0, t0
	add sp, 16
	ret
__L6:
__L7:
	mov t1, 4
	mov t2, 4
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L8
	mov t0, 5
	mov a0, t0
	add sp, 16
	ret
__L8:
__L9:
	mov t1, 4
	mov t2, 4
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L10
	mov t0, 6
	mov a0, t0
	add sp, 16
	ret
__L10:
__L11:
	mov t1, 63
	mov t2, 63
	cmp neq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L12
	mov t0, 7
	mov a0, t0
	add sp, 16
	ret
__L12:
__L13:
	mov ea, fp
	lde u16t, t2, -4
	mov ea, fp
	lde u16t, t3, -4
	add t1, t2, t3
	mov ea, fp
	ste u16t, -8, t1
	mov t0, t1
	mov ea, fp
	lde u16t, t2, -8
	mov ea, fp
	lde i32t, t3, -12
	add t1, t2, t3
	mov ea, fp
	ste i32t, -12, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t2, -12
	mov ea, fp
	lde u32t, t3, -16
	add t1, t2, t3
	mov ea, fp
	ste u32t, -16, t1
	mov t0, t1
	mov t0, 0
	mov a0, t0
	add sp, 16
	ret

