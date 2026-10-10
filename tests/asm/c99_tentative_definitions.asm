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
	lod i16t, t4, g__counter
	mov t5, 7
	cmp eq, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L3
	lod i16t, t4, total
	mov t5, 0
	cmp eq, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L3:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L2
	lod i16t, t3, internal_value
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
	ret

g__counter:	emb i16t 7
g__total:	res i16t 1, 0
g__internal_value:	res i16t 1, 0
