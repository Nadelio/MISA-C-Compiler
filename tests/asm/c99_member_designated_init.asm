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
	mov t0, 3
	add t1, fp, -4
	mov ea, t1
	ste i16t, 0, t0
	mov t0, 7
	add t1, fp, -2
	mov ea, t1
	ste i16t, 0, t0
	tpa t7, g__global_point
	mov ea, t7
	lde i16t, t6, 0
	tpa t8, g__global_point
	mov ea, t8
	lde i16t, t7, 2
	add t5, t6, t7
	tpa t7, g__global_number
	mov ea, t7
	lde i32t, t6, 0
	add t4, t5, t6
	add t6, fp, -4
	mov ea, t6
	lde i16t, t5, 0
	add t3, t4, t5
	add t5, fp, -4
	mov ea, t5
	lde i16t, t4, 2
	add t2, t3, t4
	mov t3, 35
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

g__global_point:
	emb i16t 4
	emb i16t 9
g__global_number:
	emb i32t 12
