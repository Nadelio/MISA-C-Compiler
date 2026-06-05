_start:
	cal main_
	exit

fib_:
	sub sp, 4
	add t14, fp, -4
	mov ea, t14
	ste i32t, 0, a0
	add t14, fp, -4
	mov ea, t14
	lde i32t, t1, 0
	mov t2, 1
	cmp lte, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	add t14, fp, -4
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	add sp, 4
	ret
__L0:
__L1:
	psh t0
	add t14, fp, -4
	mov ea, t14
	lde i32t, t2, 0
	mov t3, 1
	sub t0, t2, t3
	mov a0, t0
	cal fib_
	mov t1, a0
	pop t0
	psh t0
	psh t1
	add t14, fp, -4
	mov ea, t14
	lde i32t, t1, 0
	mov t3, 2
	sub t0, t1, t3
	mov a0, t0
	cal fib_
	mov t2, a0
	pop t1
	pop t0
	add t0, t1, t2
	mov a0, t0
	add sp, 4
	ret

main_:
	sub sp, 8
	mov t1, 0
	str i32t, g__g_count, t1
	mov t0, t1
	mov t1, 0
	add t14, fp, -4
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
__L2:
	add t14, fp, -4
	mov ea, t14
	lde i32t, t1, 0
	mov t2, 8
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L4
	psh t0
	add t14, fp, -4
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	cal fib_
	mov t1, a0
	pop t0
	add t14, fp, -8
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	lod i32t, t2, g__g_count
	mov t3, 1
	add t1, t2, t3
	str i32t, g__g_count, t1
	mov t0, t1
__L3:
	add t14, fp, -4
	mov ea, t14
	lde i32t, t2, 0
	mov t3, 1
	add t1, t2, t3
	add t14, fp, -4
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	jmp __L2
__L4:
	add t14, fp, -8
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	add sp, 8
	ret

g__g_count:	res i32t 1, 0
