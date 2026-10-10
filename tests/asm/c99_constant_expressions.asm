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
	lod i16t, t0, g__global_value
	mov t14, t0
	cmp eq, t14, 13
	jtr __L2
	jmp __L1
__L2:
	tpa t3, g__values
	mov t4, 3
	mul t4, 2
	add t3, t4
	mov ea, t3
	lde i16t, t2, 0
	mov t3, 7
	cmp eq, t2, t3
	sel t1, 1, 0
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
	ret
__L1:
	mov t0, 2
	mov a0, t0
	ret
__L0:
	mov a0, 0
	ret

g__global_value:	emb i16t 13
g__values:
	res u8t 2, 0
	res u8t 2, 0
	res u8t 2, 0
	emb i16t 7
	res u8t 2, 0
