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
	mov t1, 1
	add t0, fp, -4
	mov ea, t0
	lde u16t, t2, 0
	mov t3, t1
	and t3, t3, 7
	and t2, t2, -8
	orr t2, t2, t3
	ste u16t, 0, t2
	mov t1, 2
	add t0, fp, -4
	mov ea, t0
	lde u16t, t2, 0
	mov t3, t1
	and t3, t3, 31
	sll t3, t3, 3
	and t2, t2, -249
	orr t2, t2, t3
	ste u16t, 0, t2
	mov t2, 2
	neg t1, t2
	add t0, fp, -4
	mov ea, t0
	lde i16t, t2, 2
	mov t3, t1
	and t3, t3, 15
	and t2, t2, -16
	orr t2, t2, t3
	ste i16t, 2, t2
	add t1, fp, -4
	mov t0, t1
	mov ea, fp
	ste u32t, -8, t0
	tpa t4, g__global_flags
	mov ea, t4
	lde u16t, t3, 0
	and t3, t3, 7
	mov t4, 2
	cmp neq, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jtr __L3
	tpa t4, g__global_flags
	mov ea, t4
	lde u16t, t3, 0
	srl t3, t3, 3
	and t3, t3, 31
	mov t4, 6
	cmp neq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L3:
	mov t0, t1
	cmp neq, t0, zr
	jtr __L2
	tpa t3, g__global_flags
	mov ea, t3
	lde i16t, t2, 2
	and t2, t2, 15
	sll t2, t2, 28
	sar t2, t2, 28
	mov t4, 1
	neg t3, t4
	cmp neq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L2:
	cmp eq, t0, zr
	jtr __L0
	mov t0, 1
	mov a0, t0
	add sp, 8
	ret
__L0:
__L1:
	add t4, fp, -4
	mov ea, t4
	lde u16t, t3, 0
	and t3, t3, 7
	mov t4, 1
	cmp neq, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jtr __L7
	add t4, fp, -4
	mov ea, t4
	lde u16t, t3, 0
	srl t3, t3, 3
	and t3, t3, 31
	mov t4, 2
	cmp neq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L7:
	mov t0, t1
	cmp neq, t0, zr
	jtr __L6
	add t3, fp, -4
	mov ea, t3
	lde i16t, t2, 2
	and t2, t2, 15
	sll t2, t2, 28
	sar t2, t2, 28
	mov t4, 2
	neg t3, t4
	cmp neq, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L6:
	cmp eq, t0, zr
	jtr __L4
	mov t0, 1
	mov a0, t0
	add sp, 8
	ret
__L4:
__L5:
	mov t1, 5
	add t2, fp, -4
	mov ea, t2
	lde u16t, t3, 0
	mov t4, t1
	and t4, t4, 7
	and t3, t3, -8
	orr t3, t3, t4
	ste u16t, 0, t3
	mov t0, t1
	mov t1, 17
	mov ea, fp
	lde u32t, t2, -8
	mov ea, t2
	lde u16t, t3, 0
	mov t4, t1
	and t4, t4, 31
	sll t4, t4, 3
	and t3, t3, -249
	orr t3, t3, t4
	ste u16t, 0, t3
	mov t0, t1
	mov t2, 3
	neg t1, t2
	add t2, fp, -4
	mov ea, t2
	lde i16t, t3, 2
	mov t4, t1
	and t4, t4, 15
	and t3, t3, -16
	orr t3, t3, t4
	ste i16t, 2, t3
	mov t0, t1
	mov t5, 4
	mov t6, 4
	cmp eq, t5, t6
	sel t4, 1, 0
	mov t3, t4
	cmp neq, t3, zr
	jfs __L12
	add t6, fp, -4
	mov ea, t6
	lde u16t, t5, 0
	and t5, t5, 7
	mov t6, 5
	cmp eq, t5, t6
	sel t4, 1, 0
	cmp neq, t4, zr
	sel t3, 1, 0
__L12:
	mov t2, t3
	cmp neq, t2, zr
	jfs __L11
	add t5, fp, -4
	mov ea, t5
	lde u16t, t4, 0
	srl t4, t4, 3
	and t4, t4, 31
	mov t5, 17
	cmp eq, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L11:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L10
	add t4, fp, -4
	mov ea, t4
	lde i16t, t3, 2
	and t3, t3, 15
	sll t3, t3, 28
	sar t3, t3, 28
	mov t5, 3
	neg t4, t5
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L10:
	cmp neq, t1, zr
	jfs __L8
	mov t1, 0
	mov t0, t1
	jmp __L9
__L8:
	mov t1, 1
	mov t0, t1
__L9:
	mov a0, t0
	add sp, 8
	ret

g__global_flags:
	emb u16t 50
	emb i16t 15
