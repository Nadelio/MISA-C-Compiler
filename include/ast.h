#ifndef AST_H
#define AST_H

#include "token.h"
#include "type.h"

/*
 * AST node kinds.
 */
typedef enum {
	/* Top-level */
	AST_TRANSLATION_UNIT,

	/* Declarations */
	AST_FUNC_DEF,
	AST_FUNC_DECL,       /* forward / extern declaration */
	AST_VAR_DECL,        /* global or local variable */
	AST_STRUCT_DEF,
	AST_UNION_DEF,
	AST_ENUM_DEF,
	AST_TYPEDEF_DECL,

	/* Statements */
	AST_BLOCK,
	AST_EXPR_STMT,
	AST_IF,
	AST_WHILE,
	AST_DO_WHILE,
	AST_FOR,
	AST_SWITCH,
	AST_CASE,
	AST_DEFAULT,
	AST_RETURN,
	AST_BREAK,
	AST_CONTINUE,
	AST_GOTO,
	AST_LABEL_STMT,
	AST_NULL_STMT,

	/* Expressions */
	AST_ASSIGN,          /* lhs op= rhs */
	AST_TERNARY,
	AST_BINARY,
	AST_CAST,
	AST_UNARY_PRE,       /* prefix unary: ++x, --x, &x, *x, -x, ~x, !x */
	AST_UNARY_POST,      /* postfix unary: x++, x-- */
	AST_SIZEOF_TYPE,
	AST_SIZEOF_EXPR,
	AST_CALL,
	AST_SUBSCRIPT,
	AST_MEMBER,          /* a.b */
	AST_PTR_MEMBER,      /* a->b */
	AST_COMMA_EXPR,

	/* Atoms */
	AST_INT_LIT,
	AST_FLOAT_LIT,
	AST_CHAR_LIT,
	AST_STRING_LIT,
	AST_IDENT
} AstKind;

typedef struct AstNode AstNode;
typedef struct AstList AstList;

/*
 * Singly-linked list of AST nodes.
 */
struct AstList {
	AstNode *node;
	AstList *next;
};

/*
 * A single AST node.
 * The 'type' field is filled in by semantic analysis.
 * The 'is_lvalue' field is set by semantic analysis.
 */
struct AstNode {
	AstKind   kind;
	int       line;
	Type     *type;       /* resolved type (sema) */
	int       is_lvalue;  /* 1 if addressable (sema) */

	union {
		/* AST_TRANSLATION_UNIT */
		struct {
			AstList *decls;
		} unit;

		/*
		 * AST_FUNC_DEF / AST_FUNC_DECL
		 * params is a list of AST_VAR_DECL nodes.
		 */
		struct {
			char    *name;
			Type    *func_type;   /* TY_FUNCTION */
			AstList *params;      /* param AST_VAR_DECL nodes */
			AstNode *body;        /* AST_BLOCK (NULL for decl) */
			int      is_static;
			int      is_extern;
		} func;

		/* AST_VAR_DECL */
		struct {
			char    *name;
			Type    *var_type;
			AstNode *init;        /* initializer, or NULL */
			int      is_static;
			int      is_extern;
			int      is_param;    /* 1 if function parameter */
		} var;

		/* AST_STRUCT_DEF / AST_UNION_DEF */
		struct {
			Type    *struct_type;
		} struct_def;

		/* AST_ENUM_DEF: handled via symbol table */

		/* AST_TYPEDEF_DECL */
		struct {
			char *name;
			Type *alias_type;
		} typedef_decl;

		/* AST_BLOCK */
		struct {
			AstList *items;  /* declarations and statements */
		} block;

		/* AST_EXPR_STMT */
		struct {
			AstNode *expr;
		} expr_stmt;

		/* AST_IF */
		struct {
			AstNode *cond;
			AstNode *then_stmt;
			AstNode *else_stmt;  /* may be NULL */
		} if_stmt;

		/* AST_WHILE / AST_DO_WHILE */
		struct {
			AstNode *cond;
			AstNode *body;
		} while_stmt;

		/* AST_FOR */
		struct {
			AstNode *init;   /* expr_stmt or var_decl or NULL */
			AstNode *cond;   /* or NULL */
			AstNode *incr;   /* or NULL */
			AstNode *body;
		} for_stmt;

		/* AST_SWITCH */
		struct {
			AstNode *expr;
			AstNode *body;
		} switch_stmt;

		/* AST_CASE */
		struct {
			AstNode *expr;    /* constant expression */
			AstNode *stmt;
		} case_stmt;

		/* AST_DEFAULT */
		struct {
			AstNode *stmt;
		} default_stmt;

		/* AST_RETURN */
		struct {
			AstNode *expr;   /* may be NULL */
		} ret_stmt;

		/* AST_GOTO */
		struct {
			char *label;
		} goto_stmt;

		/* AST_LABEL_STMT */
		struct {
			char    *name;
			AstNode *stmt;
		} label_stmt;

		/* AST_ASSIGN */
		struct {
			int      op;     /* TOK_ASSIGN, TOK_PLUS_ASSIGN, etc. */
			AstNode *lhs;
			AstNode *rhs;
		} assign;

		/* AST_BINARY / AST_COMMA_EXPR */
		struct {
			int      op;     /* TokenType */
			AstNode *left;
			AstNode *right;
		} binary;

		/* AST_TERNARY */
		struct {
			AstNode *cond;
			AstNode *then_expr;
			AstNode *else_expr;
		} ternary;

		/* AST_CAST */
		struct {
			Type    *cast_type;
			AstNode *expr;
		} cast;

		/* AST_UNARY_PRE / AST_UNARY_POST */
		struct {
			int      op;
			AstNode *operand;
		} unary;

		/* AST_SIZEOF_TYPE */
		struct {
			Type *sizeof_type;
		} sizeof_type;

		/* AST_SIZEOF_EXPR */
		struct {
			AstNode *sizeof_expr;
		} sizeof_expr;

		/* AST_CALL */
		struct {
			AstNode *callee;
			AstList *args;
			int      argc;
		} call;

		/* AST_SUBSCRIPT */
		struct {
			AstNode *base;
			AstNode *index;
		} subscript;

		/* AST_MEMBER / AST_PTR_MEMBER */
		struct {
			AstNode *object;
			char    *member_name;
		} member;

		/* AST_INT_LIT / AST_CHAR_LIT */
		struct {
			long long value;
		} int_lit;

		/* AST_FLOAT_LIT */
		struct {
			double value;
		} float_lit;

		/* AST_STRING_LIT */
		struct {
			char *value;    /* the unescaped string content */
			int   label_id; /* assigned during codegen */
		} str_lit;

		/* AST_IDENT */
		struct {
			char *name;
		} ident;
	} u;
};

/* Node constructors */
AstNode *ast_new(AstKind kind, int line);
AstList *ast_list_append(AstList *list, AstNode *node);
int      ast_list_len(const AstList *list);
void     ast_free(AstNode *node);
void     ast_list_free(AstList *list);

#endif /* AST_H */
