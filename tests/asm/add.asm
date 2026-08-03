_start:
	cal main_
	exit

add_:
	sub sp, 8
	mov ea, fp
	ste i32t, -4, a0
	mov ea, fp
	ste i32t, -8, a1
	mov ea, fp
	lde i32t, t1, -4
	mov ea, fp
	lde i32t, t2, -8
	add t0, t1, t2
	mov a0, t0
	add sp, 8
	ret

main_:
	sub sp, 12
	mov t1, 10
	mov ea, fp
	ste i32t, -4, t1
	mov t0, t1
	mov t1, 32
	mov ea, fp
	ste i32t, -8, t1
	mov t0, t1
	psh t0
	mov ea, fp
	lde i32t, t0, -4
	mov ea, fp
	lde i32t, t2, -8
	mov a1, t2
	mov a0, t0
	cal add_
	mov t1, a0
	pop t0
	mov ea, fp
	ste i32t, -12, t1
	mov t0, t1
	mov ea, fp
	lde i32t, t0, -12
	mov a0, t0
	add sp, 12
	ret

