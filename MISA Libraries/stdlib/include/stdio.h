#include "types.h"

#define EOF      (-1)
#define NULL     ((void*)0)
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

// FILE flag bits
#define _FILE_EOF   0x01
#define _FILE_ERROR 0x02

typedef struct {
    void*  dirent;  // MFS dirent pointer (from MFS.open); NULL if not open
    u32t   pos;     // byte position indicator
    i16t   flags;   // _FILE_EOF / _FILE_ERROR state
} FILE;

// file operations
i16t   fclose(FILE* stream);
i16t   feof(FILE* stream);
i16t   ferror(FILE* stream);
i16t   fgetc(FILE* stream);
string fgets(string str, i16t n, FILE* stream);
FILE*  fopen(string filename, string mode);
i16t   fprintf(FILE* stream, string format, ...);
i16t   fputc(i16t c, FILE* stream);
i16t   fputs(string str, FILE* stream);
u32t   fread(void* ptr, u32t size, u32t count, FILE* stream);
i16t   fscanf(FILE* stream, string format, ...);
i16t   fseek(FILE* stream, i32t offset, i16t whence);
i32t   ftell(FILE* stream);
u32t   fwrite(const void* ptr, u32t size, u32t count, FILE* stream);
i16t   getc(FILE* stream);
i16t   getchar(void);
extern i16t   printf(string format, ...);
i16t   putc(i16t c, FILE* stream);
i16t   putchar(i16t c);
i16t   puts(string str);
i16t   remove(string filename);
i16t   rename(string old_name, string new_name);
void   rewind(FILE* stream);
extern i16t   scanf(string format, ...);
extern i16t   snprintf(string str, u32t n, string format, ...);
extern i16t   sprintf(string str, string format, ...);
extern i16t   sscanf(string str, string format, ...);

#include "../src/stdio.c"