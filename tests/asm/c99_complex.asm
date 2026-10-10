bmk "TOP"
_start:
	cal main_
	exit

sbmk "crealf_(value: f32t): f32t"
##
## Parameters:
## > a0 - value, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
crealf_:
	sub sp, 8
	mov ea, fp
	ste f32t, -8, a0
	ste f32t, -4, a1
	add t3, fp, -8
	mov t2, t3
	mov t1, t2
	mov t2, 0
	mul t2, 4
	add t1, t2
	mov ea, t1
	lde f32t, t0, 0
	mov a0, t0
	add sp, 8
	ret

sbmk "cimagf_(value: f32t): f32t"
##
## Parameters:
## > a0 - value, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
cimagf_:
	sub sp, 8
	mov ea, fp
	ste f32t, -8, a0
	ste f32t, -4, a1
	add t3, fp, -8
	mov t2, t3
	mov t1, t2
	mov t2, 1
	mul t2, 4
	add t1, t2
	mov ea, t1
	lde f32t, t0, 0
	mov a0, t0
	add sp, 8
	ret

sbmk "cabsf_(value: f32t): f32t"
##
## Parameters:
## > a0 - value, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
cabsf_:
	sub sp, 8
	mov ea, fp
	ste f32t, -8, a0
	ste f32t, -4, a1
	psh t0
	add t0, fp, -8
	mov ea, t0
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal crealf_
	mov t1, a0
	pop t0
	psh t0
	psh t1
	add t0, fp, -8
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov a1, t2
	mov a0, t1
	fmul a0, a0, a0
	fmul a1, a1, a1
	fadd a0, a0, a1
	fsqrt a0, a0
	mov t0, a0
	mov a0, t0
	add sp, 8
	ret

sbmk "cexpf_(value: f32t): f32t"
##
## Parameters:
## > a0 - value, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
cexpf_:
	sub sp, 20
	mov ea, fp
	ste f32t, -8, a0
	ste f32t, -4, a1
	psh t0
	add t0, fp, -8
	mov ea, t0
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal crealf_
	mov t1, a0
	pop t0
	mov a0, t1
	fexp a0, a0
	mov t0, a0
	mov ea, fp
	ste f32t, -12, t0
	mov ea, fp
	lde f32t, t2, -12
	psh t0
	psh t1
	psh t2
	psh t3
	add t1, fp, -8
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal cimagf_
	mov t0, a0
	pop t3
	mov a0, t0
	fcos a0, a0
	mov t3, a0
	pop t2
	pop t1
	pop t0
	fmul t1, t2, t3
	add t2, fp, -20
	mov ea, t2
	ste f32t, 0, t1
	add t0, fp, -20
	mov ea, fp
	lde f32t, t2, -12
	psh t0
	psh t1
	psh t2
	psh t3
	add t1, fp, -8
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal cimagf_
	mov t0, a0
	pop t3
	mov a0, t0
	fcos a0, a0
	mov t3, a0
	pop t2
	pop t1
	pop t0
	fmul t1, t2, t3
	mov ea, fp
	lde f32t, t3, -12
	psh t0
	psh t1
	psh t2
	psh t3
	psh t4
	add t1, fp, -8
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal cimagf_
	mov t0, a0
	pop t4
	mov a0, t0
	fsin a0, a0
	mov t4, a0
	pop t3
	pop t2
	pop t1
	pop t0
	fmul t2, t3, t4
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t2
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t2, 4
	mov a0, t1
	mov a1, t2
	add sp, 20
	ret

