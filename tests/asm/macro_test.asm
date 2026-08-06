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
	mov t1, 3
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t2, 7
	mov t3, 7
	add t1, t2, t3
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t3, 3
	mov t4, 5
	cmp gt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L0
	mov t2, 3
	mov t1, t2
	jmp __L1
__L0:
	mov t2, 5
	mov t1, t2
__L1:
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t3, 3
	mov t4, 5
	cmp lt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L2
	mov t2, 3
	mov t1, t2
	jmp __L3
__L2:
	mov t2, 5
	mov t1, t2
__L3:
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t4, 9
	neg t3, t4
	mov t4, 0
	cmp lt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L4
	mov t4, 9
	neg t3, t4
	neg t2, t3
	mov t1, t2
	jmp __L5
__L4:
	mov t3, 9
	neg t2, t3
	mov t1, t2
__L5:
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t2, 6
	mov t3, 6
	mul t1, t2, t3
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t5, 15
	mov t6, 10
	cmp lt, t5, t6
	sel t4, 1, 0
	cmp neq, t4, zr
	jfs __L8
	mov t4, 15
	mov t3, t4
	jmp __L9
__L8:
	mov t4, 10
	mov t3, t4
__L9:
	mov t4, 0
	cmp gt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L6
	mov t4, 15
	mov t5, 10
	cmp lt, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	jfs __L10
	mov t3, 15
	mov t2, t3
	jmp __L11
__L10:
	mov t3, 10
	mov t2, t3
__L11:
	mov t1, t2
	jmp __L7
__L6:
	mov t2, 0
	mov t1, t2
__L7:
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t6, 5
	neg t5, t6
	mov t6, 10
	cmp lt, t5, t6
	sel t4, 1, 0
	cmp neq, t4, zr
	jfs __L14
	mov t5, 5
	neg t4, t5
	mov t3, t4
	jmp __L15
__L14:
	mov t4, 10
	mov t3, t4
__L15:
	mov t4, 0
	cmp gt, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	jfs __L12
	mov t5, 5
	neg t4, t5
	mov t5, 10
	cmp lt, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	jfs __L16
	mov t4, 5
	neg t3, t4
	mov t2, t3
	jmp __L17
__L16:
	mov t3, 10
	mov t2, t3
__L17:
	mov t1, t2
	jmp __L13
__L12:
	mov t2, 0
	mov t1, t2
__L13:
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t1, 3
	mov ea, fp
	ste i16t, -4, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t2, -4
	mov ea, fp
	lde i16t, t3, -4
	mul t1, t2, t3
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t1, 10
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t1, 20
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	tpa t1, __str_18
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_LINE_STRING
	mov t0, a0
	mov t1, 42
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t1, 99
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	mov t1, 77
	mov ea, fp
	ste i16t, -8, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -8
	mov a0, t1
	syscall SYS_PRINT_LINE_INT
	mov t0, a0
	tpa t1, __str_19
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_LINE_STRING
	mov t0, a0
	mov t0, 0
	mov a0, t0
	add sp, 8
	ret

__str_18:	emb string "v2"
__str_19:	emb string "hello"
