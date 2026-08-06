bmk "MFS - About"

# MFS (Mnemonimov File System)
# A simple FAT-based filesystem layered over Mnemonimov storage.
#
# Default storage layout (1 block = 128 bytes):
#   Block 0:       Superblock
#   Blocks 1..4:   FAT  (256 u16 entries covering all data blocks)
#   Blocks 5..8:   Root directory  (variable-length entries)
#   Blocks 9..264: Data  (256 blocks, 32 KB total)
#
# Directory entries are variable-length and 2-byte aligned:
#   +0  u16  rec_len      total bytes occupied by this entry
#   +2  u8   name_len     length of name field (not null-terminated)
#   +3  u8   flags        bit 0: in-use
#   +4  u16  first_block  first FAT-chained data block (MFS_FAT_EOF = none)
#   +6  u32  file_size    file size in bytes
#   +10 u8[] name         name_len bytes
#
# Deleted entries keep their rec_len so directory walks remain intact.
# MFS.create reuses a deleted entry when its rec_len fits the new name.
#
# Public API (all in a0 unless noted):
#   MFS.format  - write a fresh filesystem to storage
#   MFS.load    - load an existing filesystem; returns MFS_ERR_INVALID on bad magic
#   MFS.open    - find file by name; returns pa-rel dirent pointer or 0
#   MFS.create  - create a new empty file entry
#   MFS.read    - read file data into a buffer; returns bytes read or -1
#   MFS.write   - replace file data from a buffer
#   MFS.delete  - delete a file and free its blocks
#
# Call MFS.format once to initialise, then MFS.load on every subsequent startup.
# The FAT and directory are kept in the MFS_DATA buffers; every mutating call
# flushes the affected buffer(s) back to storage before returning.

bmk "MFS - Constants"

def MFS_BLOCK_SIZE       128
def MFS_BLOCK_SIZE_LOG2  7
def MFS_FAT_START_BLOCK  1
def MFS_FAT_BLOCK_COUNT  4
def MFS_DIR_START_BLOCK  5
def MFS_DIR_BLOCK_COUNT  4
def MFS_DATA_START_BLOCK 9
def MFS_DATA_BLOCK_COUNT 256

def MFS_MAGIC    0x4D465300
def MFS_VERSION  1

def MFS_FAT_FREE 0x0000
def MFS_FAT_EOF  0xFFFF

# Superblock field offsets
def MFS_SB_MAGIC           0
def MFS_SB_VERSION         4
def MFS_SB_BLOCK_SIZE_LOG2 5
def MFS_SB_BLOCK_COUNT     6
def MFS_SB_FAT_START       8
def MFS_SB_FAT_BLOCK_COUNT 10
def MFS_SB_DIR_START       12
def MFS_SB_DIR_BLOCK_COUNT 14
def MFS_SB_DATA_START      16
def MFS_SB_FREE_COUNT      18

# Directory entry field offsets
def MFS_DIRENT_REC_LEN     0
def MFS_DIRENT_NAME_LEN    2
def MFS_DIRENT_FLAGS       3
def MFS_DIRENT_FIRST_BLOCK 4
def MFS_DIRENT_FILE_SIZE   6
def MFS_DIRENT_NAME        10
def MFS_DIRENT_HEADER_SIZE 10
def MFS_DIRENT_MIN_REC_LEN 12    # 10-byte header + 1-char name + 1 alignment pad

def MFS_FLAG_IN_USE 0x01

# Return codes
def MFS_OK            0
def MFS_ERR_NOT_FOUND 1
def MFS_ERR_NO_SPACE  2
def MFS_ERR_EXISTS    3
def MFS_ERR_INVALID   4

bmk "MFS - Data"

MFS_DATA:
    .superblock: res u8t MFS_BLOCK_SIZE
    .fat_buf:    res u8t MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
    .dir_buf:    res u8t MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
    .block_buf:  res u8t MFS_BLOCK_SIZE

bmk "MFS - Internals"

