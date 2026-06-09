_start:
	cal main_
	exit

sbmk "fib_(n: i32t): i32t"
##
## Parameters:
## > a0 - n, is i32t
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
fib_:
	sub sp, 4
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	lde i32t, t1, -4
	mov t2, 1
	cmp lte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	mov ea, fp
	lde i32t, t0, -4
	mov a0, t0
	add sp, 4
	ret
__L0:
__L1:
	psh t0
	mov ea, fp
	lde i32t, t2, -4
	mov t3, 1
	sub t0, t2, t3
	mov a0, t0
	cal fib_
	mov t1, a0
	pop t0
	psh t0
	psh t1
	mov ea, fp
	lde i32t, t1, -4
	mov t3, 2
	sub t0, t1, t3
	mov a0, t0
	cal fib_
	mov t2, a0
	pop t1
	pop t0
	add t0, t1, t2
	mov a0, t0
	add sp, 4
	ret

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
main_:
	sub sp, 8
	mov t1, 0
	str i32t, g__g_count, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	ste i32t, -4, t1
	mov t0, t1
__L2:
	mov ea, fp
	lde i32t, t1, -4
	mov t2, 8
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L4
	psh t0
	mov ea, fp
	lde i32t, t0, -4
	mov a0, t0
	cal fib_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -8, t1
	mov t0, t1
	lod i32t, t2, g__g_count
	mov t3, 1
	add t1, t2, t3
	str i32t, g__g_count, t1
	mov t0, t1
__L3:
	mov ea, fp
	lde i32t, t2, -4
	mov t3, 1
	add t1, t2, t3
	mov ea, fp
	ste i32t, -4, t1
	mov t0, t1
	jmp __L2
__L4:
	mov ea, fp
	lde i32t, t0, -8
	mov a0, t0
	add sp, 8
	ret

g__g_count:	res i32t 1, 0
