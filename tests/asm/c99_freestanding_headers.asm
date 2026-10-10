bmk "TOP"
_start:
	cal main_
	exit

sbmk "sum_(count: i16t): i16t"
##
## Parameters:
## > a0 - count, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
sum_:
	sub sp, 72
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	mov ea, fp
	ste u32t, -12, a2
	mov ea, fp
	ste u32t, -16, a3
	mov ea, fp
	ste u32t, -20, a4
	mov ea, fp
	ste u32t, -24, a5
	mov ea, fp
	ste u32t, -28, a6
	mov ea, fp
	ste u32t, -32, a7
	mov ea, fp
	ste u32t, -36, a8
	mov ea, fp
	ste u32t, -40, a9
	mov ea, fp
	ste u32t, -44, a10
	mov ea, fp
	ste u32t, -48, a11
	mov ea, fp
	ste u32t, -52, a12
	mov ea, fp
	ste u32t, -56, a13
	mov ea, fp
	ste u32t, -60, a14
	mov ea, fp
	ste u32t, -64, a15
	mov t0, 0
	mov ea, fp
	ste i16t, -72, t0
	add t4, fp, -4
	mov t3, t4
	mov t2, t3
	mov t3, 4
	sub t1, t2, t3
	mov ea, fp
	ste u32t, -68, t1
	mov t0, t1
__L0:
	mov ea, fp
	lde i16t, t2, -4
	mov t1, t2
	dec t2
	mov ea, fp
	ste i16t, -4, t2
	mov t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L1
	mov t5, 4
	mov ea, fp
	lde u32t, t6, -68
	sub t7, t6, t5
	mov ea, fp
	ste u32t, -68, t7
	mov t4, t7
	mov t5, 4
	add t3, t4, t5
	mov t2, t3
	mov ea, t2
	lde i16t, t1, 0
	mov ea, fp
	lde i16t, t2, -72
	add t3, t2, t1
	mov ea, fp
	ste i16t, -72, t3
	mov t0, t3
	jmp __L0
__L1:
	mov ea, fp
	lde u32t, t1, -68
	mov t0, t1
	mov ea, fp
	lde i16t, t0, -72
	mov a0, t0
	add sp, 72
	ret

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	sub sp, 4
	mov t4, 8
	mov t5, 8
	cmp eq, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L4
	mov t4, 32767
	mov t5, 32767
	cmp eq, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L4:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L3
	mov t3, 4
	mov t4, 4
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L3:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L2
	mov t2, 2
	mov t3, 2
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L2:
	ubx t0, t0, 0, 8
	mov ea, fp
	ste u8t, -4, t0
	mov ea, fp
	lde u8t, t2, -4
	mov t1, t2
	cmp neq, t1, zr
	jfs __L7
	psh t0
	psh t1
	psh t2
	mov t0, 3
	mov t1, 4
	mov t2, 5
	mov t4, 6
	mov a3, t4
	mov a2, t2
	mov a1, t1
	mov a0, t0
	cal sum_
	mov t3, a0
	pop t2
	pop t1
	pop t0
	mov t4, 15
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L7:
	cmp neq, t1, zr
	jfs __L5
	mov t1, 0
	mov t0, t1
	jmp __L6
__L5:
	mov t1, 1
	mov t0, t1
__L6:
	mov a0, t0
	add sp, 4
	ret

