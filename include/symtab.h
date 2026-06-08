#ifndef SYMTAB_H
#define SYMTAB_H

#include "type.h"

/*
 * Symbol kinds.
 */
typedef enum {
	SYM_VAR,        /* variable (global or local) */
	SYM_FUNC,       /* function */
	SYM_TYPEDEF,    /* typedef alias */
	SYM_ENUM_CONST, /* enum constant */
	SYM_STRUCT_TAG, /* struct tag */
	SYM_UNION_TAG,  /* union tag */
	SYM_ENUM_TAG    /* enum tag */
} SymKind;

/*
 * Built-in function IDs (syscall wrappers).
 * BUILTIN_NONE means the symbol is not a built-in.
 */
typedef enum {
	BUILTIN_NONE = 0,
	BUILTIN_PRINT_INT,
	BUILTIN_PRINT_FLOAT,
	BUILTIN_PRINT_STRING,
	BUILTIN_DRAW_RECT,
	BUILTIN_DRAW_TEXTURE,
	BUILTIN_DRAW_TEXTURE_REGION,
	BUILTIN_STORAGE_READ,
	BUILTIN_STORAGE_WRITE,
	BUILTIN_MEM_COPY,
	BUILTIN_MEM_SET,
	BUILTIN_PRESERVE_BACK_BUFFER,
	BUILTIN_PRESERVE_FRONT_BUFFER,
	BUILTIN_GET_INPUT,
	BUILTIN_GET_UNIX_TIME,
	BUILTIN_GET_RUNNING_TIME,
	BUILTIN_GET_UPDATE_DELTA,
	BUILTIN_GET_DRAW_DELTA,
	BUILTIN_SET_RNG_SEED,
	BUILTIN_SYSCALL,
	BUILTIN_TO_PA
} BuiltinId;

/*
 * A symbol table entry.
 */
typedef struct Symbol {
	char         *name;
	SymKind       kind;
	Type         *type;

	/* SYM_VAR: where is the variable? */
	int           is_global;    /* 1 = global, 0 = local */
	int           is_extern;    /* 1 = extern (label is exact C name, no g__ prefix) */
	int           is_param_ptr; /* 1 = struct/union param passed as pointer */
	int           fp_offset;    /* local: byte offset from fp (negative) */
	char         *asm_label;    /* global: assembly label name */

	/* SYM_FUNC */
	char         *func_label;   /* assembly label for the function */
	BuiltinId     builtin_id;   /* non-zero if this is a syscall wrapper */

	/* SYM_ENUM_CONST */
	long long     enum_value;

	struct Symbol *next;        /* hash-chain next */
} Symbol;

/*
 * A scope (one level of the symbol table).
 */
typedef struct Scope {
	Symbol      *buckets[64];
	struct Scope *parent;
} Scope;

/*
 * The symbol table — a stack of scopes.
 */
typedef struct {
	Scope *current;
	Scope *file_scope; /* outermost scope */
} SymTab;

/* Scope management */
SymTab *symtab_new(void);
void    symtab_free(SymTab *st);
void    symtab_push(SymTab *st);   /* enter a new scope */
void    symtab_pop(SymTab *st);    /* leave current scope */

/* Symbol operations */
Symbol *symtab_define(SymTab *st, const char *name, SymKind kind, Type *type);
Symbol *symtab_lookup(SymTab *st, const char *name);
Symbol *symtab_lookup_current(SymTab *st, const char *name);

/* Tag (struct/union/enum) lookup — searched across all scopes */
Symbol *symtab_lookup_tag(SymTab *st, const char *tag, SymKind kind);
Symbol *symtab_define_tag(SymTab *st, const char *tag, SymKind kind, Type *type);

#endif /* SYMTAB_H */