MFS_INTERNAL:

    sbmk "fat_alloc(): block_index | MFS_FAT_EOF"
    # Find and mark a free data block. Returns its index, or MFS_FAT_EOF if full.
    # < a0: block index, or MFS_FAT_EOF
    .fat_alloc:
        psh s0
        mov s0, 0
        @loop:
            cmp gte, s0, MFS_DATA_BLOCK_COUNT
            jtr @not_found+
            cea MFS_DATA.fat_buf, s0, 2
            lde u16t, t0, 0
            cmp eq, t0, MFS_FAT_FREE
            jtr @found+
            inc s0
            jmp @loop-
        @not_found:
            mov a0, MFS_FAT_EOF
            jmp @done+
        @found:
            ste u16t, 0, MFS_FAT_EOF    # mark allocated but end-of-chain
            mov a0, s0
        @done:
        pop s0
        ret

    sbmk "fat_get(block): next_block"
    # Read a FAT entry.
    # > a0: block index
    # < a0: FAT entry value (MFS_FAT_EOF at end of chain)
    .fat_get:
        cea MFS_DATA.fat_buf, a0, 2
        lde u16t, a0, 0
        ret

    sbmk "fat_set(block, value)"
    # Write a FAT entry.
    # > a0: block index, a1: value
    .fat_set:
        cea MFS_DATA.fat_buf, a0, 2
        ste u16t, 0, a1
        ret

    sbmk "fat_flush()"
    # Flush the FAT buffer to storage.
    .fat_flush:
        mov a0, MFS_FAT_START_BLOCK * MFS_BLOCK_SIZE
        mov a1, MFS_DATA.fat_buf
        mov a2, MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
        syscall SYS_STORAGE_WRITE
        ret

    sbmk "dir_flush()"
    # Flush the directory buffer to storage.
    .dir_flush:
        mov a0, MFS_DIR_START_BLOCK * MFS_BLOCK_SIZE
        mov a1, MFS_DATA.dir_buf
        mov a2, MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        syscall SYS_STORAGE_WRITE
        ret

    sbmk "fat_free_chain(first_block)"
    # Release all blocks in a FAT chain back to free.
    # > a0: first block index
    .fat_free_chain:
        vpsh s0..s1
        mov s0, a0
        @loop:
            cmp eq, s0, MFS_FAT_EOF
            jtr @done+
            cmp eq, s0, MFS_FAT_FREE
            jtr @done+
            cea MFS_DATA.fat_buf, s0, 2
            lde u16t, s1, 0             # s1 = next block before freeing
            ste u16t, 0, MFS_FAT_FREE
            mov s0, s1
            jmp @loop-
        @done:
        vpop s0..s1
        ret

    sbmk "name_eq(dirent, query): bool"
    # Compare a dirent's name against a null-terminated query string.
    # > a0: pa-rel dirent pointer
    # > a1: pa-rel null-terminated query string
    # < a0: 1 if equal, 0 otherwise
    .name_eq:
        vpsh s0..s3
        # s0 = dirent name_len
        # s1 = pa-rel ptr to dirent name bytes
        # s2 = pa-rel ptr to query string
        # s3 = byte index
        cea a0, 0, 1
        lde u8t, s0, MFS_DIRENT_NAME_LEN
        add s1, a0, MFS_DIRENT_NAME
        mov s2, a1
        mov s3, 0
        @loop:
            cea s2, 0, 1
            lde u8t, t0, 0
            cmp eq, t0, 0
            jtr @query_end+
            cmp gte, s3, s0
            jtr @not_equal+
            cea s1, s3, 1
            lde u8t, t1, 0
            cmp neq, t0, t1
            jtr @not_equal+
            inc s2
            inc s3
            jmp @loop-
        @query_end:
            cmp eq, s3, s0
            jfs @not_equal+
            mov a0, 1
            jmp @done+
        @not_equal:
            mov a0, 0
        @done:
        vpop s0..s3
        ret

    sbmk "dirent_find(name): dirent | 0"
    # Walk the directory buffer and return a pa-rel pointer to the named entry.
    # > a0: pa-rel null-terminated filename
    # < a0: pa-rel dirent pointer, or 0 if not found
    .dirent_find:
        vpsh s0..s3
        # s0 = scan cursor, s1 = dir buf end, s2 = query name, s3 = rec_len
        mov s0, MFS_DATA.dir_buf
        mov s1, MFS_DATA.dir_buf + MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov s2, a0
        @loop:
            sub t0, s1, s0
            cmp lt, t0, MFS_DIRENT_MIN_REC_LEN
            jtr @not_found+
            cea s0, 0, 1
            lde u16t, s3, MFS_DIRENT_REC_LEN
            cmp eq, s3, 0
            jtr @not_found+
            lde u8t, t0, MFS_DIRENT_FLAGS
            and t0, MFS_FLAG_IN_USE
            cmp eq, t0, 0
            jtr @advance+
            mov a0, s0
            mov a1, s2
            cal .name_eq
            cmp eq, a0, 1
            jtr @found+
            @advance:
            add s0, s3
            jmp @loop-
        @not_found:
            mov a0, 0
            jmp @done+
        @found:
            mov a0, s0
        @done:
        vpop s0..s3
        ret

