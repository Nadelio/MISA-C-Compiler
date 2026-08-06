bmk "TOP"
_start:
	cal main_
	exit

sbmk "dot_(a: u32t, b: u32t): i16t"
##
## Parameters:
## > a0 - a, is u32t
## > a1 - b, is u32t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
dot_:
	sub sp, 8
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste u32t, -8, a1
	add t3, fp, -4
	mov ea, t3
	lde u32t, t3, 0
	mov ea, t3
	lde i16t, t2, 0
	add t4, fp, -8
	mov ea, t4
	lde u32t, t4, 0
	mov ea, t4
	lde i16t, t3, 0
	mul t1, t2, t3
	add t4, fp, -4
	mov ea, t4
	lde u32t, t4, 0
	mov ea, t4
	lde i16t, t3, 2
	add t5, fp, -8
	mov ea, t5
	lde u32t, t5, 0
	mov ea, t5
	lde i16t, t4, 2
	mul t2, t3, t4
	add t0, t1, t2
	mov a0, t0
	add sp, 8
	ret

sbmk "classify_(v: i16t): i16t"
##
## Parameters:
## > a0 - v, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
classify_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	lde i16t, t0, -4
	mov t14, t0
	cmp eq, t14, 0
	jtr __L2
	cmp eq, t14, 1
	jtr __L3
	jmp __L1
__L2:
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret
__L3:
	mov t0, 1
	mov a0, t0
	add sp, 4
	ret
__L1:
	mov t1, 1
	neg t0, t1
	mov a0, t0
	add sp, 4
	ret
__L0:
	add sp, 4
	ret

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	sub sp, 8
	mov t1, 3
	add t2, fp, -4
	mov ea, t2
	ste i16t, 0, t1
	mov t0, t1
	mov t1, 4
	add t2, fp, -4
	mov ea, t2
	ste i16t, 2, t1
	mov t0, t1
	mov t1, 1
	add t2, fp, -8
	mov ea, t2
	ste i16t, 0, t1
	mov t0, t1
	mov t1, 2
	add t2, fp, -8
	mov ea, t2
	ste i16t, 2, t1
	mov t0, t1
	psh t0
	psh t1
	add t1, fp, -4
	add t2, fp, -8
	mov a1, t2
	mov a0, t1
	cal dot_
	mov t0, a0
	pop t1
	mov a0, t0
	cal classify_
	mov t1, a0
	pop t0
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 8
	ret