sbmk "csqrtf_(value: f32t): f32t"
##
## Parameters:
## > a0 - value, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
csqrtf_:
	sub sp, 36
	mov ea, fp
	ste f32t, -8, a0
	ste f32t, -4, a1
	add t1, fp, -8
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal crealf_
	mov t0, a0
	mov ea, fp
	ste f32t, -12, t0
	add t1, fp, -8
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal cimagf_
	mov t0, a0
	mov ea, fp
	ste f32t, -16, t0
	add t1, fp, -8
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t2
	cal cabsf_
	mov t0, a0
	mov ea, fp
	ste f32t, -20, t0
	mov ea, fp
	lde f32t, t3, -20
	mov ea, fp
	lde f32t, t4, -12
	fadd t2, t3, t4
	mov t3, 2.0
	fdiv t1, t2, t3
	mov a0, t1
	fsqrt a0, a0
	mov t0, a0
	mov ea, fp
	ste f32t, -24, t0
	mov ea, fp
	lde f32t, t3, -20
	mov ea, fp
	lde f32t, t4, -12
	fsub t2, t3, t4
	mov t3, 2.0
	fdiv t1, t2, t3
	mov a0, t1
	fsqrt a0, a0
	mov t0, a0
	mov ea, fp
	ste f32t, -28, t0
	mov ea, fp
	lde f32t, t1, -16
	mov t2, 0.0
	cmp flt, t1, t2
	sel t0, 1, 0
	cmp eq, t0, zr
	jtr __L0
	mov ea, fp
	lde f32t, t2, -28
	fneg t1, t2
	mov ea, fp
	ste f32t, -28, t1
	mov t0, t1
__L0:
__L1:
	mov ea, fp
	lde f32t, t1, -24
	add t2, fp, -36
	mov ea, t2
	ste f32t, 0, t1
	add t0, fp, -36
	mov ea, fp
	lde f32t, t1, -24
	mov ea, fp
	lde f32t, t2, -28
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t2
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t2, 4
	mov a0, t1
	mov a1, t2
	add sp, 36
	ret

sbmk "add_scaled_(left: f32t, right: f32t, scale: f32t): f32t"
##
## Parameters:
## > a0 - left, is f32t
## > a1 - right, is f32t
## > a2 - scale, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
add_scaled_:
	sub sp, 36
	mov ea, fp
	ste f32t, -8, a0
	ste f32t, -4, a1
	mov ea, fp
	ste f32t, -16, a2
	ste f32t, -12, a3
	mov ea, fp
	ste f32t, -20, a4
	add t0, fp, -28
	add t3, fp, -8
	mov ea, t3
	lde f32t, t4, 0
	lde f32t, t5, 4
	add t3, fp, -36
	add t8, fp, -16
	mov ea, t8
	lde f32t, t9, 0
	lde f32t, t10, 4
	mov ea, fp
	lde f32t, t8, -20
	mov t11, 0.0
	fmul t6, t9, t8
	fmul t12, t10, t11
	fsub t6, t6, t12
	fmul t7, t9, t11
	fmul t12, t10, t8
	fadd t7, t7, t12
	mov ea, t3
	ste f32t, 0, t6
	ste f32t, 4, t7
	mov ea, t3
	lde f32t, t6, 0
	lde f32t, t7, 4
	fadd t1, t4, t6
	fadd t2, t5, t7
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t2
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t2, 4
	mov a0, t1
	mov a1, t2
	add sp, 36
	ret

sbmk "call_indirect_(operation: u32t*, left: f32t, right: f32t): f32t"
##
## Parameters:
## > a0 - operation, is u32t*
## > a1 - left, is f32t
## > a2 - right, is f32t
## Returns:
## < a0 - return value, is f32t
## Additional Implementation Notes:
call_indirect_:
	sub sp, 28
	mov ea, fp
	ste u32t, -4, a0
	mov ea, fp
	ste f32t, -12, a1
	ste f32t, -8, a2
	mov ea, fp
	ste f32t, -20, a3
	ste f32t, -16, a4
	add t0, fp, -28
	psh t0
	add t0, fp, -12
	mov ea, t0
	lde f32t, t2, 0
	lde f32t, t3, 4
	add t0, fp, -20
	mov ea, t0
	lde f32t, t4, 0
	lde f32t, t5, 4
	mov t0, 2.0
	mov a4, t0
	mov a3, t5
	mov a2, t4
	mov a1, t3
	mov a0, t2
	mov ea, fp
	lde u32t, t0, -4
	tpr t0
	sub t0, @__ical+
