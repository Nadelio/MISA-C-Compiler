bmk "TOP"
_start:
	cal main_
	exit

sbmk "_draw(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_draw:
	mov t1, 0
	mov t2, 0
	mov t3, 10
	mov t4, 10
	mov t5, 255
	mov a4, t5
	mov a3, t4
	mov a2, t3
	mov a1, t2
	mov a0, t1
	syscall SYS_DRAW_RECT
	mov t0, a0
	ret

sbmk "_update(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_update:
	ret

sbmk "main_(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
main_:
	ret

