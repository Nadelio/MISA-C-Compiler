#ifndef SEMA_H
#define SEMA_H

#include "ast.h"
#include "symtab.h"
#include "asm_labels.h"

/*
 * Semantic analysis context.
 * Resolves types, checks declarations, and annotates AST nodes.
 */
typedef struct {
	SymTab  *symtab;
	int      had_error;
	Type    *current_func_ret; /* return type of the function being analyzed */
	int      loop_depth;       /* nesting depth of while/for/do loops */
	int      switch_depth;     /* nesting depth of switch statements */
	AsmLabelTable *asm_labels; /* labels from included .asm files */

} Sema;

void sema_init(Sema *s, SymTab *st);
void sema_analyze(Sema *s, AstNode *unit);  /* analyze a translation unit */

#endif /* SEMA_H */