bmk "MFS - Public API"

MFS:

    sbmk "MFS.format()"
    # Write a fresh filesystem to storage and initialise the in-memory buffers.
    .format:
        # Zero all three buffers before writing
        mov a0, MFS_DATA.superblock
        mov a1, MFS_BLOCK_SIZE
        mov a2, 0
        syscall SYS_MEM_SET

        mov a0, MFS_DATA.fat_buf
        mov a1, MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
        mov a2, 0
        syscall SYS_MEM_SET

        mov a0, MFS_DATA.dir_buf
        mov a1, MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov a2, 0
        syscall SYS_MEM_SET

        # Fill superblock fields
        str u32t, MFS_DATA.superblock + MFS_SB_MAGIC,           MFS_MAGIC
        str u8t,  MFS_DATA.superblock + MFS_SB_VERSION,         MFS_VERSION
        str u8t,  MFS_DATA.superblock + MFS_SB_BLOCK_SIZE_LOG2, MFS_BLOCK_SIZE_LOG2
        str u16t, MFS_DATA.superblock + MFS_SB_BLOCK_COUNT,     MFS_DATA_BLOCK_COUNT
        str u16t, MFS_DATA.superblock + MFS_SB_FAT_START,       MFS_FAT_START_BLOCK
        str u16t, MFS_DATA.superblock + MFS_SB_FAT_BLOCK_COUNT, MFS_FAT_BLOCK_COUNT
        str u16t, MFS_DATA.superblock + MFS_SB_DIR_START,       MFS_DIR_START_BLOCK
        str u16t, MFS_DATA.superblock + MFS_SB_DIR_BLOCK_COUNT, MFS_DIR_BLOCK_COUNT
        str u16t, MFS_DATA.superblock + MFS_SB_DATA_START,      MFS_DATA_START_BLOCK
        str u16t, MFS_DATA.superblock + MFS_SB_FREE_COUNT,      MFS_DATA_BLOCK_COUNT

        # Flush superblock, FAT, and directory to storage
        mov a0, 0
        mov a1, MFS_DATA.superblock
        mov a2, MFS_BLOCK_SIZE
        syscall SYS_STORAGE_WRITE

        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        ret

    sbmk "MFS.load(): error"
    # Load the filesystem from storage into the in-memory buffers.
    # Verifies the superblock magic; returns MFS_ERR_INVALID on mismatch.
    # < a0: MFS_OK or MFS_ERR_INVALID
    .load:
        mov a0, MFS_DATA.superblock
        mov a1, 0
        mov a2, MFS_BLOCK_SIZE
        syscall SYS_STORAGE_READ

        lod u32t, t0, MFS_DATA.superblock + MFS_SB_MAGIC
        cmp neq, t0, MFS_MAGIC
        jtr @invalid+

        mov a0, MFS_DATA.fat_buf
        mov a1, MFS_FAT_START_BLOCK * MFS_BLOCK_SIZE
        mov a2, MFS_BLOCK_SIZE * MFS_FAT_BLOCK_COUNT
        syscall SYS_STORAGE_READ

        mov a0, MFS_DATA.dir_buf
        mov a1, MFS_DIR_START_BLOCK * MFS_BLOCK_SIZE
        mov a2, MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        syscall SYS_STORAGE_READ

        mov a0, MFS_OK
        ret

        @invalid:
        mov a0, MFS_ERR_INVALID
        ret

    sbmk "MFS.open(name): dirent | 0"
    # Find a file by name. Returns its pa-rel dirent pointer, or 0 if not found.
    # > a0: pa-rel null-terminated filename
    # < a0: pa-rel dirent pointer, or 0
    .open:
        tpr a0
        cal MFS_INTERNAL.dirent_find
        ret

    sbmk "MFS.create(name): error"
    # Create a new empty file entry in the directory.
    # Reuses a deleted entry if one is large enough; otherwise appends.
    # > a0: pa-rel null-terminated filename
    # < a0: MFS_OK, MFS_ERR_EXISTS, or MFS_ERR_NO_SPACE
    .create:
        vpsh s0..s4
        # s0 = filename, s1 = name_len, s2 = needed rec_len
        # s3 = scan cursor, s4 = dir buf end
        tpr a0
        mov s0, a0

        # Compute name_len via strlen
        mov s1, a0
        @strlen:
            cea s1, 0, 1
            lde u8t, t0, 0
            cmp eq, t0, 0
            jtr @strlen_done+
            inc s1
            jmp @strlen-
        @strlen_done:
        sub s1, s0

        # Reject if file already exists
        cal MFS_INTERNAL.dirent_find
        cmp neq, a0, 0
        jtr @exists+

        # needed rec_len = header + name_len, rounded up to 2-byte alignment
        add s2, MFS_DIRENT_HEADER_SIZE, s1
        and t0, s2, 1
        add s2, t0

        mov s3, MFS_DATA.dir_buf
        mov s4, MFS_DATA.dir_buf + MFS_BLOCK_SIZE * MFS_DIR_BLOCK_COUNT
        mov a0, 0                           # candidate slot (0 = none yet)

        # First-fit scan for a deleted entry with sufficient rec_len
        @scan:
            sub t0, s4, s3
            cmp lt, t0, MFS_DIRENT_MIN_REC_LEN
            jtr @scan_done+
            cea s3, 0, 1
            lde u16t, t0, MFS_DIRENT_REC_LEN
            cmp eq, t0, 0
            jtr @scan_done+
            lde u8t, t1, MFS_DIRENT_FLAGS
            and t1, MFS_FLAG_IN_USE
            cmp neq, t1, 0
            jtr @advance_scan+              # in-use: skip
            cmp lt, t0, s2
            jtr @advance_scan+              # too small: skip
            cmp neq, a0, 0
            jtr @advance_scan+              # already have a candidate: skip
            mov a0, s3
            @advance_scan:
            add s3, t0
            jmp @scan-
        @scan_done:

        cmp neq, a0, 0
        jtr @write_entry+

        # No free slot found; try to append at end of written entries (s3)
        sub t0, s4, s3
        cmp lt, t0, s2
        jtr @no_space+
        mov a0, s3

        @write_entry:
        mov s3, a0
        cea s3, 0, 1
        ste u16t, MFS_DIRENT_REC_LEN,     s2
        ste u8t,  MFS_DIRENT_NAME_LEN,    s1
        ste u8t,  MFS_DIRENT_FLAGS,       MFS_FLAG_IN_USE
        ste u16t, MFS_DIRENT_FIRST_BLOCK, MFS_FAT_EOF
        ste u32t, MFS_DIRENT_FILE_SIZE,   0
        add a0, s3, MFS_DIRENT_NAME
        mov a1, s0
        mov a2, s1
        syscall SYS_MEM_COPY

        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_OK
        jmp @done+

        @exists:
        mov a0, MFS_ERR_EXISTS
        jmp @done+

        @no_space:
        mov a0, MFS_ERR_NO_SPACE

        @done:
        vpop s0..s4
        ret

    sbmk "MFS.read(name, dst, max): bytes_read | -1"
    # Read a file's data into a buffer.
    # > a0: pa-rel null-terminated filename
    # > a1: pa-rel destination buffer
    # > a2: maximum bytes to read
    # < a0: bytes read, or -1 if file not found
    .read:
        vpsh s0..s5
        # s0 = dst buffer, s1 = max bytes / clamped file size
        # s2 = dirent ptr, s3 = current FAT block index, s4 unused, s5 = bytes read
        tpr a0
        tpr a1
        mov s0, a1
        mov s1, a2

        cal MFS_INTERNAL.dirent_find
        cmp eq, a0, 0
        jtr @not_found+
        mov s2, a0

        cea s2, 0, 1
        lde u16t, s3, MFS_DIRENT_FIRST_BLOCK
        lde u32t, t0, MFS_DIRENT_FILE_SIZE
        cmp lt, t0, s1
        mvc s1, t0                          # s1 = min(file_size, max)

        mov s5, 0                           # bytes read so far

        @loop:
            cmp gte, s5, s1
            jtr @done_reading+
            cmp eq, s3, MFS_FAT_EOF
            jtr @done_reading+

            # Read storage block s3 into block_buf
            add a1, MFS_DATA_START_BLOCK, s3
            sll a1, MFS_BLOCK_SIZE_LOG2
            mov a0, MFS_DATA.block_buf
            mov a2, MFS_BLOCK_SIZE
            syscall SYS_STORAGE_READ

            # Copy min(MFS_BLOCK_SIZE, remaining) bytes to destination
            sub t0, s1, s5
            cmp lt, t0, MFS_BLOCK_SIZE
            jfs @full_block+
            mov t1, t0
            jmp @do_copy+
            @full_block:
            mov t1, MFS_BLOCK_SIZE
            @do_copy:
            add a0, s0, s5
            mov a1, MFS_DATA.block_buf
            mov a2, t1
            syscall SYS_MEM_COPY
            add s5, t1

            # Advance FAT chain
            mov a0, s3
            cal MFS_INTERNAL.fat_get
            mov s3, a0
            jmp @loop-

        @done_reading:
        mov a0, s5
        jmp @done+

        @not_found:
        mov a0, -1

        @done:
        vpop s0..s5
        ret

    sbmk "MFS.write(name, src, size): error"
    # Replace a file's data with the contents of a buffer.
    # Frees the existing chain, allocates new blocks, then flushes FAT and directory.
    # > a0: pa-rel null-terminated filename
    # > a1: pa-rel source buffer
    # > a2: size in bytes
    # < a0: MFS_OK, MFS_ERR_NOT_FOUND, or MFS_ERR_NO_SPACE
    .write:
        vpsh s0..s5
        # s0 = src buffer, s1 = total size to write
        # s2 = dirent ptr, s3 = bytes written
        # s4 = first allocated block, s5 = last allocated block
        tpr a0
        tpr a1
        mov s0, a1
        mov s1, a2

        cal MFS_INTERNAL.dirent_find
        cmp eq, a0, 0
        jtr @not_found+
        mov s2, a0

        # Free the existing FAT chain
        cea s2, 0, 1
        lde u16t, a0, MFS_DIRENT_FIRST_BLOCK
        cmp eq, a0, MFS_FAT_EOF
        jtr @skip_free+
        cal MFS_INTERNAL.fat_free_chain
        @skip_free:

        mov s3, 0
        mov s4, MFS_FAT_EOF             # first block of new chain
        mov s5, MFS_FAT_EOF             # last block of new chain

        @loop:
            cmp gte, s3, s1
            jtr @done_writing+

            cal MFS_INTERNAL.fat_alloc
            cmp eq, a0, MFS_FAT_EOF
            jtr @no_space+

            # Record the first block of the chain
            cmp neq, s4, MFS_FAT_EOF
            jtr @not_first+
            mov s4, a0
            @not_first:

            # Link the previous block to this one
            cmp eq, s5, MFS_FAT_EOF
            jtr @no_prev+
            psh a0
            mov a1, a0
            mov a0, s5
            cal MFS_INTERNAL.fat_set
            pop a0
            @no_prev:
            mov s5, a0

            # Determine bytes to write for this block
            sub t0, s1, s3
            cmp lt, t0, MFS_BLOCK_SIZE
            jfs @full_write+
            mov t1, t0
            jmp @have_count+
            @full_write:
            mov t1, MFS_BLOCK_SIZE
            @have_count:

            # Copy from source into block_buf, zero-padding any remainder
            mov a0, MFS_DATA.block_buf
            add a1, s0, s3
            mov a2, t1
            syscall SYS_MEM_COPY

            cmp gte, t1, MFS_BLOCK_SIZE
            jtr @no_pad+
            add a0, MFS_DATA.block_buf, t1
            sub a1, MFS_BLOCK_SIZE, t1
            mov a2, 0
            syscall SYS_MEM_SET
            @no_pad:

            # Write block_buf to storage
            add a0, MFS_DATA_START_BLOCK, s5
            sll a0, MFS_BLOCK_SIZE_LOG2
            mov a1, MFS_DATA.block_buf
            mov a2, MFS_BLOCK_SIZE
            syscall SYS_STORAGE_WRITE

            add s3, t1
            jmp @loop-

        @done_writing:
        cea s2, 0, 1
        ste u16t, MFS_DIRENT_FIRST_BLOCK, s4
        ste u32t, MFS_DIRENT_FILE_SIZE,   s1
        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_OK
        jmp @done+

        @not_found:
        mov a0, MFS_ERR_NOT_FOUND
        jmp @done+

        @no_space:
        # Roll back any partially allocated blocks
        cmp eq, s4, MFS_FAT_EOF
        jtr @no_rollback+
        mov a0, s4
        cal MFS_INTERNAL.fat_free_chain
        @no_rollback:
        cea s2, 0, 1
        ste u16t, MFS_DIRENT_FIRST_BLOCK, MFS_FAT_EOF
        ste u32t, MFS_DIRENT_FILE_SIZE,   0
        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_ERR_NO_SPACE

        @done:
        vpop s0..s5
        ret

    sbmk "MFS.delete(name): error"
    # Delete a file: frees its FAT chain and clears its in-use flag.
    # The entry's rec_len is preserved so the directory walk stays intact;
    # MFS.create will reuse the slot when writing a file that fits.
    # > a0: pa-rel null-terminated filename
    # < a0: MFS_OK or MFS_ERR_NOT_FOUND
    .delete:
        vpsh s0..s1
        tpr a0
        mov s0, a0

        cal MFS_INTERNAL.dirent_find
        cmp eq, a0, 0
        jtr @not_found+
        mov s1, a0

        cea s1, 0, 1
        lde u16t, a0, MFS_DIRENT_FIRST_BLOCK
        cmp eq, a0, MFS_FAT_EOF
        jtr @skip_free+
        cal MFS_INTERNAL.fat_free_chain
        @skip_free:

        cea s1, 0, 1
        ste u8t, MFS_DIRENT_FLAGS, 0

        cal MFS_INTERNAL.fat_flush
        cal MFS_INTERNAL.dir_flush
        mov a0, MFS_OK
        jmp @done+

        @not_found:
        mov a0, MFS_ERR_NOT_FOUND

        @done:
        vpop s0..s1
        ret
