#include "../src/mfs.asm"

extern void     MFS.format();
extern int      MFS.load();
extern void*    MFS.open(char *name);
extern int      MFS.create(char *name);
extern int      MFS.read(char *name, void *dst, int max);
extern int      MFS.write(char *name, void *src, int size);
extern int      MFS.delete(char *name);

