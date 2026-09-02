bmk "TOP"
_start:
	cal main_
	exit

sbmk "draw_digit_(d: i16t, x: i16t, y: i16t): void"
##
## Parameters:
## > a0 - d, is i16t
## > a1 - x, is i16t
## > a2 - y, is i16t
## Returns: NONE
## Additional Implementation Notes:
draw_digit_:
	sub sp, 24
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste i16t, -8, a1
	mov ea, fp
	ste i16t, -12, a2
	mov t1, 0
	mov ea, fp
	ste i16t, -16, t1
	mov t0, t1
__L0:
	mov ea, fp
	lde i16t, t1, -16
	mov t2, 5
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L2
	tpa t1, g__font
	mov ea, fp
	lde i16t, t4, -4
	mov t5, 5
	mul t3, t4, t5
	mov ea, fp
	lde i16t, t4, -16
	add t2, t3, t4
	add t1, t2
	mov ea, t1
	lde u8t, t0, 0
	sbx t0, t0, 0, 16
	mov ea, fp
	ste i16t, -24, t0
	mov t1, 0
	mov ea, fp
	ste i16t, -20, t1
	mov t0, t1
__L3:
	mov ea, fp
	lde i16t, t1, -20
	mov t2, 3
	cmp lt, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L5
	mov ea, fp
	lde i16t, t1, -24
	mov t3, 4
	mov ea, fp
	lde i16t, t4, -20
	sar t2, t3, t4
	and t0, t1, t2
	cmp eq, t0, zr
	jtr __L6
	mov ea, fp
	lde i16t, t2, -8
	mov ea, fp
	lde i16t, t4, -20
	mov t6, 3
	mov t7, 1
	add t5, t6, t7
	mul t3, t4, t5
	add t1, t2, t3
	mov ea, fp
	lde i16t, t3, -12
	mov ea, fp
	lde i16t, t5, -16
	mov t7, 3
	mov t8, 1
	add t6, t7, t8
	mul t4, t5, t6
	add t2, t3, t4
	mov t3, 3
	mov t4, 3
	mov t5, 255
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
__L6:
__L7:
__L4:
	mov ea, fp
	lde i16t, t1, -20
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -20, t1
	jmp __L3
__L5:
__L1:
	mov ea, fp
	lde i16t, t1, -16
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -16, t1
	jmp __L0
__L2:
	add sp, 24
	ret

sbmk "draw_number_(n: i16t, cx: i16t, top_y: i16t): void"
##
## Parameters:
## > a0 - n, is i16t
## > a1 - cx, is i16t
## > a2 - top_y, is i16t
## Returns: NONE
## Additional Implementation Notes:
draw_number_:
	sub sp, 56
	mov ea, fp
	ste i16t, -4, a0
	mov ea, fp
	ste i16t, -8, a1
	mov ea, fp
	ste i16t, -12, a2
	mov t0, 0
	mov ea, fp
	ste i16t, -32, t0
	mov ea, fp
	lde i16t, t1, -4
	mov t2, 0
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L8
	mov t1, 0
	add t2, fp, -28
	mov t3, 0
	mul t3, 2
	add t2, t3
	mov ea, t2
	ste i16t, 0, t1
	mov t0, t1
	mov t1, 1
	mov ea, fp
	ste i16t, -32, t1
	mov t0, t1
	jmp __L9
__L8:
	mov ea, fp
	lde i16t, t1, -4
	mov ea, fp
	ste i16t, -36, t1
	mov t0, t1
__L10:
	mov ea, fp
	lde i16t, t2, -36
	mov t3, 0
	cmp gt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jfs __L12
	mov ea, fp
	lde i16t, t2, -32
	mov t3, 8
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L12:
	cmp neq, t0, zr
	jfs __L11
	mov ea, fp
	lde i16t, t2, -36
	mov t3, 10
	rem t1, t2, t3
	add t2, fp, -28
	mov ea, fp
	lde i16t, t3, -32
	mul t3, 2
	add t2, t3
	mov ea, t2
	ste i16t, 0, t1
	mov t0, t1
	mov ea, fp
	lde i16t, t1, -32
	mov t0, t1
	inc t1
	mov ea, fp
	ste i16t, -32, t1
	mov t1, 10
	mov ea, fp
	lde i16t, t2, -36
	div t3, t2, t1
	mov ea, fp
	ste i16t, -36, t3
	mov t0, t3
	jmp __L10
