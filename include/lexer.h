#ifndef LEXER_H
#define LEXER_H

#include "token.h"

/*
 * Saved state for one level of #include nesting.
 */
typedef struct {
	const char *src;
	char       *owned_buf;     /* heap buf for this level, or NULL */
	int         pos;
	int         len;
	int         line;
	int         col;
	const char *filename;
	int         filename_owned;
} IncludeFrame;

/*
 * Lexer / preprocessor state.
 * Handles tokenizing C89 source with basic preprocessing.
 */
typedef struct {
	const char *src;        /* source text */
	int         pos;        /* current position in src */
	int         len;        /* length of src */
	int         line;
	int         col;
	const char *filename;

	/* Ownership of the current src buffer (from an #include) */
	char       *owned_buf;
	int         filename_owned;

	/* Include file stack */
	IncludeFrame *include_stack;
	int           include_depth;
	int           include_cap;

	/* Already-included file paths (include-once semantics) */
	char      **seen_includes;
	int         seen_count;
	int         seen_cap;

	/* Simple #define macro table (object-like, integer/float only) */
	struct MacroDef {
		char *name;
		char *body;
	}          *macros;
	int         macro_count;
	int         macro_cap;

	/* Collected .asm include paths from #include directives */
	char      **asm_includes;
	int         asm_include_count;
	int         asm_include_cap;

	/* One token of lookahead */
	Token       lookahead;
	int         has_lookahead;

	/* Pending doc comment fields (transferred to the next token) */
	char       *pending_doc_brief;
	char       *pending_doc_details;
	char      **pending_doc_param_names; /* @param: names */
	char      **pending_doc_param_descs; /* @param: descriptions */
	int         pending_doc_param_count;
	int         pending_doc_param_cap;
	char       *pending_doc_return;      /* @return */

	/* Error flag */
	int         had_error;
} Lexer;

/*
 * Initialise a lexer over 'src' (must remain valid for the lexer's lifetime).
 */
void  lexer_init(Lexer *l, const char *src, int len, const char *filename);
void  lexer_free(Lexer *l);

/*
 * Return the next token, advancing the lexer.
 * The caller owns the Token's 'text' field and must free it.
 */
Token lexer_next(Lexer *l);

/*
 * Peek at the next token without consuming it.
 * The returned pointer is valid until the next call to lexer_next/lexer_peek.
 */
const Token *lexer_peek(Lexer *l);

/*
 * Emit an error and return a TOK_ERROR token.
 */
Token lexer_error(Lexer *l, const char *msg);

#endif /* LEXER_H */
