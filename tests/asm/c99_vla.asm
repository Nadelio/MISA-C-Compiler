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
	sub sp, 20
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	lde i16t, t0, -4
	mul t0, 2
	add t0, t0, 3
	and t0, t0, -4
	sub sp, t0
	mov ea, fp
	ste u32t, -12, sp
	ste u32t, -8, t0
	mov ea, fp
	lde u32t, t0, -8
	mov ea, fp
	ste i16t, -16, t0
	mov t1, 1
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	mov t0, 0
	mov ea, fp
	ste i16t, -20, t0
__L0:
	mov ea, fp
	lde i16t, t1, -20
	mov ea, fp
	lde i16t, t3, -16
	mov t4, 2
	div t2, t3, t4
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L2
	mov ea, fp
	lde i16t, t2, -20
	mov t3, 1
	add t1, t2, t3
	mov ea, fp
	lde u32t, t2, -12
	mov ea, fp
	lde i16t, t3, -20
	mul t3, 2
	add t2, t3
	mov ea, t2
	ste i16t, 0, t1
	mov t0, t1
__L1:
	mov ea, fp
	lde i16t, t1, -20
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -20, t1
	jmp __L0
__L2:
	mov ea, fp
	lde u32t, t3, -12
	mov t4, 0
	mul t4, 2
	add t3, t4
	mov ea, t3
	lde i16t, t2, 0
	mov ea, fp
	lde u32t, t4, -12
	mov t5, 2
	mul t5, 2
	add t4, t5
	mov ea, t4
	lde i16t, t3, 0
	add t1, t2, t3
	mov ea, fp
	lde i16t, t2, -16
	add t0, t1, t2
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
	psh t0
	psh t1
	mov t0, 3
	mov a0, t0
	cal sum_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 10
	cmp eq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	jfs __L3
	mov t1, 0
	mov t0, t1
	jmp __L4
__L3:
	mov t1, 1
	mov t0, t1
__L4:
	mov a0, t0
	ret

