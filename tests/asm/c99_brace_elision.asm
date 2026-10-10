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
	add t1, fp, -2
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -1
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
	mov t0, 5
	add t1, fp, -8
	mov ea, t1
	ste i16t, 0, t0
	mov t0, 6
	add t1, fp, -6
	mov ea, t1
	ste i16t, 0, t0
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
	mov t0, 7
	add t1, fp, -4
	mov ea, t1
	ste i16t, 0, t0
	mov t0, 8
	add t1, fp, -2
	mov ea, t1
	ste i16t, 0, t0
	tpa t7, g__global_nested
	mov ea, t7
	lde u32t, t6, 0
	mov t7, 1
	mul t7, 2
	add t6, t7
	mov ea, t6
	lde i16t, t5, 0
	mov t6, 2
	cmp eq, t5, t6
	sel t4, 1, 0
	mov t3, t4
	cmp neq, t3, zr
	jfs __L4
	tpa t7, g__global_nested
	add t6, t7, 4
	mov ea, t6
	lde i16t, t5, 2
	mov t6, 4
	cmp eq, t5, t6
	sel t4, 1, 0
	cmp neq, t4, zr
	sel t3, 1, 0
__L4:
	mov t2, t3
	cmp neq, t2, zr
	jfs __L3
	add t6, fp, -8
	mov ea, t6
	lde u32t, t5, 0
	mov t6, 0
	mul t6, 2
	add t5, t6
	mov ea, t5
	lde i16t, t4, 0
	mov t5, 5
	cmp eq, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L3:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L2
	add t5, fp, -8
	add t4, t5, 4
	mov ea, t4
	lde i16t, t3, 0
	mov t4, 7
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

g__global_nested:
	emb i16t 1
	emb i16t 2
	emb i16t 3
	emb i16t 4
