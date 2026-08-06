#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "symtab.h"

#define BUCKET_COUNT 64

static unsigned int hash_str(const char *s) {
	unsigned int h = 5381;
	while (*s) h = h * 33 ^ (unsigned char)*s++;
	return h % BUCKET_COUNT;
}

static Scope *scope_new(Scope *parent) {
	Scope *s = (Scope *)calloc(1, sizeof(Scope));
	s->parent = parent;
	return s;
}

static void scope_free(Scope *s) {
	int i;
	for (i = 0; i < BUCKET_COUNT; i++) {
		Symbol *sym = s->buckets[i];
		while (sym) {
			Symbol *next = sym->next;
			free(sym->name);
			free(sym->asm_label);
			free(sym->func_label);
			free(sym);
			sym = next;
		}
	}
	free(s);
}

static const char *const kernel_entry_names[] = {
	"draw", "mouse_button_input", "update",
	"input", "terminal_input", NULL
};

char *func_label_for(const char *name, int is_extern) {
	if (is_extern || name[0] == '_') return strdup(name);
	for (int i = 0; kernel_entry_names[i]; i++) {
		if (strcmp(name, kernel_entry_names[i]) == 0) {
			char *lbl = (char *)malloc(strlen(name) + 2);
			sprintf(lbl, "_%s", name);
			return lbl;
		}
	}
	char *lbl = (char *)malloc(strlen(name) + 2);
	sprintf(lbl, "%s_", name);
	return lbl;
}

int symtab_is_kernel_entry(const char *name) {
	for (int i = 0; kernel_entry_names[i]; i++)
		if (strcmp(name, kernel_entry_names[i]) == 0) return 1;
	return 0;
}

SymTab *symtab_new(void) {
	SymTab *st = (SymTab *)malloc(sizeof(SymTab));
	st->file_scope = scope_new(NULL);
	st->current    = st->file_scope;
	return st;
}

void symtab_free(SymTab *st) {
	Scope *s = st->current;
	while (s) {
		Scope *parent = s->parent;
		scope_free(s);
		s = parent;
	}
	free(st);
}

void symtab_push(SymTab *st) {
	st->current = scope_new(st->current);
}

void symtab_pop(SymTab *st) {
	Scope *dead = st->current;
	st->current = dead->parent;
	scope_free(dead);
}

Symbol *symtab_define(SymTab *st, const char *name, SymKind kind, Type *type) {
	unsigned int  h   = hash_str(name);
	Scope        *sc  = st->current;
	Symbol       *sym = (Symbol *)calloc(1, sizeof(Symbol));
	sym->name = strdup(name);
	sym->kind = kind;
	sym->type = type;
	sym->next = sc->buckets[h];
	sc->buckets[h] = sym;
	return sym;
}

Symbol *symtab_lookup(SymTab *st, const char *name) {
	Scope *sc = st->current;
	unsigned int h = hash_str(name);
	while (sc) {
		Symbol *sym = sc->buckets[h];
		while (sym) {
			if (!strcmp(sym->name, name)) return sym;
			sym = sym->next;
		}
		sc = sc->parent;
	}
	return NULL;
}

Symbol *symtab_lookup_current(SymTab *st, const char *name) {
	unsigned int h = hash_str(name);
	Symbol *sym = st->current->buckets[h];
	while (sym) {
		if (!strcmp(sym->name, name)) return sym;
		sym = sym->next;
	}
	return NULL;
}

Symbol *symtab_lookup_tag(SymTab *st, const char *tag, SymKind kind) {
	Scope *sc = st->current;
	unsigned int h = hash_str(tag);
	while (sc) {
		Symbol *sym = sc->buckets[h];
		while (sym) {
			if (sym->kind == kind && !strcmp(sym->name, tag)) return sym;
			sym = sym->next;
		}
		sc = sc->parent;
	}
	return NULL;
}

Symbol *symtab_define_tag(SymTab *st, const char *tag, SymKind kind, Type *type) {
	Symbol *existing = symtab_lookup_tag(st, tag, kind);
	if (existing) return existing;
	return symtab_define(st, tag, kind, type);
}
