# sprintf / snprintf
#
# sprintf(buf, fmt, ...)   a0=buf(abs), a1=fmt(abs), a2..a9=varargs
# snprintf(buf, n, fmt, .) a0=buf(abs), a1=n,        a2=fmt,  a3..a9=varargs
#
# Returns number of characters written (excluding null terminator).

_sprintf_state:
    .buf:     emb u32t 0    # absolute output buffer pointer
    .pos:     emb u32t 0    # current write position
    .limit:   emb u32t 0    # max chars to write (0 = unlimited)
    .int_buf: res u8t 12    # temp for int/hex digit reversal

# Write byte in t0 to buf[pos], respecting limit
_sprintf_putc:
    lod u32t, t1, _sprintf_state.pos
    lod u32t, t2, _sprintf_state.limit
    cmp eq, t2, 0
    jtr @write+
    cmp gte, t1, t2
    jtr @done+
    @write:
    lod u32t, t2, _sprintf_state.buf
    add t2, t1
    mov ea, t2
    ste u8t, 0, t0
    inc t1
    str u32t, _sprintf_state.pos, t1
    @done:
    ret

# Write null-terminated C string from absolute address a0
_sprintf_puts:
    vpsh s0
    mov s0, a0
    @loop:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        cal _sprintf_putc
        inc s0
        jmp @loop-
    @done:
    vpop s0
    ret

# Write signed integer a0
_sprintf_puti:
    vpsh s0..s2
    mov s0, a0
    cmp gte, s0, 0
    jtr @positive+
    mov t0, 45
    cal _sprintf_putc
    neg s0
    @positive:
    cmp neq, s0, 0
    jtr @nonzero+
    mov t0, 48
    cal _sprintf_putc
    jmp @done+
    @nonzero:
    mov s1, _sprintf_state.int_buf + 11
    str u8t, s1, 0
    dec s1
    mov s2, 0
    @digits:
        rem t0, s0, 10
        add t0, 48
        str u8t, s1, t0
        div s0, 10
        dec s1
        inc s2
        cmp neq, s0, 0
        jtr @digits-
    inc s1
    @copy:
        cmp eq, s2, 0
        jtr @done+
        lod u8t, t0, s1
        cal _sprintf_putc
        inc s1
        dec s2
        jmp @copy-
    @done:
    vpop s0..s2
    ret

# Write unsigned integer a0
_sprintf_putu:
    vpsh s0..s2
    mov s0, a0
    cmp neq, s0, 0
    jtr @nonzero+
    mov t0, 48
    cal _sprintf_putc
    jmp @done+
    @nonzero:
    mov s1, _sprintf_state.int_buf + 11
    str u8t, s1, 0
    dec s1
    mov s2, 0
    @digits:
        remu t0, s0, 10
        add t0, 48
        str u8t, s1, t0
        divu s0, 10
        dec s1
        inc s2
        cmp neq, s0, 0
        jtr @digits-
    inc s1
    @copy:
        cmp eq, s2, 0
        jtr @done+
        lod u8t, t0, s1
        cal _sprintf_putc
        inc s1
        dec s2
        jmp @copy-
    @done:
    vpop s0..s2
    ret

# Write unsigned integer a0 as lowercase hex
_sprintf_putx:
    vpsh s0..s2
    mov s0, a0
    cmp neq, s0, 0
    jtr @nonzero+
    mov t0, 48
    cal _sprintf_putc
    jmp @done+
    @nonzero:
    mov s1, _sprintf_state.int_buf + 11
    str u8t, s1, 0
    dec s1
    mov s2, 0
    @digits:
        remu t0, s0, 16
        cmp lt, t0, 10
        jtr @is_dec+
        add t0, 87      # 'a' - 10
        jmp @store+
        @is_dec:
        add t0, 48
        @store:
        str u8t, s1, t0
        divu s0, 16
        dec s1
        inc s2
        cmp neq, s0, 0
        jtr @digits-
    inc s1
    @copy:
        cmp eq, s2, 0
        jtr @done+
        lod u8t, t0, s1
        cal _sprintf_putc
        inc s1
        dec s2
        jmp @copy-
    @done:
    vpop s0..s2
    ret

# Write float a0 (6 decimal places)
_sprintf_putf:
    vpsh s0..s3
    mov s0, a0
    cmp flt, s0, 0.0
    jfs @positive+
    mov t0, 45
    cal _sprintf_putc
    fneg s0
    @positive:
    fcti s1, s0             # s1 = integer part (int)
    mov a0, s1
    cal _sprintf_puti
    mov t0, 46              # '.'
    cal _sprintf_putc
    fctf s2, s1             # s2 = integer part (float)
    fsub s3, s0, s2         # s3 = fractional part
    mov s0, 6
    @frac_loop:
        cmp eq, s0, 0
        jtr @done+
        fmul s3, 10.0
        fcti s2, s3
        add t0, s2, 48
        cal _sprintf_putc
        fctf s1, s2
        fsub s3, s1
        dec s0
        jmp @frac_loop-
    @done:
    vpop s0..s3
    ret

