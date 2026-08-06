#include "../include/ctype.h"

i16t isdigit(i16t c) { return c >= '0' && c <= '9'; }
i16t isupper(i16t c) { return c >= 'A' && c <= 'Z'; }
i16t islower(i16t c) { return c >= 'a' && c <= 'z'; }
i16t isalpha(i16t c) { return isupper(c) || islower(c); }
i16t isalnum(i16t c) { return isalpha(c) || isdigit(c); }
i16t isblank(i16t c) { return c == ' ' || c == '\t'; }
i16t isspace(i16t c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\v' || c == '\f'; }
i16t isprint(i16t c) { return c >= ' ' && c <= '~'; }
i16t isgraph(i16t c) { return c > ' ' && c <= '~'; }
i16t ispunct(i16t c) { return isgraph(c) && !isalnum(c); }
i16t iscntrl(i16t c) { return (c >= 0 && c <= 0x1F) || c == 0x7F; }
i16t isxdigit(i16t c) { return isdigit(c) || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f'); }
i16t tolower(i16t c)  { return isupper(c) ? c + ('a' - 'A') : c; }
i16t toupper(i16t c)  { return islower(c) ? c - ('a' - 'A') : c; }
