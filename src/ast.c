#include <stdlib.h>
#include <string.h>
#include "ast.h"

AstNode *ast_new(AstKind kind, int line) {
	AstNode *n = (AstNode *)calloc(1, sizeof(AstNode));
	n->kind = kind;
	n->line = line;
	return n;
}

AstList *ast_list_append(AstList *list, AstNode *node) {
	AstList *entry = (AstList *)malloc(sizeof(AstList));
	AstList *cur;
	entry->node = node;
	entry->next = NULL;
	if (!list) return entry;
	cur = list;
	while (cur->next) cur = cur->next;
	cur->next = entry;
	return list;
}

int ast_list_len(const AstList *list) {
	int n = 0;
	const AstList *c = list;
	while (c) { n++; c = c->next; }
	return n;
}

void ast_list_free(AstList *list) {
	while (list) {
		AstList *next = list->next;
		ast_free(list->node);
		free(list);
		list = next;
	}
}

void ast_free(AstNode *n) {
	if (!n) return;
	switch (n->kind) {
	case AST_TRANSLATION_UNIT: {
		ast_list_free(n->u.unit.decls);
		int i;
		for (i = 0; i < n->u.unit.asm_include_count; i++)
			free(n->u.unit.asm_includes[i]);
		free(n->u.unit.asm_includes);
		break;
	}
	case AST_FUNC_DEF:
	case AST_FUNC_DECL:
		free(n->u.func.name);
		free(n->u.func.doc_brief);
		free(n->u.func.doc_details);
		free(n->u.func.doc_return);
		{
			int i;
			for (i = 0; i < n->u.func.doc_param_count; i++) {
				free(n->u.func.doc_param_names[i]);
				free(n->u.func.doc_param_descs[i]);
			}
		}
		free(n->u.func.doc_param_names);
		free(n->u.func.doc_param_descs);
		ast_list_free(n->u.func.params);
		ast_free(n->u.func.body);
		break;
	case AST_VAR_DECL:
		free(n->u.var.name);
		ast_free(n->u.var.init);
		break;
	case AST_TYPEDEF_DECL:
		free(n->u.typedef_decl.name);
		break;
	case AST_BLOCK:
		ast_list_free(n->u.block.items);
		break;
	case AST_EXPR_STMT:
		ast_free(n->u.expr_stmt.expr);
		break;
	case AST_IF:
		ast_free(n->u.if_stmt.cond);
		ast_free(n->u.if_stmt.then_stmt);
		ast_free(n->u.if_stmt.else_stmt);
		break;
	case AST_WHILE:
	case AST_DO_WHILE:
		ast_free(n->u.while_stmt.cond);
		ast_free(n->u.while_stmt.body);
		break;
	case AST_FOR:
		ast_free(n->u.for_stmt.init);
		ast_free(n->u.for_stmt.cond);
		ast_free(n->u.for_stmt.incr);
		ast_free(n->u.for_stmt.body);
		break;
	case AST_SWITCH:
		ast_free(n->u.switch_stmt.expr);
		ast_free(n->u.switch_stmt.body);
		break;
	case AST_CASE:
		ast_free(n->u.case_stmt.expr);
		ast_free(n->u.case_stmt.stmt);
		break;
	case AST_DEFAULT:
		ast_free(n->u.default_stmt.stmt);
		break;
	case AST_RETURN:
		ast_free(n->u.ret_stmt.expr);
		break;
	case AST_GOTO:
		free(n->u.goto_stmt.label);
		break;
	case AST_LABEL_STMT:
		free(n->u.label_stmt.name);
		ast_free(n->u.label_stmt.stmt);
		break;
	case AST_ASSIGN:
		ast_free(n->u.assign.lhs);
		ast_free(n->u.assign.rhs);
		break;
	case AST_BINARY:
	case AST_COMMA_EXPR:
		ast_free(n->u.binary.left);
		ast_free(n->u.binary.right);
		break;
	case AST_TERNARY:
		ast_free(n->u.ternary.cond);
		ast_free(n->u.ternary.then_expr);
		ast_free(n->u.ternary.else_expr);
		break;
	case AST_CAST:
		ast_free(n->u.cast.expr);
		break;
	case AST_UNARY_PRE:
	case AST_UNARY_POST:
		ast_free(n->u.unary.operand);
		break;
	case AST_SIZEOF_EXPR:
		ast_free(n->u.sizeof_expr.sizeof_expr);
		break;
	case AST_CALL:
		ast_free(n->u.call.callee);
		ast_list_free(n->u.call.args);
		break;
	case AST_SUBSCRIPT:
		ast_free(n->u.subscript.base);
		ast_free(n->u.subscript.index);
		break;
	case AST_MEMBER:
	case AST_PTR_MEMBER:
		ast_free(n->u.member.object);
		free(n->u.member.member_name);
		break;
	case AST_STRING_LIT:
		free(n->u.str_lit.value);
		break;
	case AST_IDENT:
		free(n->u.ident.name);
		break;
	case AST_INIT_LIST:
		ast_list_free(n->u.init_list.items);
		break;
	default:
		break;
	}
	free(n);
}