@__ical:
	cal t0
	mov t1, a0
	pop t0
	mov t2, a1
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t2
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t2, 4
	mov a0, t1
	mov a1, t2
	add sp, 28
	ret

sbmk "main_(): i16t"
##
## Parameters: NONE
## Returns:
## < a0 - return value, is i16t
## Additional Implementation Notes:
main_:
	sub sp, 184
	add t0, fp, -8
	mov t1, 2.0
	mov t2, 3.0
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t2
	add t0, fp, -16
	add t1, fp, -24
	mov t4, 4.0
	mov t5, 0.0
	mov t7, 0.0
	add t8, fp, -32
	mov ea, t8
	ste f32t, 0, t7
	add t6, fp, -32
	mov t7, 0.0
	mov t8, 1.0
	mov ea, t6
	ste f32t, 0, t7
	ste f32t, 4, t8
	mov ea, t6
	lde f32t, t7, 0
	lde f32t, t8, 4
	fsub t2, t4, t7
	fsub t3, t5, t8
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -40
	add t1, fp, -48
	add t4, fp, -8
	mov ea, t4
	lde f32t, t5, 0
	lde f32t, t6, 4
	add t4, fp, -16
	mov ea, t4
	lde f32t, t7, 0
	lde f32t, t8, 4
	fadd t2, t5, t7
	fadd t3, t6, t8
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -56
	add t1, fp, -64
	add t4, fp, -8
	mov ea, t4
	lde f32t, t5, 0
	lde f32t, t6, 4
	add t4, fp, -16
	mov ea, t4
	lde f32t, t7, 0
	lde f32t, t8, 4
	fmul t2, t5, t7
	fmul t4, t6, t8
	fsub t2, t2, t4
	fmul t3, t5, t8
	fmul t4, t6, t7
	fadd t3, t3, t4
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -72
	add t1, fp, -80
	add t4, fp, -56
	mov ea, t4
	lde f32t, t5, 0
	lde f32t, t6, 4
	add t4, fp, -16
	mov ea, t4
	lde f32t, t7, 0
	lde f32t, t8, 4
	fmul t4, t7, t7
	fmul t9, t8, t8
	fadd t4, t4, t9
	fmul t2, t5, t7
	fmul t9, t6, t8
	fadd t2, t2, t9
	fdiv t2, t2, t4
	fmul t3, t6, t7
	fmul t9, t5, t8
	fsub t3, t3, t9
	fdiv t3, t3, t4
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -88
	add t1, fp, -96
	add t2, fp, -8
	mov ea, t2
	lde f32t, t3, 0
	lde f32t, t4, 4
	fneg t3, t3
	fneg t4, t4
	mov ea, t1
	ste f32t, 0, t3
	ste f32t, 4, t4
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -104
	add t1, fp, -112
	psh t0
	psh t1
	add t0, fp, -8
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	add t0, fp, -16
	mov ea, t0
	lde f32t, t4, 0
	lde f32t, t5, 4
	mov t0, 2.0
	mov a4, t0
	mov a3, t5
	mov a2, t4
	mov a1, t3
	mov a0, t1
	cal add_scaled_
	mov t2, a0
	pop t1
	pop t0
	mov t3, a1
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -120
	add t1, fp, -128
	psh t0
	psh t1
	tpa t0, add_scaled_
	add t1, fp, -8
	mov ea, t1
	lde f32t, t3, 0
	lde f32t, t4, 4
	add t1, fp, -16
	mov ea, t1
	lde f32t, t5, 0
	lde f32t, t6, 4
	mov a4, t6
	mov a3, t5
	mov a2, t4
	mov a1, t3
	mov a0, t0
	cal call_indirect_
	mov t2, a0
	pop t1
	pop t0
	mov t3, a1
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -136
	add t1, fp, -144
	psh t0
	psh t1
	mov t1, 0.0
	add t3, fp, -152
	mov ea, t3
	ste f32t, 0, t1
	add t0, fp, -152
	mov t1, 0.0
	mov t3, 1.0
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t3
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cexpf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, a1
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	add t0, fp, -160
	add t1, fp, -168
	psh t0
	psh t1
	mov t3, 4.0
	fneg t1, t3
	add t3, fp, -176
	mov ea, t3
	ste f32t, 0, t1
	add t0, fp, -176
	mov t3, 4.0
	fneg t1, t3
	mov t3, 0.0
	mov ea, t0
	ste f32t, 0, t1
	ste f32t, 4, t3
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal csqrtf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, a1
	mov ea, t1
	ste f32t, 0, t2
	ste f32t, 4, t3
	mov ea, t1
	lde f32t, t2, 0
	lde f32t, t3, 4
	mov ea, t0
	ste f32t, 0, t2
	ste f32t, 4, t3
	psh t0
	psh t1
	add t0, fp, -40
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal crealf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 6.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L4
	psh t0
	psh t1
	add t0, fp, -40
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 2.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L4:
	cmp eq, t0, zr
	jtr __L2
	mov t0, 1
	mov a0, t0
	add sp, 184
	ret
