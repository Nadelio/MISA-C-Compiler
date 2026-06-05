_start:
	cal main_
	exit

max_:
	sub sp, 8
	add t14, fp, -4
	mov ea, t14
	ste i32t, 0, a0
	add t14, fp, -8
	mov ea, t14
	ste i32t, 0, a1
	add t14, fp, -4
	mov ea, t14
	lde i32t, t1, 0
	add t14, fp, -8
	mov ea, t14
	lde i32t, t2, 0
	cmp gt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	add t14, fp, -4
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	add sp, 8
	ret
__L0:
__L1:
	add t14, fp, -8
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	add sp, 8
	ret

sum_array_:
	sub sp, 16
	add t14, fp, -4
	mov ea, t14
	ste u32t, 0, a0
	add t14, fp, -8
	mov ea, t14
	ste i32t, 0, a1
	mov t1, 0
	add t14, fp, -16
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	mov t1, 0
	add t14, fp, -12
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
__L2:
	add t14, fp, -12
	mov ea, t14
	lde i32t, t1, 0
	add t14, fp, -8
	mov ea, t14
	lde i32t, t2, 0
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L4
	add t14, fp, -16
	mov ea, t14
	lde i32t, t2, 0
	add t14, fp, -4
	mov ea, t14
	lde u32t, t4, 0
	add t14, fp, -12
	mov ea, t14
	lde i32t, t5, 0
	mul t5, 4
	add t4, t5
	mov ea, t4
	lde i32t, t3, 0
	add t1, t2, t3
	add t14, fp, -16
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
__L3:
	add t14, fp, -12
	mov ea, t14
	lde i32t, t2, 0
	mov t3, 1
	add t1, t2, t3
	add t14, fp, -12
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	jmp __L2
__L4:
	add t14, fp, -16
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	add sp, 16
	ret

main_:
	sub sp, 20
	tpa t1, __str_5
	str u32t, g__greeting, t1
	mov t0, t1
	mov t1, 1
	add t2, fp, -16
	mov t3, 0
	mul t3, 4
	add t2, t3
	mov ea, t2
	ste i32t, 0, t1
	mov t0, t1
	mov t1, 2
	add t2, fp, -16
	mov t3, 1
	mul t3, 4
	add t2, t3
	mov ea, t2
	ste i32t, 0, t1
	mov t0, t1
	mov t1, 3
	add t2, fp, -16
	mov t3, 2
	mul t3, 4
	add t2, t3
	mov ea, t2
	ste i32t, 0, t1
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
	add t14, fp, -20
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	add t14, fp, -20
	mov ea, t14
	lde i32t, t1, 0
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
__str_5:	emb string "hello"
