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
	sub sp, 8
	mov t0, 1
	mov ea, fp
	ste i16t, -4, t0
	mov ea, fp
	lde i16t, t1, -4
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -4, t1
	mov ea, fp
	lde i16t, t0, -4
	mov ea, fp
	ste i16t, -8, t0
	mov ea, fp
	lde i16t, t1, -8
	mov t0, t1
	mov a0, 0
	add sp, 8
	ret

