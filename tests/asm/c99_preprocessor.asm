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
	sub sp, 16
	tpa t0, __str_0
	mov ea, fp
	ste u32t, -4, t0
	tpa t0, __str_1
	mov ea, fp
	ste u32t, -8, t0
	tpa t0, __str_2
	mov ea, fp
	ste u32t, -12, t0
	mov t0, 105
	sbx t0, t0, 0, 16
	mov ea, fp
	ste i16t, -16, t0
	mov ea, fp
	lde u32t, t7, -4
	mov t8, 0
	add t7, t8
	mov ea, t7
	lde i8t, t6, 0
	mov t7, 118
	cmp eq, t6, t7
	sel t5, 1, 0
	mov ea, fp
	lde i16t, t7, -16
	mov t8, 105
	cmp eq, t7, t8
	sel t6, 1, 0
	add t4, t5, t6
	mov t5, 2
	cmp eq, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L6
	mov ea, fp
	lde u32t, t4, -8
	mov t5, 0
	add t4, t5
	mov ea, t4
	lde i8t, t3, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L6:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L5
	mov ea, fp
	lde u32t, t3, -12
	mov t4, 0
	add t3, t4
	mov ea, t3
	lde i8t, t2, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L5:
	cmp neq, t1, zr
	jfs __L3
	mov t1, 0
	mov t0, t1
	jmp __L4
__L3:
	mov t1, 1
	mov t0, t1
__L4:
	mov a0, t0
	add sp, 16
	ret

__str_0:	emb string "virtual_source.c"
__str_1:	emb string "Oct 10 2026"
__str_2:	emb string "11:06:02"
