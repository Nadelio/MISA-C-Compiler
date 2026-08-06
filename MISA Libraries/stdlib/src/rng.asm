srand:
    syscall SYS_SET_RNG_SEED
    ret

rand:
    rnd a0, 0, 0x7FFF
    ret