__L11:
__L9:
	mov t2, 3
	mov t3, 3
	mul t1, t2, t3
	mov t2, 2
	add t0, t1, t2
	mov ea, fp
	ste i16t, -40, t0
	mov ea, fp
	lde i16t, t1, -40
	mov t2, 2
	add t0, t1, t2
	mov ea, fp
	ste i16t, -44, t0
	mov ea, fp
	lde i16t, t3, -32
	mov t4, 1
	sub t2, t3, t4
	mov ea, fp
	lde i16t, t3, -44
	mul t1, t2, t3
	mov ea, fp
	lde i16t, t2, -40
	add t0, t1, t2
	mov ea, fp
	ste i16t, -48, t0
	mov ea, fp
	lde i16t, t1, -8
	mov ea, fp
	lde i16t, t3, -48
	mov t4, 2
	div t2, t3, t4
	sub t0, t1, t2
	mov ea, fp
	ste i16t, -52, t0
	mov ea, fp
	lde i16t, t2, -32
	mov t3, 1
	sub t1, t2, t3
	mov ea, fp
	ste i16t, -56, t1
	mov t0, t1
__L13:
	mov ea, fp
	lde i16t, t1, -56
	mov t2, 0
	cmp gte, t1, t2
	sel t0, 1, 0
	cmp neq, t0, zr
	jfs __L15
	add t2, fp, -28
	mov ea, fp
	lde i16t, t3, -56
	mul t3, 2
	add t2, t3
	mov ea, t2
	lde i16t, t1, 0
	mov ea, fp
	lde i16t, t3, -52
	mov ea, fp
	lde i16t, t7, -32
	mov t8, 1
	sub t6, t7, t8
	mov ea, fp
	lde i16t, t7, -56
	sub t5, t6, t7
	mov ea, fp
	lde i16t, t6, -44
	mul t4, t5, t6
	add t2, t3, t4
	mov ea, fp
	lde i16t, t3, -12
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_digit_
	mov t0, a0
__L14:
	mov ea, fp
	lde i16t, t1, -56
	mov t0, t1
	dec t1
	mov ea, fp
	ste i16t, -56, t1
	jmp __L13
__L15:
	add sp, 56
	ret

sbmk "draw_impl_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
draw_impl_:
	sub sp, 16
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a1
	mov ea, fp
	ste i16t, -8, t0
	mov ea, fp
	lde i16t, t4, -4
	mov t5, 2
	cmp gte, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L18
	mov ea, fp
	lde i16t, t4, -4
	mov t6, 2
	mov t7, 120
	add t5, t6, t7
	cmp lt, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L18:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L17
	mov ea, fp
	lde i16t, t3, -8
	mov t4, 1
	cmp gte, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L17:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L16
	mov ea, fp
	lde i16t, t2, -8
	mov t4, 1
	mov t5, 60
	add t3, t4, t5
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L16:
	mov ea, fp
	ste i16t, -12, t0
	mov t1, 0
	mov t2, 0
	mov t3, 320
	mov t4, 240
	mov t5, 16
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 2
	mov t2, 1
	mov t3, 120
	mov t4, 60
	mov ea, fp
	lde i16t, t6, -12
	cmp neq, t6, zr
	jfs __L19
	mov t6, 120
	mov t5, t6
	jmp __L20
__L19:
	mov t6, 70
	mov t5, t6
