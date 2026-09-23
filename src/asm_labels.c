#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "asm_labels.h"

typedef struct AsmLabelEntry {
	char                  *name;
	AsmLabelKind           kind;
	struct AsmLabelEntry  *next;
} AsmLabelEntry;

struct AsmLabelTable {
	AsmLabelEntry *head;
};

/* rescanning a name overwrites the old entry */
static void add_label(AsmLabelTable *t, const char *name, AsmLabelKind kind) {
	AsmLabelEntry *e;
	for (e = t->head; e; e = e->next) {
		if (strcmp(e->name, name) == 0) { e->kind = kind; return; }
	}
	e = (AsmLabelEntry *)malloc(sizeof(AsmLabelEntry));
	if (!e) return; /* best-effort return w/ malloc fail */
	e->name = strdup(name);
	if (!e->name) { free(e); return; } /* if strdup NULL, free e */
	e->kind = kind;
	e->next = t->head;
	t->head = e;
}

/* reads a file into a NULL terminated heap buf, or ret
 * NULL if it can't be opened. */
static char *read_file(const char *path) {
	FILE *f = fopen(path, "rb");
	long  len;
	char *buf;
	if (!f) return NULL;
	fseek(f, 0, SEEK_END);
	len = ftell(f);
	fseek(f, 0, SEEK_SET);
	if (len < 0) { fclose(f); return NULL; }
	buf = (char *)malloc((size_t)len + 1);
	if (!buf) { fclose(f); return NULL; }
	if (fread(buf, 1, (size_t)len, f) != (size_t)len) {
		free(buf);
		fclose(f);
		return NULL;
	}
	buf[len] = '\0';
	fclose(f);
	return buf;
}

static int is_ident_char(char c) {
	return isalnum((unsigned char)c) || c == '_';
}

static void strip_comment(char *line) {
	char *h = strchr(line, '#');
	if (h) *h = '\0';
}

static void rstrip(char *line) {
	size_t n = strlen(line);
	while (n > 0 && isspace((unsigned char)line[n - 1])) line[--n] = '\0';
}

/* true if the next word is "emb" or "res" */
static int line_has_data_directive(const char *rest) {
	while (*rest && isspace((unsigned char)*rest)) rest++;
	if (strncmp(rest, "emb", 3) == 0 && !is_ident_char(rest[3])) return 1;
	if (strncmp(rest, "res", 3) == 0 && !is_ident_char(rest[3])) return 1;
	return 0;
}

static void scan_file(AsmLabelTable *t, const char *path) {
	char  *src = read_file(path);
	char  *cursor;
	char   global[256];

	if (!src) return;
	global[0] = '\0';

	cursor = src;
	while (*cursor) {
		char   *line_end = strchr(cursor, '\n');
		size_t  len = line_end ? (size_t)(line_end - cursor) : strlen(cursor);
		char    line[256];
		char   *p;

		if (len >= sizeof line) len = sizeof line - 1;
		memcpy(line, cursor, len);
		line[len] = '\0';

		p = line;
		strip_comment(p);
		while (*p && isspace((unsigned char)*p)) p++;
		rstrip(p);

		if (*p) {
			int is_local = (*p == '.');
			if (is_local) p++;

			if (isalpha((unsigned char)*p) || *p == '_') {
				char *start = p;
				while (is_ident_char(*p)) p++;
				if (*p == ':') {
					char name[320]; /* global[256] + '.' + a local identifier */
					name[0] = '\0';
					if (is_local) {
						if (global[0] != '\0')
							snprintf(name, sizeof name, "%s.%.*s",
							    global, (int)(p - start), start);
					} else {
						snprintf(name, sizeof name, "%.*s",
						    (int)(p - start), start);
						strncpy(global, name, sizeof global - 1);
						global[sizeof global - 1] = '\0';
					}
					if (name[0]) {
						p++; /* past ':' */
						add_label(t, name, line_has_data_directive(p)
						    ? ASM_LABEL_DATA : ASM_LABEL_CODE);
					}
				}
			}
			/* reusable labels (e.g. '@name:') aren't reachable via the
			 * dotted extern syntax, skipped */
		}

		cursor = line_end ? line_end + 1 : cursor + strlen(cursor);
	}
	free(src);
}

AsmLabelTable *asm_labels_scan(char **paths, int count) {
	AsmLabelTable *t = (AsmLabelTable *)calloc(1, sizeof(AsmLabelTable));
	int i;
	if (!t) return NULL;
	for (i = 0; i < count; i++) scan_file(t, paths[i]);
	return t;
}

AsmLabelKind asm_labels_lookup(const AsmLabelTable *t, const char *name) {
	AsmLabelEntry *e;
	if (!t) return ASM_LABEL_UNKNOWN;
	for (e = t->head; e; e = e->next)
		if (strcmp(e->name, name) == 0) return e->kind;
	return ASM_LABEL_UNKNOWN;
}

void asm_labels_free(AsmLabelTable *t) {
	AsmLabelEntry *e;
	if (!t) return;
	e = t->head;
	while (e) {
		AsmLabelEntry *next = e->next;
		free(e->name);
		free(e);
		e = next;
	}
	free(t);
}