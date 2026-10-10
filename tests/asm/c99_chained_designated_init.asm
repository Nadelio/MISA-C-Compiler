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
	sub sp, 8
	mov t0, zr
	add t1, fp, -8
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -7
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -6
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -5
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -4
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -3
	mov ea, t1
	ste u8t, 0, t0
	mov t0, zr
	add t1, fp, -8
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -7
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -6
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -5
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -4
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -3
	mov ea, t1
	ste u8t, 0, t0
	mov t0, zr
	add t1, fp, -6
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -5
	mov ea, t1
	ste u8t, 0, t0
	mov t0, 9
	add t1, fp, -6
	mov ea, t1
	ste i16t, 0, t0
	tpa t7, g__global_rows
	mov t8, 1
	mul t8, 6
	add t7, t8
	mov t6, t7
	mov ea, t6
	lde u32t, t5, 0
	mov t6, 2
	mul t6, 2
	add t5, t6
	mov t4, t5
	mov ea, t4
	lde i16t, t3, 0
	mov t4, 17
	cmp eq, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jfs __L2
	add t6, fp, -8
	mov ea, t6
	lde u32t, t5, 0
	mov t6, 1
	mul t6, 2
	add t5, t6
	mov t4, t5
	mov ea, t4
	lde i16t, t3, 0
	mov t4, 9
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
	add sp, 8
	ret

g__global_rows:
	res u8t 2, 0
	res u8t 2, 0
	res u8t 2, 0
	res u8t 2, 0
	res u8t 2, 0
	emb i16t 17
