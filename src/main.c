#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexer.h"
#include "parser.h"
#include "sema.h"
#include "codegen.h"
#include "symtab.h"

static char *read_file(const char *path, int *out_len) {
	FILE *f = fopen(path, "rb");
	if (!f) return NULL;
	fseek(f, 0, SEEK_END);
	long sz = ftell(f);
	rewind(f);
	char *buf = (char *)malloc(sz + 1);
	if (!buf) { fclose(f); return NULL; }
	fread(buf, 1, sz, f);
	buf[sz] = '\0';
	fclose(f);
	if (out_len) *out_len = (int)sz;
	return buf;
}

static void usage(const char *prog) {
	fprintf(stderr, "Usage: %s <input.c> [-o output.misa]\n", prog);
}

int main(int argc, char **argv) {
	const char *input_path  = NULL;
	const char *output_path = NULL;
	int i;

	for (i = 1; i < argc; i++) {
		if (!strcmp(argv[i], "-o") && i + 1 < argc) {
			output_path = argv[++i];
		} else if (!strcmp(argv[i], "-h") || !strcmp(argv[i], "--help")) {
			usage(argv[0]);
			return 0;
		} else if (argv[i][0] != '-') {
			input_path = argv[i];
		} else {
			fprintf(stderr, "Unknown option: %s\n", argv[i]);
			usage(argv[0]);
			return 1;
		}
	}

	if (!input_path) {
		fprintf(stderr, "Error: no input file specified.\n");
		usage(argv[0]);
		return 1;
	}

	int src_len = 0;
	char *src = read_file(input_path, &src_len);
	if (!src) {
		fprintf(stderr, "Error: cannot open '%s'\n", input_path);
		return 1;
	}

	Lexer  lexer;
	lexer_init(&lexer, src, src_len, input_path);

	SymTab *symtab = symtab_new();

	Parser parser;
	parser_init(&parser, &lexer, symtab);

	AstNode *ast = parser_parse(&parser);

	if (lexer.had_error || parser.had_error) {
		fprintf(stderr, "Compilation failed (parse errors).\n");
		ast_free(ast);
		symtab_free(symtab);
		lexer_free(&lexer);
		free(src);
		return 1;
	}

	Sema sema;
	sema_init(&sema, symtab);
	sema_analyze(&sema, ast);

	if (sema.had_error) {
		fprintf(stderr, "Compilation failed (semantic errors).\n");
		ast_free(ast);
		symtab_free(symtab);
		lexer_free(&lexer);
		free(src);
		return 1;
	}

	FILE *out;
	if (output_path) {
		out = fopen(output_path, "w");
		if (!out) {
			fprintf(stderr, "Error: cannot open output file '%s'\n", output_path);
			ast_free(ast);
			symtab_free(symtab);
			lexer_free(&lexer);
			free(src);
			return 1;
		}
	} else {
		out = stdout;
	}

	CodeGen cg;
	codegen_init(&cg, out, symtab);
	codegen_emit(&cg, ast);
	codegen_free(&cg);

	if (output_path) fclose(out);

	ast_free(ast);
	symtab_free(symtab);
	lexer_free(&lexer);
	free(src);

	if (cg.had_error) {
		fprintf(stderr, "Compilation failed (codegen errors).\n");
		return 1;
	}

	return 0;
}
