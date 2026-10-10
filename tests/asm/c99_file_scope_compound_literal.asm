bmk "TOP"
_start:
	tpa t0, __compound_static_0
	str u32t, g__pair, t0
	tpa t0, __compound_static_1
	str u32t, g__values, t0
	cal main_
	exit

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	lod u32t, t5, g__pair
	mov ea, t5
	lde i16t, t4, 0
	mov t5, 4
	cmp eq, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L5
	lod u32t, t5, g__pair
	mov ea, t5
	lde i16t, t4, 2
	mov t5, 8
	cmp eq, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L5:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L4
	lod u32t, t4, g__values
	mov t5, 2
	mul t5, 2
	add t4, t5
	mov ea, t4
	lde i16t, t3, 0
	mov t4, 7
	cmp eq, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L4:
	cmp neq, t1, zr
	jfs __L2
	mov t1, 0
	mov t0, t1
	jmp __L3
__L2:
	mov t1, 1
	mov t0, t1
__L3:
	mov a0, t0
	ret
__compound_static_0:
	emb i16t 4
	emb i16t 8
__compound_static_1:
	emb i16t 3
	emb i16t 5
	emb i16t 7

g__pair:	res u32t 1, 0
g__values:	res u32t 1, 0
