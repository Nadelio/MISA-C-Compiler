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
	sub sp, 28
	mov t2, 4
	add t3, fp, -8
	mov ea, t3
	ste i16t, 0, t2
	add t1, fp, -8
	mov ea, t1
	lde i16t, t0, 0
	mov ea, fp
	ste i16t, -4, t0
	mov t2, zr
	add t3, fp, -16
	mov ea, t3
	ste u8t, 0, t2
	add t3, fp, -15
	mov ea, t3
	ste u8t, 0, t2
	add t3, fp, -14
	mov ea, t3
	ste u8t, 0, t2
	add t3, fp, -13
	mov ea, t3
	ste u8t, 0, t2
	mov t2, 3
	add t3, fp, -16
	mov ea, t3
	ste i16t, 0, t2
	mov t2, 7
	add t3, fp, -14
	mov ea, t3
	ste i16t, 0, t2
	add t1, fp, -16
	mov ea, t1
	lde i16t, t0, 2
	mov ea, fp
	ste i16t, -12, t0
	mov t3, zr
	add t4, fp, -28
	mov ea, t4
	ste u8t, 0, t3
	add t4, fp, -27
	mov ea, t4
	ste u8t, 0, t3
	add t4, fp, -26
	mov ea, t4
	ste u8t, 0, t3
	add t4, fp, -25
	mov ea, t4
	ste u8t, 0, t3
	add t4, fp, -24
	mov ea, t4
	ste u8t, 0, t3
	add t4, fp, -23
	mov ea, t4
	ste u8t, 0, t3
	mov t3, 9
	add t4, fp, -24
	mov ea, t4
	ste i16t, 0, t3
	add t2, fp, -28
	mov t1, t2
	mov t2, 2
	mul t2, 2
	add t1, t2
	mov ea, t1
	lde i16t, t0, 0
	mov ea, fp
	ste i16t, -20, t0
	mov ea, fp
	lde i16t, t4, -4
	mov ea, fp
	lde i16t, t5, -12
	add t3, t4, t5
	mov ea, fp
	lde i16t, t4, -20
	add t2, t3, t4
	mov t3, 20
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
	add sp, 28
	ret

