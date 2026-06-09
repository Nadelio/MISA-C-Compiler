_start:
	cal main_
	exit

sbmk "main_(): i32t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i32t
## Additional Implementation Notes:
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
	mov ea, fp
	ste u32t, -4, t0
	mov t1, 42
	mov a0, t1
	mov ea, fp
	lde u32t, t1, -4
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
