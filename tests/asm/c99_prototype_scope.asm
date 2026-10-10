bmk "TOP"
_start:
	cal main_
	exit

sbmk "inspect_(value: u32t*): i16t"
##
## Parameters:
## > a0 - value, is u32t*
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
inspect_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	mov ea, t1
	lde i16t, t0, 0
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
	sub sp, 4
	mov t0, zr
	add t1, fp, -4
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -3
	mov ea, t1
	ste u8t, 0, t0
	mov t0, 9
	add t1, fp, -4
	mov ea, t1
	ste i16t, 0, t0
	psh t0
	psh t1
	add t1, fp, -4
	mov t0, t1
	mov a0, t0
	cal inspect_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 9
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

