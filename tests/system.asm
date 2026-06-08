_start:
	cal main_
	exit

main_:
	yield
	mov t0, a0
	break
	mov t0, a0
	exit
	mov t0, a0
	mov t0, 0
	mov a0, t0
	ret

