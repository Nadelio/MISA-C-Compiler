bmk "TOP"
_start:
	cal main_
	exit

sbmk "_keyboard_input(): void"
##
## Parameters: NONE
## Returns: NONE
## Additional Implementation Notes:
_keyboard_input:
	psh t0
	syscall SYS_GET_KEYBOARD_INPUT
	mov t1, a0
	pop t0
	str i16t, g__input, t1
	mov t0, t1
	lod i16t, t1, g__input
	mov t2, 131
	cmp eq, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	tpa t1, __str_2
	mov a0, t1
	tpr a0
	syscall SYS_PRINT_LINE_STRING
	mov t0, a0
__L0:
__L1:
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

g__input:	emb i16t 0
__str_2:	emb string "ESCAPED!"