__L20:
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 2
	mov t2, 1
	mov t3, 120
	mov t4, 2
	mov t5, 220
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 2
	mov t4, 1
	mov t5, 60
	add t3, t4, t5
	mov t4, 2
	sub t2, t3, t4
	mov t3, 120
	mov t4, 2
	mov t5, 220
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t1, 2
	mov t2, 1
	mov t3, 2
	mov t4, 60
	mov t5, 220
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t3, 2
	mov t4, 120
	add t2, t3, t4
	mov t3, 2
	sub t1, t2, t3
	mov t2, 1
	mov t3, 2
	mov t4, 60
	mov t5, 220
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	mov t2, 5
	mov t3, 3
	mul t1, t2, t3
	mov t2, 4
	add t0, t1, t2
	mov ea, fp
	ste i16t, -16, t0
	lod i16t, t1, g__counter
	mov t3, 2
	mov t5, 120
	mov t6, 2
	div t4, t5, t6
	add t2, t3, t4
	mov t4, 1
	mov t7, 60
	mov ea, fp
	lde i16t, t8, -16
	sub t6, t7, t8
	mov t7, 2
	div t5, t6, t7
	add t3, t4, t5
	mov a2, t3
	mov a1, t2
	mov a0, t1
	cal draw_number_
	mov t0, a0
	add sp, 16
	ret

sbmk "mouse_btn_impl_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
mouse_btn_impl_:
	sub sp, 12
	syscall SYS_GET_MOUSE_BUTTON_INPUT
	mov t0, a0
	mov ea, fp
	ste i16t, -4, t0
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a0
	mov ea, fp
	ste i16t, -8, t0
	syscall SYS_GET_MOUSE_POSITION
	mov t0, a1
	mov ea, fp
	ste i16t, -12, t0
	mov ea, fp
	lde i16t, t2, -4
	mov t3, 1
	and t1, t2, t3
	mov t0, t1
	cmp neq, t0, zr
	jfs __L23
	lod i16t, t3, g__prev_btn
	mov t4, 1
	and t2, t3, t4
	cmp eq, t2, zr
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L23:
	cmp eq, t0, zr
	jtr __L21
	mov ea, fp
	lde i16t, t4, -8
	mov t5, 2
	cmp gte, t4, t5
	sel t3, 1, 0
	mov t2, t3
	cmp neq, t2, zr
	jfs __L28
	mov ea, fp
	lde i16t, t4, -8
	mov t6, 2
	mov t7, 120
	add t5, t6, t7
	cmp lt, t4, t5
	sel t3, 1, 0
	cmp neq, t3, zr
	sel t2, 1, 0
__L28:
	mov t1, t2
	cmp neq, t1, zr
	jfs __L27
	mov ea, fp
	lde i16t, t3, -12
	mov t4, 1
	cmp gte, t3, t4
	sel t2, 1, 0
	cmp neq, t2, zr
	sel t1, 1, 0
__L27:
	mov t0, t1
	cmp neq, t0, zr
	jfs __L26
	mov ea, fp
	lde i16t, t2, -12
	mov t4, 1
	mov t5, 60
	add t3, t4, t5
	cmp lt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L26:
	cmp eq, t0, zr
	jtr __L24
	lod i16t, t1, g__counter
	mov t0, t1
	inc t1
	str i16t, g__counter, t1
__L24:
__L25:
__L21:
__L22:
	mov ea, fp
	lde i16t, t1, -4
	str i16t, g__prev_btn, t1
	mov t0, t1
	add sp, 12
	ret

sbmk "_draw(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_draw:
	cal draw_impl_
	mov t0, a0
	exit
	mov t0, a0
	ret

sbmk "_mouse_button_input(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_mouse_button_input:
	cal mouse_btn_impl_
	mov t0, a0
	exit
	mov t0, a0
	ret

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	mov t0, 0
	mov a0, t0
	ret

g__counter:	emb i16t 0
g__prev_btn:	emb i16t 0
g__font:	emb u8t 7, 5, 5, 5, 7, 2, 6, 2, 2, 7, 7, 1, 7, 4, 7, 7, 1, 7, 1, 7, 5, 5, 7, 1, 1, 7, 4, 7, 1, 7, 7, 4, 7, 5, 7, 7, 1, 1, 1, 1, 7, 5, 7, 5, 7, 7, 5, 7, 1, 7
