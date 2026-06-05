_start:
	cal main_
	exit

add_:
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
	add t0, t1, t2
	mov a0, t0
	add sp, 8
	ret

main_:
	sub sp, 12
	mov t1, 10
	add t14, fp, -4
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	mov t1, 32
	add t14, fp, -8
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	psh t0
	add t14, fp, -4
	mov ea, t14
	lde i32t, t0, 0
	add t14, fp, -8
	mov ea, t14
	lde i32t, t2, 0
	mov a1, t2
	mov a0, t0
	cal add_
	mov t1, a0
	pop t0
	add t14, fp, -12
	mov ea, t14
	ste i32t, 0, t1
	mov t0, t1
	add t14, fp, -12
	mov ea, t14
	lde i32t, t0, 0
	mov a0, t0
	add sp, 12
	ret

