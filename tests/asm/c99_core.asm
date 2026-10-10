bmk "TOP"
_start:
	cal main_
	exit

sbmk "has_data_(data: i8t*): u8t"
##
## Parameters:
## > a0 - data, is i8t*
## Returns:
## < a0 - return value, is u8t
## Additional Implementation Notes:
has_data_:
	sub sp, 4
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	lde u32t, t1, -4
	mov t2, 0
	cmp neq, t1, t2
	sel t0, 1, 0
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
	sub sp, 12
	mov t0, 0
	mov ea, fp
	ste i32t, -4, t0
	mov t0, 3.0
	mov ea, fp
	ste f32t, -8, t0
	mov t0, 32
	mov ea, fp
	ste u32t, -12, t0
	psh t0
	psh t1
	tpa t0, __str_0
	mov a0, t0
	cal has_data_
	mov t2, a0
	pop t1
	pop t0
	mov ea, fp
	lde u32t, t4, -12
	mov t5, 32
	cmp eq, t4, t5
	sel t3, 1, 0
	add t1, t2, t3
	mov ea, fp
	lde i32t, t2, -4
	add t3, t2, t1
	mov ea, fp
	ste i32t, -4, t3
	mov t0, t3
	mov ea, fp
	lde i32t, t3, -4
	mov t4, 2
	cmp eq, t3, t4
	sel t2, 1, 0
	mov t1, t2
	cmp neq, t1, zr
	jfs __L3
	mov ea, fp
	lde f32t, t3, -8
	mov t4, 3.0
	cmp feqa, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L3:
	cmp neq, t1, zr
	jfs __L1
	mov t1, 0
	mov t0, t1
	jmp __L2
__L1:
	mov t1, 1
	mov t0, t1
__L2:
	mov a0, t0
	add sp, 12
	ret

__str_0:	emb string "main"
