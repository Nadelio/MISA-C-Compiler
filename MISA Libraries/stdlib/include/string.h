#include "types.h"

// memory
void*  memchr(const void *ptr, i16t value, u32t num);
i16t   memcmp(const void *ptr1, const void *ptr2, u32t num);
void*  memcpy(void *dest, const void *src, u32t num);
void*  memmove(void *dest, const void *src, u32t num);
void*  memset(void *ptr, i16t value, u32t num);

// string operations
string strcat(string dest, string src);
string strchr(string str, i16t character);
i16t   strcmp(string str1, string str2);
i16t   strcoll(string str1, string str2); // locale-aware strcmp
string strcpy(string dest, string src);
u32t   strcspn(string str, string reject); // length before any char in reject
string strerror(i16t errnum);
u32t   strlen(string str);
string strncat(string dest, string src, u32t num);
i16t   strncmp(string str1, string str2, u32t num);
string strncpy(string dest, string src, u32t num);
string strpbrk(string str, string accept); // first char in str that's in accept
string strrchr(string str, i16t character);
u32t   strspn(string str, string accept);  // length of leading chars all in accept
string strstr(string haystack, string needle);
string strtok(string str, string delimiters);
u32t   strxfrm(string dest, string src, u32t num);