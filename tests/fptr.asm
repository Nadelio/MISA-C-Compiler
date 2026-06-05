_start:
	cal main_
	exit

main_:
	sub sp, 4
	mov t1, 6
	tpa t2, g____code
	mov t3, 0
	add t2, t3
	mov ea, t2
	ste u8t, 0, t1
	mov t0, t1
	mov t1, 0
	tpa t2, g____code
	mov t3, 1
	add t2, t3
	mov ea, t2
	ste u8t, 0, t1
	mov t0, t1
	mov t1, 0
	tpa t2, g____code
	mov t3, 2
	add t2, t3
	mov ea, t2
	ste u8t, 0, t1
	mov t0, t1
	mov t1, 2
	tpa t2, g____code
	mov t3, 3
	add t2, t3
	mov ea, t2
	ste u8t, 0, t1
	mov t0, t1
	tpa t0, g____code
	add t14, fp, -4
	mov ea, t14
	ste u32t, 0, t0
	mov t1, 42
	mov a0, t1
	add t14, fp, -4
	mov ea, t14
	lde u32t, t1, 0
	tpr t1
	sub t1, @__ical+
@__ical:
	cal t1
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 4
	ret

g____code:	res u8t 4, 0
