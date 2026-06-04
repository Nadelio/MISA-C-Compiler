#ifndef LEXER_H
#define LEXER_H

#include "token.h"

/*
 * Lexer / preprocessor state.
 * Handles tokenizing C89 source with basic preprocessing.
 */
typedef struct {
	const char *src;        /* source text (not owned) */
	int         pos;        /* current position in src */
	int         len;        /* length of src */
	int         line;
	int         col;
	const char *filename;

	/* Simple #define macro table (object-like, integer/float only) */
	struct MacroDef {
		char *name;
		char *body;
	}          *macros;
	int         macro_count;
	int         macro_cap;

	/* One token of lookahead */
	Token       lookahead;
	int         has_lookahead;

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
