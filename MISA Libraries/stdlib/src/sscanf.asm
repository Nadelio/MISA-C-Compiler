# sscanf / scanf
#
# sscanf(str, fmt, ...)  a0=str(abs), a1=fmt(abs), a2..a9=output ptrs(abs)
# scanf(fmt, ...)        a0=fmt(abs), a1..a9=output ptrs(abs)
#
# Returns number of items successfully matched and assigned.
# Supports: %d %i %u %f %s %c %%

_sscanf_input_buf: res u8t 258   # terminal input buffer for scanf

# input: s0=str ptr(abs), s1=fmt ptr(abs), s2=out ptr stack(abs), s3=match count
_sscanf_loop:

    @loop:
        mov ea, s1
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+

        cmp eq, t0, 37  # '%'
        jtr @fmt+

        # whitespace in fmt: skip all whitespace in input
        cmp eq, t0, 32
        jtr @skip_ws+
        cmp eq, t0, 9
        jtr @skip_ws+
        cmp eq, t0, 10
        jtr @skip_ws+

        # literal character match
        mov ea, s0
        lde u8t, t1, 0
        cmp neq, t0, t1
        jtr @done+
        inc s0
        inc s1
        jmp @loop-

        @skip_ws:
        @ws_lp:
            mov ea, s0
            lde u8t, t1, 0
            cmp eq, t1, 32
            jtr @ws_adv+
            cmp eq, t1, 9
            jtr @ws_adv+
            cmp eq, t1, 10
            jtr @ws_adv+
            cmp eq, t1, 13
            jtr @ws_adv+
            jmp @ws_done+
            @ws_adv: inc s0
            jmp @ws_lp-
        @ws_done:
        inc s1
        jmp @loop-

    @fmt:
        inc s1
        mov ea, s1
        lde u8t, t0, 0
        cmp eq, t0, 100
        jtr @scan_d+
        cmp eq, t0, 105
        jtr @scan_d+
        cmp eq, t0, 117
        jtr @scan_u+
        cmp eq, t0, 115
        jtr @scan_s+
        cmp eq, t0, 102
        jtr @scan_f+
        cmp eq, t0, 99
        jtr @scan_c+
        cmp eq, t0, 37
        jtr @scan_pct+
        jmp @adv+

    @scan_d:
        # skip input whitespace
        @wd:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @wd_adv+
            cmp eq, t0, 9
            jtr @wd_adv+
            cmp eq, t0, 10
            jtr @wd_adv+
            cmp eq, t0, 13
            jtr @wd_adv+
            jmp @wd_done+
            @wd_adv: inc s0
            jmp @wd-
        @wd_done:
        # parse sign
        mov t1, 0
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 45
        jfs @no_neg_d+
        mov t1, 1
        inc s0
        jmp @after_sign_d+
        @no_neg_d:
        cmp eq, t0, 43
        jfs @after_sign_d+
        inc s0
        @after_sign_d:
        # check at least one digit present
        mov ea, s0
        lde u8t, t0, 0
        cmp lt, t0, 48
        jtr @adv+
        cmp gt, t0, 57
        jtr @adv+
        # accumulate digits
        vpsh s4
        mov s4, 0
        @dig_d:
            mov ea, s0
            lde u8t, t0, 0
            cmp lt, t0, 48
            jtr @dig_d_done+
            cmp gt, t0, 57
            jtr @dig_d_done+
            sub t0, 48
            mul s4, 10
            add s4, t0
            inc s0
            jmp @dig_d-
        @dig_d_done:
        cmp eq, t1, 0
        jtr @d_pos+
        neg s4
        @d_pos:
        # store at out ptr
        mov ea, s2
        lde u32t, t0, 0
        add s2, 4
        mov ea, t0
        ste i32t, 0, s4
        vpop s4
        inc s3
        jmp @adv+

    @scan_u:
        @wu:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @wu_adv+
            cmp eq, t0, 9
            jtr @wu_adv+
            cmp eq, t0, 10
            jtr @wu_adv+
            cmp eq, t0, 13
            jtr @wu_adv+
            jmp @wu_done+
            @wu_adv: inc s0
            jmp @wu-
        @wu_done:
        mov ea, s0
        lde u8t, t0, 0
        cmp ltu, t0, 48
        jtr @adv+
        cmp gt, t0, 57
        jtr @adv+
        vpsh s4
        mov s4, 0
        @dig_u:
            mov ea, s0
            lde u8t, t0, 0
            cmp ltu, t0, 48
            jtr @dig_u_done+
            cmp gt, t0, 57
            jtr @dig_u_done+
            sub t0, 48
            mul s4, 10
            add s4, t0
            inc s0
            jmp @dig_u-
        @dig_u_done:
        mov ea, s2
        lde u32t, t0, 0
        add s2, 4
        mov ea, t0
        ste u32t, 0, s4
        vpop s4
        inc s3
        jmp @adv+

    @scan_s:
        @ws2:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @ws2_adv+
            cmp eq, t0, 9
            jtr @ws2_adv+
            cmp eq, t0, 10
            jtr @ws2_adv+
            cmp eq, t0, 13
            jtr @ws2_adv+
            jmp @ws2_done+
            @ws2_adv: inc s0
            jmp @ws2-
        @ws2_done:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        # get output ptr (absolute)
        mov ea, s2
        lde u32t, t1, 0
        add s2, 4
        # copy non-whitespace chars
        @str_cp:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 0
            jtr @str_done+
            cmp eq, t0, 32
            jtr @str_done+
            cmp eq, t0, 9
            jtr @str_done+
            cmp eq, t0, 10
            jtr @str_done+
            cmp eq, t0, 13
            jtr @str_done+
            mov ea, t1
            ste u8t, 0, t0
            inc s0
            inc t1
            jmp @str_cp-
        @str_done:
        mov ea, t1
        ste u8t, 0, 0
        inc s3
        jmp @adv+

    @scan_f:
        @wf:
            mov ea, s0
            lde u8t, t0, 0
            cmp eq, t0, 32
            jtr @wf_adv+
            cmp eq, t0, 9
            jtr @wf_adv+
            cmp eq, t0, 10
            jtr @wf_adv+
            cmp eq, t0, 13
            jtr @wf_adv+
            jmp @wf_done+
            @wf_adv: inc s0
            jmp @wf-
        @wf_done:
        vpsh s4..s6
        mov s4, 0       # negative flag
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 45
        jfs @fno_neg+
        mov s4, 1
        inc s0
        jmp @fafter_sign+
        @fno_neg:
        cmp eq, t0, 43
        jfs @fafter_sign+
        inc s0
        @fafter_sign:
        # integer part
        fctf s5, zr     # s5 = result float (starts at 0.0)
        @fdig_int:
            mov ea, s0
            lde u8t, t0, 0
            cmp lt, t0, 48
            jtr @fdig_int_done+
            cmp gt, t0, 57
            jtr @fdig_int_done+
            sub t0, 48
            fmul s5, 10.0
            fctf s6, t0
            fadd s5, s6
            inc s0
            jmp @fdig_int-
        @fdig_int_done:
        # fractional part
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 46  # '.'
        jfs @fno_frac+
        inc s0
        fctf s6, zr     # s6 = frac multiplier seed
        fadd s6, 0.1    # s6 = 0.1
        @fdig_frac:
            mov ea, s0
            lde u8t, t0, 0
            cmp lt, t0, 48
            jtr @fdig_frac_done+
            cmp gt, t0, 57
            jtr @fdig_frac_done+
            sub t0, 48
            fctf t0, t0
            fmul t0, s6
            fadd s5, t0
            fmul s6, 0.1
            inc s0
            jmp @fdig_frac-
        @fdig_frac_done:
        @fno_frac:
        cmp eq, s4, 0
        jtr @fpos+
        fneg s5
        @fpos:
        mov ea, s2
        lde u32t, t0, 0
        add s2, 4
        mov ea, t0
        ste f32t, 0, s5
        vpop s4..s6
        inc s3
        jmp @adv+

    @scan_c:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 0
        jtr @done+
        mov ea, s2
        lde u32t, t1, 0
        add s2, 4
        mov ea, t1
        ste u8t, 0, t0
        inc s0
        inc s3
        jmp @adv+

    @scan_pct:
        mov ea, s0
        lde u8t, t0, 0
        cmp eq, t0, 37
        jfs @done+
        inc s0

    @adv:
        inc s1
        jmp @loop-

    @done:
    ret

