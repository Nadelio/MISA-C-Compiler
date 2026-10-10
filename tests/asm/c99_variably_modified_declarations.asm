bmk "TOP"
_start:
	cal main_
	exit

sbmk "first_(count: i16t, values: i16t*): i16t"
##
## Parameters:
## > a0 - count, is i16t
## > a1 - values, is i16t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
first_:
	sub sp, 16
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	lde i16t, t0, -4
	mul t0, 2
	add t0, t0, 3
	and t0, t0, -4
	sub sp, t0
	mov ea, fp
	ste u32t, -16, sp
	ste u32t, -12, t0
	mov ea, fp
	lde u32t, t2, -8
	mov t3, 0
	mul t3, 2
	add t2, t3
	mov ea, t2
	lde i16t, t1, 0
	mov ea, fp
	lde u32t, t2, -16
	mov t3, 0
	mul t3, 2
	add t2, t3
	mov ea, t2
	ste i16t, 0, t1
	mov t0, t1
	mov ea, fp
	lde u32t, t1, -16
	mov t2, 0
	mul t2, 2
	add t1, t2
	mov ea, t1
	lde i16t, t0, 0
	mov a0, t0
	mov sp, fp
	ret

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	sub sp, 4
	mov t0, zr
	add t1, fp, -4
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -3
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -2
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -1
	mov ea, t1
	ste u8t, 0, t0
	mov t0, 5
	add t1, fp, -4
	mov ea, t1
	ste i16t, 0, t0
	mov t0, 6
	add t1, fp, -2
	mov ea, t1
	ste i16t, 0, t0
	psh t0
	psh t1
	mov t0, 2
	add t1, fp, -4
	mov a1, t1
	mov a0, t0
	cal first_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 5
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	jfs __L0
	mov t1, 0
	mov t0, t1
	jmp __L1
__L0:
	mov t1, 1
	mov t0, t1
__L1:
	mov a0, t0
	add sp, 4
	ret

