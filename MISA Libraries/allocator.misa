bmk "TOP"

bmk "Allocator - About"

# Author: @theernie on Discord
# How to use:
#   this general purpose allocator exposes 3 functions for managing dynamic memory.
#   all allocations are 16-byte aligned.
#
#   malloc:
#   > a0: u32t, bytes requested
#   < a0: u32t, pointer to allocated block. NULL if allocation failed
#
#   free:
#   > a0: u32t, pointer to block to free
#
#   realloc:
#   > a0: u32t, pointer to allocated block to reallocate
#   > a1: u32t, amount of bytes to reallocate to
#   < a0: u32t, pointer to reallocated block. NULL if allocation failed
#
#   edge cases:
#     malloc(0)        returns NULL
#     free(NULL)       is a NOP
#     realloc(NULL, n) behaves like malloc(n)
#     realloc(ptr, 0)  behaves like free(ptr)
#
#   customize heap size:
#     default heap size is 512 KiB
#     to customize it, change the value at ALLOC_DATA.HEAP_SIZE
#     the value must be a multiple of 16, else you get undefined behaviour
#
#   fragmentation:
#     fragmentation seems to be a non issue as of my tests,
#     though i dont know how bad it can really get.
#     you can test current fragmentation by calling:
#
#   ALLOC_INTERNAL.fragmentation_index:
#   < a0: f32t, current heap fragmentation from 0.0 (very good) to 1.0 (very bad)
#
#   known issues:
#     if the heap reaches a certain fragmentation,
#     the free list grows too long, so the watchdog kills
#     the allocator before it finishes.
#     currently there are no yields in there to reduce the performance overhead,
#     but if that becomes an issue to you ask @TheErnie on the discord,
#     or add a "yield" into the traversal loops yourself

bmk "Allocator - Structs"

# Allocator Header:
#   prev_info: u32t
#   curr_info: u32t
#   prev_free: u32t (pointer to prev free block)
#   next_free: u32t (pointer to next free block)

ALLOC_HEADER:
    .prev_info: emb u32t 0
    .curr_info: emb u32t 0
    .prev_free: emb u32t 0
    .next_free: emb u32t 0
    def ._PREV_INFO (.prev_info - ALLOC_HEADER)
    def ._CURR_INFO (.curr_info - ALLOC_HEADER)
    def ._PREV_FREE (.prev_free - ALLOC_HEADER)
    def ._NEXT_FREE (.next_free - ALLOC_HEADER)
    def .SIZE ($ - ALLOC_HEADER)
    def .INFO_SIZE 8 # 2 * sizeof(u32t)
    def .INFO_MASK_SIZE ~0x7
    def .INFO_MASK_USED  0x1

bmk "Allocator - Data"

ALLOC_DATA:
    # Must be multiple of 16, else UB
    def .HEAP_SIZE 0x20000000 # 512 MiB
    .HEAP_PADDING: res u8t 16 - ($ & 0b1111)
    .HEAP: res u8t .HEAP_SIZE
    .FREE_LIST: emb u32t 0
    .INITIALIZED: emb u8t false
    def .SENTINEL_START .HEAP
    def .SENTINEL_END .HEAP + .HEAP_SIZE - ALLOC_HEADER.INFO_SIZE

bmk "Allocator - Internals"