__L2:
__L3:
	psh t0
	psh t1
	add t0, fp, -72
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal crealf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 2.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L7
	psh t0
	psh t1
	add t0, fp, -72
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 3.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L7:
	cmp eq, t0, zr
	jtr __L5
	mov t0, 2
	mov a0, t0
	add sp, 184
	ret
__L5:
__L6:
	psh t0
	psh t1
	add t0, fp, -104
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal crealf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 10.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L10
	psh t0
	psh t1
	add t0, fp, -104
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 1.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L10:
	cmp eq, t0, zr
	jtr __L8
	mov t0, 3
	mov a0, t0
	add sp, 184
	ret
__L8:
__L9:
	psh t0
	psh t1
	add t0, fp, -120
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal crealf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 10.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L13
	psh t0
	psh t1
	add t0, fp, -120
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 1.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L13:
	cmp eq, t0, zr
	jtr __L11
	mov t0, 4
	mov a0, t0
	add sp, 184
	ret
__L11:
__L12:
	psh t0
	psh t1
	add t0, fp, -136
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal crealf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 0.5
	cmp flt, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L16
	psh t0
	psh t1
	add t0, fp, -136
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 0.8
	cmp flt, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L16:
	cmp eq, t0, zr
	jtr __L14
	mov t0, 5
	mov a0, t0
	add sp, 184
	ret
__L14:
__L15:
	psh t0
	psh t1
	add t0, fp, -160
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal crealf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 0.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	mov t0, t1
	cmp neq, t0, zr
	jtr __L19
	psh t0
	psh t1
	add t0, fp, -160
	mov ea, t0
	lde f32t, t1, 0
	lde f32t, t3, 4
	mov a1, t3
	mov a0, t1
	cal cimagf_
	mov t2, a0
	pop t1
	pop t0
	mov t3, 2.0
	cmp fneqa, t2, t3
	sel t1, 1, 0
	cmp neq, t1, zr
	sel t0, 1, 0
__L19:
	cmp eq, t0, zr
	jtr __L17
	mov t0, 6
	mov a0, t0
	add sp, 184
	ret
__L17:
__L18:
	add t2, fp, -88
	mov ea, t2
	lde f32t, t3, 0
	lde f32t, t4, 4
	mov t6, 2.0
	fneg t5, t6
	add t6, fp, -184
	mov ea, t6
	ste f32t, 0, t5
	add t2, fp, -184
	mov t6, 2.0
	fneg t5, t6
	mov t7, 3.0
	fneg t6, t7
	mov ea, t2
	ste f32t, 0, t5
	ste f32t, 4, t6
	mov ea, t2
	lde f32t, t5, 0
	lde f32t, t6, 4
	cmp feqa, t3, t5
	sel t0, 1, 0
	cmp feqa, t4, t6
	sel t1, 1, 0
	and t0, t0, t1
	xor t0, t0, 1
	cmp eq, t0, zr
	jtr __L20
	mov t0, 7
	mov a0, t0
	add sp, 184
	ret
__L20:
__L21:
	mov t0, 0
	mov a0, t0
	add sp, 184
	ret