sscanf:
    vpsh s0..s3
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

    mov s0, a0
    mov s1, a1
    mov s2, sp
    mov s3, 0
    cal _sscanf_loop
    mov a0, s3

    add sp, 32
    vpop s0..s3
    ret

scanf:
    vpsh s0..s3
    sub sp, 32
    mov ea, sp
    ste u32t, 0,  a1
    ste u32t, 4,  a2
    ste u32t, 8,  a3
    ste u32t, 12, a4
    ste u32t, 16, a5
    ste u32t, 20, a6
    ste u32t, 24, a7
    ste u32t, 28, a8

    mov s0, a0          # save fmt

    syscall SYS_GET_TERMINAL_INPUT_SIZE
    cmp eq, a0, 0
    jtr @empty+

    psh a0              # save input size
    mov a0, _sscanf_input_buf
    pop a1
    syscall SYS_READ_TERMINAL_INPUT

    # s0=input(abs), s1=fmt(abs), s2=out ptrs(abs), s3=count
    tpa s1, _sscanf_input_buf   # absolute ptr to filled buffer
    swp s0, s1                  # s0=input, s1=fmt
    mov s2, sp
    mov s3, 0
    cal _sscanf_loop
    mov a0, s3
    jmp @done+

    @empty:
    mov a0, 0

    @done:
    add sp, 32
    vpop s0..s3
    ret