ALLOC_INTERNAL:
    .add_free_list:
        # > a0: u32t, pointer to header
        cea a0, ALLOC_HEADER._PREV_FREE, 1
        ste u32t, 0, 0
        lod u32t, t0, ALLOC_DATA.FREE_LIST
        cea a0, ALLOC_HEADER._NEXT_FREE, 1
        ste u32t, 0, t0
        @if_free_list_null:
            cmp eq, t0, 0
            jtr @endif+
            cea t0, ALLOC_HEADER._PREV_FREE, 1
            ste u32t, 0, a0
        @endif:
        str u32t, ALLOC_DATA.FREE_LIST, a0
        ret

    .remove_free_list:
        # > a0: u32t, pointer to header
        cea a0, ALLOC_HEADER._PREV_FREE, 1
        lde u32t, t0, 0
        cea a0, ALLOC_HEADER._NEXT_FREE, 1
        lde u32t, t1, 0
        lod u32t, t2, ALLOC_DATA.FREE_LIST
        @if_free_list_eq_header:
            cmp neq, t2, a0
            jtr @endif+
            str u32t, ALLOC_DATA.FREE_LIST, t1
        @endif:
        @if_prev_free_not_null:
            cmp eq, t0, 0
            jtr @endif+
            cea t0, ALLOC_HEADER._NEXT_FREE, 1
            ste u32t, 0, t1
        @endif:
        @if_next_free_not_null:
            cmp eq, t1, 0
            jtr @endif+
            cea t1, ALLOC_HEADER._PREV_FREE, 1
            ste u32t, 0, t0
        @endif:
        ret

    .header_next:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to next header
        cea a0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        add a0, ALLOC_HEADER.INFO_SIZE
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add a0, t0
        ret

    .header_prev:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to prev header
        cea a0, ALLOC_HEADER._PREV_INFO, 1
        lde u32t, t0, 0
        sub a0, ALLOC_HEADER.INFO_SIZE
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        sub a0, t0
        ret

    .coalesce_next:
        # > a0: u32t, pointer to header
        # < a0:  u8t, bool was coalesced
        #   s0: current header
        #   s1: next header
        #   s2: next next header
        #   s3: new size
        vpsh s0..s3
        mov s0, a0
        cal .header_next
        mov s1, a0
        cal .header_next
        mov s2, a0
        cea s1, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_USED
        @if_header_used:
            cmp eq, t0, 0
            jtr @endif+
            mov a0, false
            jmp @return+
        @endif:
        mov a0, s1
        cal .remove_free_list
        mov s3, ALLOC_HEADER.INFO_SIZE
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add s3, t0
        cea s1, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add s3, t0
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_USED
        orr t0, s3
        cea s2, ALLOC_HEADER._PREV_INFO, 1
        ste u32t, 0, t0
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ~ALLOC_HEADER.INFO_MASK_SIZE
        orr t0, s3
        ste u32t, 0, t0
        mov a0, true
        @return:
        vpop s0..s3
        ret

    .coalesce_prev:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to coalesced header
        #   s0: u32t, pointer to header
        psh s0
        mov s0, a0
        cea s0, ALLOC_HEADER._PREV_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_USED
        @if_not_used:
            cmp eq, t0, 1
            jtr @endif+
            cal .header_prev
            mov s0, a0
            cal .coalesce_next
        @endif:
        mov a0, s0
        pop s0
        ret

    .coalesce:
        # > a0: u32t, pointer to header
        # < a0: u32t, pointer to coalesced header
        #   s0: u32t, pointer to header
        psh s0
        mov s0, a0
        cal .coalesce_next
        mov a0, s0
        cal .coalesce_prev
        pop s0
        ret

    .initialize:
        mov t0, 0b1
        mov t1, ALLOC_DATA.HEAP_SIZE
        sub t1, 2 * ALLOC_HEADER.INFO_SIZE
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._PREV_INFO, t0
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._CURR_INFO, t1
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._PREV_FREE, 0
        str u32t, ALLOC_DATA.SENTINEL_START + ALLOC_HEADER._NEXT_FREE, 0
        str u32t, ALLOC_DATA.SENTINEL_END   + ALLOC_HEADER._PREV_INFO, t1
        str u32t, ALLOC_DATA.SENTINEL_END   + ALLOC_HEADER._CURR_INFO, t0
        mov a0, ALLOC_DATA.SENTINEL_START
        cal .add_free_list
        str u8t, ALLOC_DATA.INITIALIZED, true
        ret

    .find_free_block:
        # > a0: u32t, requested size, pre-aligned
        # < a0: u32t, pointer to header | NULL
        lod u32t, t0, ALLOC_DATA.FREE_LIST
        @while_header_not_null:
            cmp eq, t0, 0
            jtr @endwhile+
            cea t0, ALLOC_HEADER._CURR_INFO, 1
            lde u32t, t1, 0
            and t1, ALLOC_HEADER.INFO_MASK_SIZE
            @if_size_gte_requested:
                cmp lt, t1, a0
                jtr @endif+
                mov a0, t0
                jmp @return+
            @endif:
            cea t0, ALLOC_HEADER._NEXT_FREE, 1
            lde u32t, t0, 0
            jmp @while_header_not_null-
        @endwhile:
        mov a0, 0
        @return:
        ret

    .split_block:
        # > a0: u32t, pointer to header
        # > a1: u32t, requested size, pre-aligned
        # < a0: u32t, pointer to split block header
        #   s0: u32t, pointer to header, a0
        #   s1: u32t, requested size, a1
        #   s2: u32t, split size
        #   s3: u32t, pointer to split block header
        #   s4: u32t, header current info
        vpsh s0..s4
        mov s0, a0
        mov s1, a1
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        add t1, s1, ALLOC_HEADER.INFO_SIZE + 16 # 16 byte alignment
        @if_split_size_too_small:
            cmp gte, t0, t1
            jtr @endif+
            mov a0, 0
            jmp @return+
        @endif:
        sub s2, t0, s1
        sub s2, ALLOC_HEADER.INFO_SIZE
        cal .header_next
        cea a0, ALLOC_HEADER._PREV_INFO, 1
        ste u32t, 0, s2
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, s4, 0
        and s4, ALLOC_HEADER.INFO_MASK_USED
        orr s4, s1
        ste u32t, 0, s4
        mov a0, s0
        cal .header_next
        mov s3, a0
        and t0, s4, ALLOC_HEADER.INFO_MASK_USED
        orr t0, s1
        cea s3, ALLOC_HEADER._PREV_INFO, 1
        ste u32t, 0, t0
        cea s3, ALLOC_HEADER._CURR_INFO, 1
        ste u32t, 0, s2
        mov a0, s3
        cal .add_free_list
        mov a0, s3
        cal .coalesce_next
        mov a0, s3
        @return:
        vpop s0..s4
        ret

    .fragmentation_index:
        # < a0: f32t, heap fragmentation index 0.0 (low) to 1.0 (high)
        #   s0: u32t, size of largest free block
        #   s1: u32t, total free heap memory
        #   s2: u32t, pointer to current block
        vpsh s0..s2
        mov s0, 0
        mov s1, 0
        lod u32t, s2, ALLOC_DATA.FREE_LIST
        @while_not_at_end:
            cmp neq, s2, 0
            jfs @endwhile+
            cea s2, ALLOC_HEADER._CURR_INFO, 1
            lde u32t, t0, 0
            cea s2, ALLOC_HEADER._NEXT_FREE, 1
            lde u32t, s2, 0
            cmp gt, t0, s0
            mvc s0, t0
            add s1, t0
            jmp @while_not_at_end-
        @endwhile:
        @if_no_free_memory:
            cmp eq, s1, 0
            jfs @endif+
            mov a0, 0.0
            jmp @return+
        @endif:
        fctf s0
        fctf s1
        fdiv a0,  s0, s1
        fsub a0, 1.0, a0
        @return:
        vpop s0..s2
        ret


