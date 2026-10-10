bmk "TOP"
_start:
	cal main_
	exit

main_:
	mov t0, 0
	mov a0, t0
	ret

g__duplicate:	emb i16t 1
g__incompatible:	res i16t 1, 0
g__linkage:	res i16t 1, 0
