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
	add t0, fp, -4
	mov t1, 120
	mov ea, t0
	ste u8t, 0, t1
	add t0, fp, -3
	mov t1, 121
	mov ea, t0
	ste u8t, 0, t1
	add t0, fp, -2
	mov t1, 0
	mov ea, t0
	ste u8t, 0, t1
	tpa t6, g__global_text
	mov t7, 3
	add t6, t7
	mov ea, t6
	lde i8t, t5, 0
	mov t6, 0
	cmp eq, t5, t6
	sel t4, 1, 0
	mov t3, t4
	cmp neq, t3, zr
	jfs __L4
	add t6, fp, -4
	mov t7, 0
	add t6, t7
	mov ea, t6
	lde i8t, t5, 0
	mov t6, 120
	cmp eq, t5, t6
	sel t4, 1, 0
	cmp neq, t4, zr
	sel t3, 1, 0
__L4:
	mov t2, t3
	cmp neq, t2, zr
	jfs __L3
	add t5, fp, -4
	mov t6, 1
	add t5, t6
	mov ea, t5
	lde i8t, t4, 0
	mov t5, 121
	cmp eq, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L3:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L2
	add t4, fp, -4
	mov t5, 2
	add t4, t5
	mov ea, t4
	lde i8t, t3, 0
	mov t4, 0
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L2:
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

g__global_text:	emb i8t 97, 98, 99, 0
