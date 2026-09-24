get_pixel:
    gbpx a0, a0, a1
    ret

set_pixel:
    sbpx a0, a1, a2
    ret

normalize_luma:
    norm a0
    ret

denormalize_luma:
    dnrm a0
    ret