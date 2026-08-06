#include "../include/stdio.h"
#include "mfs/mfs.h"
#include "../../allocator.asm"
#include "printf.asm"
#include "sprintf.asm"
#include "sscanf.asm"

extern i16t  printf(string fmt, ...);
extern i16t  sprintf(string buf, string fmt, ...);
extern i16t  snprintf(string buf, u32t n, string fmt, ...);
extern i16t  sscanf(string str, string fmt, ...);
extern i16t  scanf(string fmt, ...);
extern void* malloc(u32t size);
extern void  free(void* ptr);
extern i32t  _get_file_size(string name);

extern void*  MFS.open(char *name);
extern int    MFS.create(char *name);
extern int    MFS.read(char *name, void *dst, int max);
extern int    MFS.write(char *name, void *src, int size);
extern int    MFS.delete(char *name);

#define _FMODE_READ   0
#define _FMODE_WRITE  1
#define _FMODE_APPEND 2
#define _MAX_FILES    8
#define _NAME_MAX     64
#define _MFS_MAX_SIZE 32768

typedef struct {
    FILE  f;
    char  name[_NAME_MAX];
    i16t  mode;
    i16t  in_use;
} _FileSlot;

static _FileSlot _file_pool[_MAX_FILES];
static char      _null_buf[1];

static char _gc_buf[257];
static u32t _gc_pos = 0;
static u32t _gc_len = 0;

i16t puts(string str) {
    println_string(str);
    return 0;
}

i16t putchar(i16t c) {
    char buf[2];
    buf[0] = (char)c;
    buf[1] = 0;
    print_string(buf);
    return c;
}

i16t getchar(void) {
    u32t sz;
    if (_gc_pos >= _gc_len) {
        sz = (u32t)get_terminal_input_size();
        if (sz == 0) return EOF;
        if (sz > 256) sz = 256;
        _gc_len = (u32t)read_terminal_input(_gc_buf, (int)sz);
        _gc_pos = 0;
    }
    if (_gc_pos >= _gc_len) return EOF;
    return (i16t)(u8t)_gc_buf[_gc_pos++];
}

static void _copy_name(_FileSlot *slot, string src) {
    i16t i = 0;
    while (src[i] && i < _NAME_MAX - 1) { slot->name[i] = src[i]; i++; }
    slot->name[i] = 0;
}

FILE* fopen(string filename, string mode) {
    i16t i;
    _FileSlot *slot = 0;
    i16t fmode;
    void *dirent;
    i32t fsz;

    for (i = 0; i < _MAX_FILES; i++) {
        if (!_file_pool[i].in_use) { slot = &_file_pool[i]; break; }
    }
    if (!slot) return 0;

    if (mode[0] == 'r')      fmode = _FMODE_READ;
    else if (mode[0] == 'w') fmode = _FMODE_WRITE;
    else if (mode[0] == 'a') fmode = _FMODE_APPEND;
    else return 0;

    if (fmode == _FMODE_READ) {
        dirent = MFS.open(filename);
        if (!dirent) return 0;
    } else {
        MFS.create(filename);
        dirent = MFS.open(filename);
        if (!dirent) return 0;
        if (fmode == _FMODE_WRITE)
            MFS.write(filename, _null_buf, 0);
    }

    slot->f.dirent = dirent;
    slot->f.pos    = 0;
    slot->f.flags  = 0;
    slot->mode     = fmode;
    slot->in_use   = 1;
    _copy_name(slot, filename);

    if (fmode == _FMODE_APPEND) {
        fsz = _get_file_size(slot->name);
        slot->f.pos = (fsz < 0) ? 0 : (u32t)fsz;
    }

    return &slot->f;
}

i16t fclose(FILE *stream) {
    _FileSlot *slot = (_FileSlot*)stream;
    if (!stream || !slot->in_use) return EOF;
    slot->in_use   = 0;
    stream->dirent = 0;
    stream->flags  = 0;
    stream->pos    = 0;
    return 0;
}

i16t remove(string filename) {
    return (i16t)MFS.delete(filename);
}

i16t rename(string old_name, string new_name) {
    i32t fsz;
    void *tmp;
    i16t ret;
    fsz = _get_file_size(old_name);
    if (fsz < 0) return -1;
    if (MFS.create(new_name) != 0) return -1;
    if (fsz > 0) {
        tmp = malloc((u32t)fsz);
        if (!tmp) { MFS.delete(new_name); return -1; }
        MFS.read(old_name, tmp, (int)fsz);
        MFS.write(new_name, tmp, (int)fsz);
        free(tmp);
    }
    ret = (i16t)MFS.delete(old_name);
    return ret;
}

i16t feof(FILE *stream) {
    if (!stream) return 0;
    return (stream->flags & _FILE_EOF) ? 1 : 0;
}

