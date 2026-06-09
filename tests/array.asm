_start:
	cal main_
	exit

sbmk "max_(a: i32t, b: i32t): i32t"
##
## Parameters:
## > a0 - a, is i32t
## > a1 - b, is i32t
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
max_:
	sub sp, 8
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	ste i32t, -8, a1
	mov ea, fp
	lde i32t, t1, -4
	mov ea, fp
	lde i32t, t2, -8
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	mov ea, fp
	lde i32t, t0, -4
	mov a0, t0
	add sp, 8
	ret
__L0:
__L1:
	mov ea, fp
	lde i32t, t0, -8
	mov a0, t0
	add sp, 8
	ret

sbmk "sum_array_(arr: i32t*, n: i32t): i32t"
##
## Parameters:
## > a0 - arr, is i32t*
## > a1 - n, is i32t
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
sum_array_:
	sub sp, 16
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste i32t, -8, a1
	mov t1, 0
	mov ea, fp
	ste i32t, -16, t1
	mov t0, t1
	mov t1, 0
	mov ea, fp
	ste i32t, -12, t1
	mov t0, t1
__L2:
	mov ea, fp
	lde i32t, t1, -12
	mov ea, fp
	lde i32t, t2, -8
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L4
	mov ea, fp
	lde i32t, t2, -16
	mov ea, fp
	lde u32t, t4, -4
	mov ea, fp
	lde i32t, t5, -12
	mul t5, 4
	add t4, t5
	mov ea, t4
	lde i32t, t3, 0
	add t1, t2, t3
	mov ea, fp
	ste i32t, -16, t1
	mov t0, t1
__L3:
	mov ea, fp
	lde i32t, t2, -12
	mov t3, 1
	add t1, t2, t3
	mov ea, fp
	ste i32t, -12, t1
	mov t0, t1
	jmp __L2
__L4:
	mov ea, fp
	lde i32t, t0, -16
	mov a0, t0
	add sp, 16
	ret

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
main_:
	sub sp, 20
	mov t0, 1
	add t1, fp, -16
	mov ea, t1
	ste i32t, 0, t0
	mov t0, 2
	add t1, fp, -12
	mov ea, t1
	ste i32t, 0, t0
	mov t0, 3
	add t1, fp, -8
	mov ea, t1
	ste i32t, 0, t0
	mov t0, 3
	add t1, fp, -4
	mov ea, t1
	ste i32t, 0, t0
	tpa t1, __str_5
	str u32t, g__greeting, t1
	mov t0, t1
	mov t1, 4
	add t2, fp, -16
	mov t3, 3
	mul t3, 4
	add t2, t3
	mov ea, t2
	ste i32t, 0, t1
	mov t0, t1
	psh t0
	add t0, fp, -16
	mov t2, 4
	mov a1, t2
	mov a0, t0
	cal sum_array_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -20, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t1, -20
	lod i32t, t2, g__global_x
	mov a1, t2
	mov a0, t1
	cal max_
	mov t0, a0
	mov a0, t0
	add sp, 20
	ret

g__global_x:	emb i32t 100
g__greeting:	res u32t 1, 0
g__foo:	emb i8t 0, 1
__str_5:	emb string "hello"