bmk "Allocator - Interface"

sbmk "malloc(size: u32): void*"
## Allocates a section of memory
## Parameters:
## > a0 - Requested allocation size in bytes
## Returns:
## < a0 - Pointer to allocation or NULL
## Additional Implementation Notes:
## s0 - saved a0
## s1 - block candidate header
malloc:
    vpsh s0..s1
    mov s0, a0
    @if_size_is_zero:
        cmp eq, s0, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    lod u8t, t0, ALLOC_DATA.INITIALIZED
    @if_not_initialized:
        cmp eq, t0, false
        jfs @endif+
        cal ALLOC_INTERNAL.initialize
    @endif:
    add s0,  0b1111
    and s0, ~0b1111
    @if_overflowed:
        cmp eq, s0, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    mov a0, s0
    cal ALLOC_INTERNAL.find_free_block
    mov s1, a0
    @if_out_of_memory:
        cmp eq, s1, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    mov a1, s0
    cal ALLOC_INTERNAL.split_block
    mov a0, s1
    cal ALLOC_INTERNAL.remove_free_list
    cea s1, ALLOC_HEADER._CURR_INFO, 1
    lde u32t, t0, 0
    orr t0, 0b1
    ste u32t, 0, t0
    mov a0, s1
    cal ALLOC_INTERNAL.header_next
    cea a0, ALLOC_HEADER._PREV_INFO, 1
    lde u32t, t0, 0
    orr t0, 0b1
    ste u32t, 0, t0
    mov a0, s1
    add a0, ALLOC_HEADER.INFO_SIZE
    @if_out_of_heap_bounds:
        cmp gte, a0, ALLOC_DATA.HEAP + ALLOC_DATA.HEAP_SIZE
        jfs @endif+
        break
    @endif:
    @return:
    vpop s0..s1
    ret

