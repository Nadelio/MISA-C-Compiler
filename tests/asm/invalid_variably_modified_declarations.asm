bmk "TOP"
_start:
	cal main_
	exit

main_:
	sub sp, 12
	mov t0, 3
	mov ea, fp
	ste i16t, -4, t0
	mov ea, fp
	lde i16t, t0, -4
	mul t0, 2
	add t0, t0, 3
	and t0, t0, -4
	sub sp, t0
	mov ea, fp
	ste u32t, -12, sp
	ste u32t, -8, t0
	mov ea, fp
	lde i16t, t0, -4
	mul t0, 2
	add t0, t0, 3
	and t0, t0, -4
	sub sp, t0
	mov ea, fp
	ste u32t, 0, sp
	ste u32t, 4, t0
	mov t0, 0
	mov a0, t0
	mov sp, fp
	ret

g__bound:	res i16t 1, 0
