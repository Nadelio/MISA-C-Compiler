#ifndef _STDARG_H
#define _STDARG_H

typedef unsigned char *va_list;

#define va_start(list, last_named) ((list) = (unsigned char *)&(last_named) - 4)
#define va_arg(list, type) (*(type *)(((list) -= 4) + 4))
#define va_end(list) ((void)(list))
#define va_copy(destination, source) ((destination) = (source))

#endif