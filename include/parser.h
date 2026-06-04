#ifndef PARSER_H
#define PARSER_H

#include "lexer.h"
#include "ast.h"
#include "symtab.h"

/*
 * Recursive-descent parser for C89.
 */
typedef struct {
	Lexer   *lexer;
	Token    cur;       /* current (consumed) token */
	Token    peek;      /* one-token lookahead */
	int      had_error;
	SymTab  *symtab;    /* for typedef name disambiguation */
} Parser;

/*
 * Initialise the parser.
 */
void     parser_init(Parser *p, Lexer *l, SymTab *st);

/*
 * Parse a full translation unit and return its AST.
 */
AstNode *parser_parse(Parser *p);

#endif /* PARSER_H */
