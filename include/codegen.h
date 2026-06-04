#ifndef CODEGEN_H
#define CODEGEN_H

#include <stdio.h>
#include "ast.h"
#include "symtab.h"

/*
 * Code generator — emits MISA assembly to an output FILE.
 *
 * Register allocation strategy:
 *   - t0..t14  : temporaries for expression evaluation
 *   - a0..a15  : function arguments / return value
 *   - s*       : not used (all locals live on the stack)
 *   - t15      : scratch register (reserved)
 *
 * Stack frame layout (after 'cal'):
 *   [fp+4]        = return address  (saved by cal)
 *   [fp+0]        = old fp          (saved by cal)
 *   [fp-4]        = param 0
 *   [fp-8]        = param 1
 *    ...
 *   [fp - FSIZE]  = last local  (sp points here)
 */
typedef struct {
	FILE    *out;
	SymTab  *symtab;
	int      had_error;

	/* Label counter for generating unique labels */
	int      label_counter;

	/* String literal pool */
	struct StrEntry {
		char *value;
		int   id;
	}       *strings;
	int      str_count;
	int      str_cap;

	/* Current function's frame info */
	int      frame_size;      /* total bytes allocated for locals+params */
	char    *func_end_label;  /* label at function epilogue */

	/* Break / continue targets (for loops / switch) */
	char    *break_label;
	char    *continue_label;

	/* Switch info */
	char   **switch_cases;    /* dynamically built during switch body scan */
	int      in_switch;

	/* Temp register allocator */
	int      temp_used[15];   /* t0..t14 */
} CodeGen;

void codegen_init(CodeGen *cg, FILE *out, SymTab *st);
void codegen_emit(CodeGen *cg, AstNode *unit);
void codegen_free(CodeGen *cg);

#endif /* CODEGEN_H */
