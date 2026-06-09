_start:
	cal main_
	exit

sbmk "dot_(a: u32t, b: u32t): i32t"
##
## Parameters:
## > a0 - a, is u32t
## > a1 - b, is u32t
## Returns:
## < a0 - return value, is i32t
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
	lde i32t, t2, 0
	add t4, fp, -8
	mov ea, t4
	lde u32t, t4, 0
	mov ea, t4
	lde i32t, t3, 0
	mul t1, t2, t3
	add t4, fp, -4
	mov ea, t4
	lde u32t, t4, 0
	mov ea, t4
	lde i32t, t3, 4
	add t5, fp, -8
	mov ea, t5
	lde u32t, t5, 0
	mov ea, t5
	lde i32t, t4, 4
	mul t2, t3, t4
	add t0, t1, t2
	mov a0, t0
	add sp, 8
	ret

sbmk "classify_(v: i32t): i32t"
##
## Parameters:
## > a0 - v, is i32t
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
classify_:
	sub sp, 4
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	lde i32t, t0, -4
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

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
main_:
	sub sp, 16
	mov t1, 3
	add t2, fp, -8
	mov ea, t2
	ste i32t, 0, t1
	mov t0, t1
	mov t1, 4
	add t2, fp, -8
	mov ea, t2
	ste i32t, 4, t1
	mov t0, t1
	mov t1, 1
	add t2, fp, -16
	mov ea, t2
	ste i32t, 0, t1
	mov t0, t1
	mov t1, 2
	add t2, fp, -16
	mov ea, t2
	ste i32t, 4, t1
	mov t0, t1
	psh t0
	add t0, fp, -8
	add t2, fp, -16
	mov a1, t2
	mov a0, t0
	cal dot_
	mov t1, a0
	pop t0
	mov a0, t1
	cal classify_
	mov t0, a0
	mov a0, t0
	add sp, 16
	ret