sbmk "free(mem_block: void*): void"
## Frees a section of memory so that it can be reused later on
## Parameters:
## > a0 - Pointer to the memory block to free
## Returns:
##   Nothing
## Additional Implementation Notes:
## s0 - saved a0
free:
    # > a0: u32t, pointer to free
    #   s0: u32t, a0 saved
    psh s0
    mov s0, a0
    @if_ptr_is_null:
        cmp eq, s0, 0
        jfs @endif+
        jmp @return+
    @endif:
    sub s0, ALLOC_HEADER.INFO_SIZE
    cea s0, ALLOC_HEADER._CURR_INFO, 1
    lde u32t, t0, 0
    xor t0, ALLOC_HEADER.INFO_MASK_USED
    ste u32t, 0, t0
    mov a0, s0
    cal ALLOC_INTERNAL.header_next
    cea a0, ALLOC_HEADER._PREV_INFO, 1
    lde u32t, t0, 0
    xor t0, ALLOC_HEADER.INFO_MASK_USED
    ste u32t, 0, t0
    mov a0, s0
    cal ALLOC_INTERNAL.add_free_list
    mov a0, s0
    cal ALLOC_INTERNAL.coalesce
    @return:
    pop s0
    ret

sbmk "realloc(mem_block: void*, new_size: u32): void*"
## Reallocates a section of memory
## Parameters:
## > a0 - Pointer to allocation
## > a1 - new size in bytes
## Returns:
## < a0 - Pointer to allocation or NULL
## Additional Implementation Notes:
## s0 - saved a0
## s1 - saved a1
## s2 - original block size
realloc:
    vpsh s0..s2
    mov s0, a0
    mov s1, a1
    @if_ptr_is_null:
        cmp eq, s0, 0
        jfs @endif+
        mov a0, s1
        cal malloc
        jmp @return+
    @endif:
    @if_size_is_null:
        cmp eq, s1, 0
        jfs @endif+
        mov a0, 0
        jmp @return+
    @endif:
    add s1, 15
    and s1, ~15
    sub s0, ALLOC_HEADER.INFO_SIZE
    cea s0, ALLOC_HEADER._CURR_INFO, 1
    lde u32t, s2, 0
    and s2, ALLOC_HEADER.INFO_MASK_SIZE
    @if_shrinking:
        cmp lte, s1, s2
        jfs @endif+
        mov a0, s0
        mov a1, s1
        cal ALLOC_INTERNAL.split_block
        jmp @return+
    @endif:
    mov a0, s0
    cal ALLOC_INTERNAL.coalesce_next
    @if_coalesced:
        cmp eq, a0, true
        jfs @endif+
        cea s0, ALLOC_HEADER._CURR_INFO, 1
        lde u32t, t0, 0
        and t0, ALLOC_HEADER.INFO_MASK_SIZE
        @if_coalesced_big_enough:
            cmp lte, s1, t0
            jfs @endif_inner+
            mov a0, s0
            mov a1, s1
            cal ALLOC_INTERNAL.split_block
            mov a0, s0
            jmp @return+
        @endif_inner:
    @endif:
    mov a0, s1
    cal malloc
    mov s1, a0
    @if_new_ptr_not_null:
        cmp neq, s1, 0
        jfs @endif+
        mov a1, s0
        mov a2, s2
        syscall SYS_MEM_COPY
    @endif:
    mov a0, s1
    @return:
    vpop s0..s2
    ret

bmk "BOTTOM"