i16t ferror(FILE *stream) {
    if (!stream) return 0;
    return (stream->flags & _FILE_ERROR) ? 1 : 0;
}

i16t fseek(FILE *stream, i32t offset, i16t whence) {
    _FileSlot *slot = (_FileSlot*)stream;
    i32t fsz;
    i32t new_pos;
    if (!stream || !slot->in_use) return -1;
    if (whence == SEEK_SET)      new_pos = offset;
    else if (whence == SEEK_CUR) new_pos = (i32t)stream->pos + offset;
    else {  /* SEEK_END */
        fsz = _get_file_size(slot->name);
        new_pos = (fsz < 0 ? 0 : fsz) + offset;
    }
    if (new_pos < 0) return -1;
    stream->pos    = (u32t)new_pos;
    stream->flags &= ~_FILE_EOF;
    return 0;
}

i32t ftell(FILE *stream) {
    if (!stream) return -1;
    return (i32t)stream->pos;
}

void rewind(FILE *stream) {
    if (!stream) return;
    stream->pos    = 0;
    stream->flags &= ~(_FILE_EOF | _FILE_ERROR);
}

u32t fread(void *ptr, u32t size, u32t count, FILE *stream) {
    _FileSlot *slot = (_FileSlot*)stream;
    u32t total;
    i32t fsz;
    u32t file_size;
    u32t read_max;
    void *tmp;
    u32t got;
    u32t available;
    u32t to_copy;

    if (!stream || !slot->in_use || size == 0 || count == 0) return 0;
    total = size * count;

    fsz = _get_file_size(slot->name);
    if (fsz < 0) { stream->flags |= _FILE_ERROR; return 0; }
    file_size = (u32t)fsz;

    if (stream->pos >= file_size) { stream->flags |= _FILE_EOF; return 0; }

    read_max = stream->pos + total;
    if (read_max > file_size) read_max = file_size;

    tmp = malloc(read_max);
    if (!tmp) { stream->flags |= _FILE_ERROR; return 0; }

    got = (u32t)MFS.read(slot->name, tmp, (int)read_max);
    if (got <= stream->pos) {
        free(tmp);
        stream->flags |= _FILE_EOF;
        return 0;
    }

    available = got - stream->pos;
    to_copy   = available < total ? available : total;
    mem_copy(ptr, (u8t*)tmp + stream->pos, to_copy);
    free(tmp);

    stream->pos += to_copy;
    if (stream->pos >= file_size) stream->flags |= _FILE_EOF;
    return to_copy / size;
}

u32t fwrite(const void *ptr, u32t size, u32t count, FILE *stream) {
    _FileSlot *slot = (_FileSlot*)stream;
    u32t total;
    i32t fsz;
    u32t file_size;
    u32t new_size;
    void *tmp;

    if (!stream || !slot->in_use || size == 0 || count == 0) return 0;
    total = size * count;

    fsz       = _get_file_size(slot->name);
    file_size = (fsz < 0) ? 0 : (u32t)fsz;
    new_size  = stream->pos + total;
    if (new_size < file_size) new_size = file_size;

    tmp = malloc(new_size);
    if (!tmp) { stream->flags |= _FILE_ERROR; return 0; }

    if (file_size > 0)
        MFS.read(slot->name, tmp, (int)file_size);

    if (stream->pos > file_size)
        mem_set((u8t*)tmp + file_size, stream->pos - file_size, 0);

    mem_copy((u8t*)tmp + stream->pos, (void*)ptr, total);
    MFS.write(slot->name, tmp, (int)new_size);
    free(tmp);

    stream->pos += total;
    return count;
}

i16t fgetc(FILE *stream) {
    u8t c;
    u32t got;
    got = fread(&c, 1, 1, stream);
    return (got == 1) ? (i16t)c : EOF;
}

i16t fputc(i16t c, FILE *stream) {
    u8t b = (u8t)c;
    return (fwrite(&b, 1, 1, stream) == 1) ? c : EOF;
}

i16t getc(FILE *stream)          { return fgetc(stream); }
i16t putc(i16t c, FILE *stream)  { return fputc(c, stream); }

string fgets(string str, i16t n, FILE *stream) {
    i16t i = 0;
    i16t c;
    if (n <= 0) return 0;
    while (i < n - 1) {
        c = fgetc(stream);
        if (c == EOF) break;
        str[i++] = (char)c;
        if (c == '\n') break;
    }
    if (i == 0 && feof(stream)) return 0;
    str[i] = 0;
    return str;
}

i16t fputs(string str, FILE *stream) {
    u32t len = 0;
    while (str[len]) len++;
    return (fwrite(str, 1, len, stream) == len) ? 0 : EOF;
}

i16t fprintf(FILE *stream, string format, ...) {
    (void)stream; (void)format;
    return -1;
}

i16t fscanf(FILE *stream, string format, ...) {
    (void)stream; (void)format;
    return -1;
}
