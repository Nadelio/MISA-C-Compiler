bmk "TOP"
_start:
	cal main_
	exit

sbmk "increment_(value: i16t): i16t"
##
## Parameters:
## > a0 - value, is i16t
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
increment_:
	sub sp, 4
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 1
	add t0, t1, t2
	mov a0, t0
	add sp, 4
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
	mov t0, 4
	mov a0, t0
	cal increment_
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
	ret

