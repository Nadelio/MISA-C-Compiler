_start:
	cal main_
	exit

get_width_:
	cal foo.somefunc
	mov t0, a0
	lod i8t, t0, CELL_WIDTH
	mov a0, t0
	ret

main_:
	lod u32t, t1, player.x
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	lod u32t, t1, player.y
	mov a0, t1
	syscall SYS_PRINT_INT
	mov t0, a0
	mov t1, 10
	str u32t, player.y, t1
	mov t0, t1
	mov t1, 5
	str u32t, player2.y, t1
	mov t0, t1
	ret


CELL_WIDTH: emb i8t 6

player:
    .x: emb u32t 0
    .y: emb u32t 0
player2:
    .x: emb u32t 0
    .y: emb u32t 0
foo:
  .somefunc:
    ret