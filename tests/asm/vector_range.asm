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
	sub sp, 36
	mov t0, 1.0
	add t1, fp, -12
	mov ea, t1
	ste f32t, 0, t0
	mov t0, 2.0
	add t1, fp, -8
	mov ea, t1
	ste f32t, 0, t0
	mov t0, 3.0
	add t1, fp, -4
	mov ea, t1
	ste f32t, 0, t0
	mov t0, zr
	mov t0, 4.0
	add t1, fp, -24
	mov ea, t1
	ste f32t, 0, t0
	mov t0, 5.0
	add t1, fp, -20
	mov ea, t1
	ste f32t, 0, t0
	mov t0, 6.0
	add t1, fp, -16
	mov ea, t1
	ste f32t, 0, t0
	mov t0, zr
	add t7, fp, -12
	mov t8, 0
	mul t8, 4
	add t7, t8
	mov t6, t7
	mov ea, t6
	lde f32t, t0, 0
	lde f32t, t1, 4
	lde f32t, t2, 8
	add t7, fp, -24
	mov t8, 0
	mul t8, 4
	add t7, t8
	mov t6, t7
	mov ea, t6
	lde f32t, t3, 0
	lde f32t, t4, 4
	lde f32t, t5, 8
	vfadd t0..t2, t0.., t3..
	add t7, fp, -36
	mov t8, 0
	mul t8, 4
	add t7, t8
	mov t6, t7
	mov ea, t6
	ste f32t, 0, t0
	ste f32t, 4, t1
	ste f32t, 8, t2
	add t2, fp, -36
	mov t3, 0
	mul t3, 4
	add t2, t3
	mov ea, t2
	lde f32t, t1, 0
	mov t2, 2
	mov a1, t2
	mov a0, t1
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	add t2, fp, -36
	mov t3, 1
	mul t3, 4
	add t2, t3
	mov ea, t2
	lde f32t, t1, 0
	mov t2, 2
	mov a1, t2
	mov a0, t1
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	add t2, fp, -36
	mov t3, 2
	mul t3, 4
	add t2, t3
	mov ea, t2
	lde f32t, t1, 0
	mov t2, 2
	mov a1, t2
	mov a0, t1
	syscall SYS_PRINT_LINE_FLOAT
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 36
	ret