_sprintf_loop:
    @loop:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        cmp eq, t0, 37      # '%'
        jtr @fmt+
        cal _sprintf_putc
        inc s0
        jmp @loop-
    @fmt:
        inc s0
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 100     # 'd'
        jtr @do_d+
        cmp eq, t0, 105     # 'i'
        jtr @do_d+
        cmp eq, t0, 117     # 'u'
        jtr @do_u+
        cmp eq, t0, 115     # 's'
        jtr @do_s+
        cmp eq, t0, 102     # 'f'
        jtr @do_f+
        cmp eq, t0, 99      # 'c'
        jtr @do_c+
        cmp eq, t0, 120     # 'x'
        jtr @do_x+
        cmp eq, t0, 37      # '%'
        jtr @do_pct+
        mov t0, 37
        cal _sprintf_putc
        jmp @adv+
    @do_d:
        mov ea, s1
        lde i32t, a0, 0
        add s1, 4
        cal _sprintf_puti
        jmp @adv+
    @do_u:
        mov ea, s1
        lde u32t, a0, 0
        add s1, 4
        cal _sprintf_putu
        jmp @adv+
    @do_s:
        mov ea, s1
        lde u32t, a0, 0
        add s1, 4
        cal _sprintf_puts
        jmp @adv+
    @do_f:
        mov ea, s1
        lde f32t, a0, 0
        add s1, 4
        cal _sprintf_putf
        jmp @adv+
    @do_c:
        mov ea, s1
        lde u8t, t0, 0
        add s1, 4
        cal _sprintf_putc
        jmp @adv+
    @do_x:
        mov ea, s1
        lde u32t, a0, 0
        add s1, 4
        cal _sprintf_putx
        jmp @adv+
    @do_pct:
        mov t0, 37
        cal _sprintf_putc
    @adv:
        inc s0
        jmp @loop-
    @done:
    ret

sprintf:
    vpsh s0..s1
    sub sp, 32
    mov ea, sp
    ste u32t, 0,  a2
    ste u32t, 4,  a3
    ste u32t, 8,  a4
    ste u32t, 12, a5
    ste u32t, 16, a6
    ste u32t, 20, a7
    ste u32t, 24, a8
    ste u32t, 28, a9

    str u32t, _sprintf_state.buf,   a0
    str u32t, _sprintf_state.pos,   0
    str u32t, _sprintf_state.limit, 0

    mov s0, a1
    mov s1, sp
    cal _sprintf_loop

    # null-terminate
    lod u32t, t0, _sprintf_state.buf
    lod u32t, t1, _sprintf_state.pos
    add t0, t1
    mov ea, t0
    ste u8t, 0, 0

    mov a0, t1
    add sp, 32
    vpop s0..s1
    ret

snprintf:
    vpsh s0..s1
    sub sp, 32
    mov ea, sp
    ste u32t, 0,  a3
    ste u32t, 4,  a4
    ste u32t, 8,  a5
    ste u32t, 12, a6
    ste u32t, 16, a7
    ste u32t, 20, a8
    ste u32t, 24, a9
    ste u32t, 28, a10

    str u32t, _sprintf_state.buf, a0
    str u32t, _sprintf_state.pos, 0

    # limit = n > 0 ? n - 1 : 0  (reserve one byte for null terminator)
    cmp gt, a1, 0
    jfs @zero_lim+
    sub t0, a1, 1
    str u32t, _sprintf_state.limit, t0
    jmp @do_fmt+
    @zero_lim:
    str u32t, _sprintf_state.limit, 0
    @do_fmt:

    mov s0, a2
    mov s1, sp
    cal _sprintf_loop

    # always null-terminate at buf[min(pos, n-1)]
    lod u32t, t0, _sprintf_state.buf
    lod u32t, t1, _sprintf_state.pos
    cmp gt, a1, 0
    jfs @write_null+
    sub t2, a1, 1
    cmp lt, t1, t2
    jtr @write_null+
    mov t1, t2
    @write_null:
    add t0, t1
    mov ea, t0
    ste u8t, 0, 0

    lod u32t, a0, _sprintf_state.pos
    add sp, 32
    vpop s0..s1
    ret

# _get_file_size(name): u32t | cast(-1)
# Returns size in bytes of a named MFS file, or -1 if not found.
# > a0: filename (C absolute pointer, tpr'd here)
_get_file_size:
    tpr a0
    cal MFS_INTERNAL.dirent_find
    cmp eq, a0, 0
    jtr @not_found+
    cea a0, 0, 1
    lde u32t, a0, MFS_DIRENT_FILE_SIZE
    ret
    @not_found:
    mov a0, -1
    ret
