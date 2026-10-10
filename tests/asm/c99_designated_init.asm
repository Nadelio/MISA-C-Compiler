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
	sub sp, 12
	mov t0, zr
	add t1, fp, -12
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -11
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -10
	mov ea, t1
	ste u8t, 0, t0
	add t1, fp, -9
	mov ea, t1
	ste u8t, 0, t0
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
	mov t0, 3
	add t1, fp, -10
	mov ea, t1
	ste i16t, 0, t0
	mov t0, 8
	add t1, fp, -8
	mov ea, t1
	ste i16t, 0, t0
	mov t0, 9
	add t1, fp, -4
	mov ea, t1
	ste i16t, 0, t0
	tpa t8, g__global_values
	mov t9, 2
	mul t9, 2
	add t8, t9
	mov ea, t8
	lde i16t, t7, 0
	tpa t9, g__global_values
	mov t10, 5
	mul t10, 2
	add t9, t10
	mov ea, t9
	lde i16t, t8, 0
	add t6, t7, t8
	tpa t8, g__inferred_values
	mov t9, 3
	mul t9, 2
	add t8, t9
	mov ea, t8
	lde i16t, t7, 0
	add t5, t6, t7
	add t7, fp, -12
	mov t8, 1
	mul t8, 2
	add t7, t8
	mov ea, t7
	lde i16t, t6, 0
	add t4, t5, t6
	add t6, fp, -12
	mov t7, 2
	mul t7, 2
	add t6, t7
	mov ea, t6
	lde i16t, t5, 0
	add t3, t4, t5
	add t5, fp, -12
	mov t6, 4
	mul t6, 2
	add t5, t6
	mov ea, t5
	lde i16t, t4, 0
	add t2, t3, t4
	mov t3, 40
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
	add sp, 12
	ret

g__global_values:
	res u8t 2, 0
	res u8t 2, 0
	emb i16t 7
	res u8t 2, 0
	res u8t 2, 0
	emb i16t 9
g__inferred_values:
	res u8t 2, 0
	res u8t 2, 0
	res u8t 2, 0
	emb i16t 4
