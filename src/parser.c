#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "parser.h"

static AstNode *parse_decl(Parser *p, int allow_func_def);
static AstNode *parse_stmt(Parser *p);
static AstNode *parse_expr(Parser *p);
static AstNode *parse_assign_expr(Parser *p);
static AstNode *parse_ternary(Parser *p);
static AstNode *parse_lor(Parser *p);
static AstNode *parse_land(Parser *p);
static AstNode *parse_bor(Parser *p);
static AstNode *parse_bxor(Parser *p);
static AstNode *parse_band(Parser *p);
static AstNode *parse_equality(Parser *p);
static AstNode *parse_relational(Parser *p);
static AstNode *parse_shift(Parser *p);
static AstNode *parse_additive(Parser *p);
static AstNode *parse_multiplicative(Parser *p);
static AstNode *parse_unary(Parser *p);
static AstNode *parse_postfix(Parser *p);
static AstNode *parse_primary(Parser *p);
static Type    *parse_type_specifier(Parser *p, int *is_typedef_name);
static Type    *parse_declarator(Parser *p, Type *base, char **out_name);
static Type    *parse_abstract_declarator(Parser *p, Type *base);

static void parser_error(Parser *p, const char *msg) {
	fprintf(stderr, "%d: error: %s (got '%s')\n",
	    p->cur.line, msg, p->cur.text ? p->cur.text : "?");
	p->had_error = 1;
}

static Token advance(Parser *p) {
	Token old = p->cur;
	p->cur  = p->peek;
	p->peek = lexer_next(p->lexer);
	return old;
}

static int check(Parser *p, TokenType t) {
	return p->cur.type == t;
}

static int check2(Parser *p, TokenType t) {
	return p->peek.type == t;
}

static int match(Parser *p, TokenType t) {
	if (check(p, t)) { advance(p); return 1; }
	return 0;
}

static void expect(Parser *p, TokenType t) {
	if (!match(p, t)) {
		char buf[128];
		sprintf(buf, "expected '%s'", tok_type_name(t));
		parser_error(p, buf);
	}
}

static int is_type_start(Parser *p) {
	switch (p->cur.type) {
	case TOK_KW_VOID:
	case TOK_KW_CHAR:
	case TOK_KW_SHORT:
	case TOK_KW_INT:
	case TOK_KW_LONG:
	case TOK_KW_FLOAT:
	case TOK_KW_DOUBLE:
	case TOK_KW_SIGNED:
	case TOK_KW_UNSIGNED:
	case TOK_KW_STRUCT:
	case TOK_KW_UNION:
	case TOK_KW_ENUM:
	case TOK_KW_CONST:
	case TOK_KW_VOLATILE:
	case TOK_KW_STATIC:
	case TOK_KW_EXTERN:
	case TOK_KW_AUTO:
	case TOK_KW_REGISTER:
	case TOK_KW_TYPEDEF:
		return 1;
	case TOK_IDENT: {
		Symbol *sym = symtab_lookup(p->symtab, p->cur.text);
		return sym && sym->kind == SYM_TYPEDEF;
	}
	default:
		return 0;
	}
}

static Type *parse_struct_or_union(Parser *p, int is_union) {
	int    line = p->cur.line;
	char  *tag  = NULL;
	Type  *t;
	Symbol *sym;

	if (check(p, TOK_IDENT)) {
		tag = strdup(p->cur.text);
		advance(p);
	}

	if (!check(p, TOK_LBRACE)) {
		
		SymKind sk = is_union ? SYM_UNION_TAG : SYM_STRUCT_TAG;
		if (tag) {
			sym = symtab_lookup_tag(p->symtab, tag, sk);
			if (sym) { free(tag); return sym->type; }
			t = is_union ? type_make_union(tag) : type_make_struct(tag);
			sym = symtab_define_tag(p->symtab, tag, sk, t);
			free(tag);
			return t;
		}
		parser_error(p, "anonymous struct/union requires a body");
		t = is_union ? type_make_union(NULL) : type_make_struct(NULL);
		free(tag);
		return t;
	}

	advance(p);

	t = is_union ? type_make_union(tag) : type_make_struct(tag);
	t->is_complete = 0;

	if (tag) {
		SymKind sk = is_union ? SYM_UNION_TAG : SYM_STRUCT_TAG;
		sym = symtab_define_tag(p->symtab, tag, sk, t);
	}

	while (!check(p, TOK_RBRACE) && !check(p, TOK_EOF)) {
		int dummy;
		Type *base = parse_type_specifier(p, &dummy);
		do {
			char   *mname = NULL;
			Type   *mtype = parse_declarator(p, base, &mname);
			TypeMember *m = (TypeMember *)calloc(1, sizeof(TypeMember));
			m->name = mname;
			m->type = mtype;
			if (!t->members) {
				t->members = m;
			} else {
				TypeMember *last = t->members;
				while (last->next) last = last->next;
				last->next = m;
			}
		} while (match(p, TOK_COMMA));
		expect(p, TOK_SEMICOLON);
	}
	expect(p, TOK_RBRACE);
	t->is_complete = 1;
	t->size = type_sizeof(t);
	free(tag);
	return t;
}

static Type *parse_enum_spec(Parser *p) {
	char   *tag  = NULL;
	Type   *t;
	Symbol *sym;

	if (check(p, TOK_IDENT)) {
		tag = strdup(p->cur.text);
		advance(p);
	}

	if (!check(p, TOK_LBRACE)) {
		if (tag) {
			sym = symtab_lookup_tag(p->symtab, tag, SYM_ENUM_TAG);
			if (sym) { free(tag); return sym->type; }
		}
		t = type_make_enum(tag);
		if (tag) symtab_define_tag(p->symtab, tag, SYM_ENUM_TAG, t);
		free(tag);
		return t;
	}

	advance(p);
	t = type_make_enum(tag);
	if (tag) symtab_define_tag(p->symtab, tag, SYM_ENUM_TAG, t);

	long long val = 0;
	while (!check(p, TOK_RBRACE) && !check(p, TOK_EOF)) {
		if (!check(p, TOK_IDENT)) {
			parser_error(p, "expected enum constant name");
			advance(p);
			break;
		}
		char *ename = strdup(p->cur.text);
		advance(p);
		if (match(p, TOK_ASSIGN)) {
			if (check(p, TOK_LIT_INT)) {
				val = p->cur.u.ival;
				advance(p);
			} else {
				parser_error(p, "expected integer constant in enum");
			}
		}
		Symbol *es = symtab_define(p->symtab, ename, SYM_ENUM_CONST, t);
		es->enum_value = val++;
		free(ename);
		if (!match(p, TOK_COMMA)) break;
	}
	expect(p, TOK_RBRACE);
	free(tag);
	return t;
}

static Type *parse_type_specifier(Parser *p, int *is_typedef_name) {
	int is_unsigned = 0, is_signed = 0;
	int has_void = 0, has_char = 0, has_short = 0, has_int = 0;
	int has_long = 0, has_float = 0, has_double = 0;
	int is_const = 0, is_volatile = 0;
	int is_static = 0, is_extern = 0;
	int is_typedef_sc = 0;
	Type *named = NULL;
	if (is_typedef_name) *is_typedef_name = 0;

	for (;;) {
		switch (p->cur.type) {
		case TOK_KW_CONST:    is_const    = 1; advance(p); break;
		case TOK_KW_VOLATILE: is_volatile = 1; advance(p); break;
		case TOK_KW_STATIC:   is_static   = 1; advance(p); break;
		case TOK_KW_EXTERN:   is_extern   = 1; advance(p); break;
		case TOK_KW_AUTO:
		case TOK_KW_REGISTER: advance(p); break;
		case TOK_KW_TYPEDEF:  is_typedef_sc = 1; advance(p); break;
		case TOK_KW_VOID:     has_void   = 1; advance(p); break;
		case TOK_KW_CHAR:     has_char   = 1; advance(p); break;
		case TOK_KW_SHORT:    has_short  = 1; advance(p); break;
		case TOK_KW_INT:      has_int    = 1; advance(p); break;
		case TOK_KW_LONG:     has_long   = 1; advance(p); break;
		case TOK_KW_FLOAT:    has_float  = 1; advance(p); break;
		case TOK_KW_DOUBLE:   has_double = 1; advance(p); break;
		case TOK_KW_SIGNED:   is_signed  = 1; advance(p); break;
		case TOK_KW_UNSIGNED: is_unsigned = 1; advance(p); break;
		case TOK_KW_STRUCT: {
			advance(p);
			named = parse_struct_or_union(p, 0);
			goto done;
		}
		case TOK_KW_UNION: {
			advance(p);
			named = parse_struct_or_union(p, 1);
			goto done;
		}
		case TOK_KW_ENUM: {
			advance(p);
			named = parse_enum_spec(p);
			goto done;
		}
		case TOK_IDENT: {
			Symbol *sym = symtab_lookup(p->symtab, p->cur.text);
			if (sym && sym->kind == SYM_TYPEDEF) {
				named = sym->type;
				if (is_typedef_name) *is_typedef_name = 1;
				advance(p);
				goto done;
			}
			goto done;
		}
		default:
			goto done;
		}
	}
done:;
	(void)is_static; (void)is_extern; (void)is_typedef_sc; (void)is_signed;

	Type *t;
	if (named) {
		t = named;
	} else if (has_void) {
		t = type_make_void();
	} else if (has_float) {
		t = type_make_float();
	} else if (has_double) {
		t = type_make_double();
	} else if (has_char) {
		t = type_make_char(is_unsigned);
	} else if (has_short) {
		t = type_make_short(is_unsigned);
	} else if (has_long) {
		t = type_make_long(is_unsigned);
	} else {
		t = type_make_int(is_unsigned);
	}
	if (is_const)    t->is_const    = 1;
	if (is_volatile) t->is_volatile = 1;
	return t;
}

static Type *parse_declarator(Parser *p, Type *base, char **out_name) {
	if (out_name) *out_name = NULL;

	int ptr_depth = 0;
	int is_const_arr[16];
	while (check(p, TOK_STAR)) {
		advance(p);
		is_const_arr[ptr_depth] = 0;
		if (check(p, TOK_KW_CONST) || check(p, TOK_KW_VOLATILE)) {
			is_const_arr[ptr_depth] = 1;
			advance(p);
		}
		ptr_depth++;
	}

	char  *name = NULL;
	Type  *inner_type = NULL;
	int    is_grouped = 0;

	if (check(p, TOK_LPAREN)) {
		advance(p);
		is_grouped = 1;
		inner_type = parse_declarator(p, NULL, &name);
		expect(p, TOK_RPAREN);
	} else if (check(p, TOK_IDENT)) {
		name = strdup(p->cur.text);
		advance(p);
		while (check(p, TOK_DOT) && p->peek.type == TOK_IDENT) {
			advance(p);
			size_t dotlen = strlen(name) + 1 + strlen(p->cur.text) + 1;
			char *dotted = (char *)malloc(dotlen);
			sprintf(dotted, "%s.%s", name, p->cur.text);
			free(name);
			name = dotted;
			advance(p);
		}
	}

	if (out_name) *out_name = name;

	Type *derived = base;
	for (ptr_depth--; ptr_depth >= 0; ptr_depth--) {
		Type *ptr = type_make_pointer(derived);
		ptr->is_const = is_const_arr[ptr_depth];
		derived = ptr;
	}

	for (;;) {
		if (check(p, TOK_LBRACKET)) {
			advance(p);
			int len = -1;
			if (!check(p, TOK_RBRACKET)) {
				if (check(p, TOK_LIT_INT)) {
					len = (int)p->cur.u.ival;
					advance(p);
				}
			}
			expect(p, TOK_RBRACKET);
			derived = type_make_array(derived, len);
		} else if (check(p, TOK_LPAREN)) {
			advance(p);
			TypeParam *params = NULL, *last_param = NULL;
			int is_variadic = 0;
			while (!check(p, TOK_RPAREN) && !check(p, TOK_EOF)) {
				if (check(p, TOK_ELLIPSIS)) {
					is_variadic = 1;
					advance(p);
					break;
				}
				if (!is_type_start(p)) break;
				int dummy;
				Type *pt  = parse_type_specifier(p, &dummy);
				char *pn  = NULL;
				if (!check(p, TOK_RPAREN) && !check(p, TOK_COMMA))
					pt = parse_declarator(p, pt, &pn);
				TypeParam *tp = (TypeParam *)calloc(1, sizeof(TypeParam));
				tp->name = pn;
				tp->type = pt;
				if (!params) params = last_param = tp;
				else { last_param->next = tp; last_param = tp; }
				if (!match(p, TOK_COMMA)) break;
			}
			expect(p, TOK_RPAREN);
			derived = type_make_function(derived, params, is_variadic);
		} else {
			break;
		}
	}

	if (is_grouped && inner_type) {
		Type *cur = inner_type;
		while (cur && cur->base) cur = cur->base;
		if (cur) cur->base = derived;
		return inner_type;
	}

	return derived;
}

static Type *parse_abstract_declarator(Parser *p, Type *base) {
	return parse_declarator(p, base, NULL);
}

static AstNode *parse_block(Parser *p) {
	int     line = p->cur.line;
	expect(p, TOK_LBRACE);
	AstNode *blk = ast_new(AST_BLOCK, line);
	blk->u.block.items = NULL;
	symtab_push(p->symtab);
	while (!check(p, TOK_RBRACE) && !check(p, TOK_EOF)) {
		AstNode *item;
		if (is_type_start(p)) {
			item = parse_decl(p, 0);
		} else {
			item = parse_stmt(p);
		}
		if (item) blk->u.block.items = ast_list_append(blk->u.block.items, item);
	}
	expect(p, TOK_RBRACE);
	symtab_pop(p->symtab);
	return blk;
}

static AstNode *parse_stmt(Parser *p) {
	int line = p->cur.line;

	if (check(p, TOK_LBRACE)) return parse_block(p);

	if (check(p, TOK_KW_IF)) {
		advance(p);
		AstNode *n = ast_new(AST_IF, line);
		expect(p, TOK_LPAREN);
		n->u.if_stmt.cond = parse_expr(p);
		expect(p, TOK_RPAREN);
		n->u.if_stmt.then_stmt = parse_stmt(p);
		n->u.if_stmt.else_stmt = NULL;
		if (match(p, TOK_KW_ELSE))
			n->u.if_stmt.else_stmt = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_KW_WHILE)) {
		advance(p);
		AstNode *n = ast_new(AST_WHILE, line);
		expect(p, TOK_LPAREN);
		n->u.while_stmt.cond = parse_expr(p);
		expect(p, TOK_RPAREN);
		n->u.while_stmt.body = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_KW_DO)) {
		advance(p);
		AstNode *n = ast_new(AST_DO_WHILE, line);
		n->u.while_stmt.body = parse_stmt(p);
		expect(p, TOK_KW_WHILE);
		expect(p, TOK_LPAREN);
		n->u.while_stmt.cond = parse_expr(p);
		expect(p, TOK_RPAREN);
		expect(p, TOK_SEMICOLON);
		return n;
	}

	if (check(p, TOK_KW_FOR)) {
		advance(p);
		AstNode *n = ast_new(AST_FOR, line);
		expect(p, TOK_LPAREN);
		if (check(p, TOK_SEMICOLON)) {
			n->u.for_stmt.init = NULL;
			advance(p);
		} else if (is_type_start(p)) {
			n->u.for_stmt.init = parse_decl(p, 0);
		} else {
			AstNode *ei = ast_new(AST_EXPR_STMT, p->cur.line);
			ei->u.expr_stmt.expr = parse_expr(p);
			n->u.for_stmt.init = ei;
			expect(p, TOK_SEMICOLON);
		}
		n->u.for_stmt.cond = check(p, TOK_SEMICOLON) ? NULL : parse_expr(p);
		expect(p, TOK_SEMICOLON);
		n->u.for_stmt.incr = check(p, TOK_RPAREN) ? NULL : parse_expr(p);
		expect(p, TOK_RPAREN);
		n->u.for_stmt.body = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_KW_SWITCH)) {
		advance(p);
		AstNode *n = ast_new(AST_SWITCH, line);
		expect(p, TOK_LPAREN);
		n->u.switch_stmt.expr = parse_expr(p);
		expect(p, TOK_RPAREN);
		n->u.switch_stmt.body = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_KW_CASE)) {
		advance(p);
		AstNode *n = ast_new(AST_CASE, line);
		n->u.case_stmt.expr = parse_expr(p);
		expect(p, TOK_COLON);
		n->u.case_stmt.stmt = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_KW_DEFAULT)) {
		advance(p);
		AstNode *n = ast_new(AST_DEFAULT, line);
		expect(p, TOK_COLON);
		n->u.default_stmt.stmt = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_KW_RETURN)) {
		advance(p);
		AstNode *n = ast_new(AST_RETURN, line);
		n->u.ret_stmt.expr = check(p, TOK_SEMICOLON) ? NULL : parse_expr(p);
		expect(p, TOK_SEMICOLON);
		return n;
	}

	if (check(p, TOK_KW_BREAK)) {
		advance(p);
		if (check(p, TOK_LPAREN)) { // break() function
			advance(p);
			expect(p, TOK_RPAREN);
			AstNode* breakIdent = ast_new(AST_IDENT, p->cur.line);
			breakIdent->u.ident.name = strdup("break");
			
			AstNode* breakFunction = ast_new(AST_CALL, p->cur.line);
			breakFunction->u.call.callee = breakIdent;
			breakFunction->u.call.args = NULL;
			breakFunction->u.call.argc = 0;

			AstNode* breakStatement = ast_new(AST_EXPR_STMT, p->cur.line);
			breakStatement->u.expr_stmt.expr = breakFunction; 
			
			expect(p, TOK_SEMICOLON);
			return breakStatement;
		} else {  // break; keyword
			expect(p, TOK_SEMICOLON);
			return ast_new(AST_BREAK, line);
		}
	}

	if (check(p, TOK_KW_CONTINUE)) {
		advance(p);
		expect(p, TOK_SEMICOLON);
		return ast_new(AST_CONTINUE, line);
	}

	if (check(p, TOK_KW_GOTO)) {
		advance(p);
		AstNode *n = ast_new(AST_GOTO, line);
		if (!check(p, TOK_IDENT)) parser_error(p, "expected label after goto");
		else { n->u.goto_stmt.label = strdup(p->cur.text); advance(p); }
		expect(p, TOK_SEMICOLON);
		return n;
	}

	if (check(p, TOK_IDENT) && check2(p, TOK_COLON)) {
		AstNode *n = ast_new(AST_LABEL_STMT, line);
		n->u.label_stmt.name = strdup(p->cur.text);
		advance(p); advance(p);
		n->u.label_stmt.stmt = parse_stmt(p);
		return n;
	}

	if (check(p, TOK_SEMICOLON)) {
		advance(p);
		return ast_new(AST_NULL_STMT, line);
	}

	{
		AstNode *n = ast_new(AST_EXPR_STMT, line);
		n->u.expr_stmt.expr = parse_expr(p);
		expect(p, TOK_SEMICOLON);
		return n;
	}
}

static AstNode *parse_decl(Parser *p, int allow_func_def) {
	int    line = p->cur.line;
	int    is_typedef_sc = 0;
	int    is_static  = 0;
	int    is_extern  = 0;

	char *doc_brief        = p->cur.doc_brief;        p->cur.doc_brief        = NULL;
	char *doc_details      = p->cur.doc_details;      p->cur.doc_details      = NULL;
	char **doc_param_names = p->cur.doc_param_names;  p->cur.doc_param_names  = NULL;
	char **doc_param_descs = p->cur.doc_param_descs;  p->cur.doc_param_descs  = NULL;
	int    doc_param_count = p->cur.doc_param_count;  p->cur.doc_param_count  = 0;
	char  *doc_return      = p->cur.doc_return;       p->cur.doc_return       = NULL;

	for (;;) {
		if (check(p, TOK_KW_TYPEDEF))  { is_typedef_sc = 1; advance(p); }
		else if (check(p, TOK_KW_STATIC))  { is_static = 1; advance(p); }
		else if (check(p, TOK_KW_EXTERN))  { is_extern = 1; advance(p); }
		else if (check(p, TOK_KW_AUTO) || check(p, TOK_KW_REGISTER)) advance(p);
		else break;
	}

	int dummy;
	Type *base = parse_type_specifier(p, &dummy);

	if (check(p, TOK_SEMICOLON)) {
		advance(p);
		if (is_typedef_sc && base->kind == TY_TYPEDEF_REF) {
		}
		return NULL;
	}

	AstList *decls = NULL;
	int first = 1;
	while (first || match(p, TOK_COMMA)) {
		first = 0;
		char *name = NULL;
		Type *full = parse_declarator(p, base, &name);

		if (is_typedef_sc && name) {
			AstNode *n = ast_new(AST_TYPEDEF_DECL, line);
			n->u.typedef_decl.name       = name;
			n->u.typedef_decl.alias_type = full;
			Symbol *sym = symtab_define(p->symtab, name, SYM_TYPEDEF, full);
			(void)sym;
			if (decls == NULL) {
				expect(p, TOK_SEMICOLON);
				return n;
			}
			decls = ast_list_append(decls, n);
			continue;
		}

		if (full->kind == TY_FUNCTION && allow_func_def && check(p, TOK_LBRACE)) {
			AstNode *n = ast_new(AST_FUNC_DEF, line);
			n->u.func.name      = name;
			n->u.func.func_type = full;
			n->u.func.is_static = is_static;
			n->u.func.is_extern = is_extern;
			TypeParam *tp = full->params;
			while (tp) {
				AstNode *pn = ast_new(AST_VAR_DECL, line);
				pn->u.var.name     = tp->name ? strdup(tp->name) : NULL;
				pn->u.var.var_type = tp->type;
				pn->u.var.is_param = 1;
				n->u.func.params = ast_list_append(n->u.func.params, pn);
				tp = tp->next;
			}
			Symbol *sym = symtab_define(p->symtab, name, SYM_FUNC, full);
			if (is_extern || name[0] == '_') {
				sym->func_label = strdup(name);
			} else {
				sym->func_label = (char *)malloc(strlen(name) + 2);
				sprintf(sym->func_label, "%s_", name);
			}
			symtab_push(p->symtab);
			AstList *pl = n->u.func.params;
			while (pl) {
				AstNode *pn = pl->node;
				if (pn->u.var.name)
					symtab_define(p->symtab, pn->u.var.name, SYM_VAR, pn->u.var.var_type);
				pl = pl->next;
			}
			int blk_line = p->cur.line;
			expect(p, TOK_LBRACE);
			AstNode *blk = ast_new(AST_BLOCK, blk_line);
			blk->u.block.items = NULL;
			while (!check(p, TOK_RBRACE) && !check(p, TOK_EOF)) {
				AstNode *item = is_type_start(p) ? parse_decl(p, 0) : parse_stmt(p);
				if (item) blk->u.block.items = ast_list_append(blk->u.block.items, item);
			}
			expect(p, TOK_RBRACE);
			symtab_pop(p->symtab);
			n->u.func.body             = blk;
			n->u.func.doc_brief        = doc_brief;
			n->u.func.doc_details      = doc_details;
			n->u.func.doc_param_names  = doc_param_names;
			n->u.func.doc_param_descs  = doc_param_descs;
			n->u.func.doc_param_count  = doc_param_count;
			n->u.func.doc_return       = doc_return;
			doc_brief = doc_details = doc_return = NULL;
			doc_param_names = doc_param_descs = NULL;
			doc_param_count = 0;
			return n;
		}

		if (full->kind == TY_FUNCTION) {
			{
				int i;
				for (i = 0; i < doc_param_count; i++) { free(doc_param_names[i]); free(doc_param_descs[i]); }
			}
			free(doc_brief); doc_brief = NULL;
			free(doc_details); doc_details = NULL;
			free(doc_param_names); doc_param_names = NULL;
			free(doc_param_descs); doc_param_descs = NULL;
			doc_param_count = 0;
			free(doc_return); doc_return = NULL;
			AstNode *n = ast_new(AST_FUNC_DECL, line);
			n->u.func.name      = name;
			n->u.func.func_type = full;
			n->u.func.is_static = is_static;
			n->u.func.is_extern = is_extern;
			Symbol *sym = symtab_define(p->symtab, name, SYM_FUNC, full);
			if (is_extern || name[0] == '_') {
				sym->func_label = strdup(name);
			} else {
				sym->func_label = (char *)malloc(strlen(name) + 2);
				sprintf(sym->func_label, "%s_", name);
			}
			if (!match(p, TOK_COMMA)) {
				expect(p, TOK_SEMICOLON);
				return n;
			}
			decls = ast_list_append(decls, n);
			continue;
		}

		{
			int i;
			for (i = 0; i < doc_param_count; i++) { free(doc_param_names[i]); free(doc_param_descs[i]); }
		}
		free(doc_brief); doc_brief = NULL;
		free(doc_details); doc_details = NULL;
		free(doc_param_names); doc_param_names = NULL;
		free(doc_param_descs); doc_param_descs = NULL;
		doc_param_count = 0;
		free(doc_return); doc_return = NULL;
		AstNode *n = ast_new(AST_VAR_DECL, line);
		n->u.var.name      = name;
		n->u.var.var_type  = full;
		n->u.var.is_static = is_static;
		n->u.var.is_extern = is_extern;
		n->u.var.init      = NULL;
		if (match(p, TOK_ASSIGN)) {
			if (check(p, TOK_LBRACE)) {
				int il_line = p->cur.line;
				advance(p);
				AstNode *il = ast_new(AST_INIT_LIST, il_line);
				il->u.init_list.items = NULL;
				while (!check(p, TOK_RBRACE) && !check(p, TOK_EOF)) {
					AstNode *elem = parse_assign_expr(p);
					if (elem) il->u.init_list.items = ast_list_append(il->u.init_list.items, elem);
					if (!match(p, TOK_COMMA)) break;
				}
				expect(p, TOK_RBRACE);
				n->u.var.init = il;
			} else {
				n->u.var.init = parse_assign_expr(p);
			}
		}
		if (name) symtab_define(p->symtab, name, SYM_VAR, full);
		decls = ast_list_append(decls, n);
	}
	expect(p, TOK_SEMICOLON);

	if (!decls) return NULL;
	if (!decls->next) {
		AstNode *single = decls->node;
		free(decls);
		return single;
	}
	AstNode *grp = ast_new(AST_BLOCK, line);
	grp->u.block.items = decls;
	return grp;
}

static AstNode *parse_expr(Parser *p) {
	AstNode *left = parse_assign_expr(p);
	while (check(p, TOK_COMMA)) {
		int line = p->cur.line;
		advance(p);
		AstNode *right = parse_assign_expr(p);
		AstNode *n     = ast_new(AST_COMMA_EXPR, line);
		n->u.binary.op    = TOK_COMMA;
		n->u.binary.left  = left;
		n->u.binary.right = right;
		left = n;
	}
	return left;
}

static int is_assign_op(TokenType t) {
	return t == TOK_ASSIGN        || t == TOK_PLUS_ASSIGN  ||
	       t == TOK_MINUS_ASSIGN  || t == TOK_STAR_ASSIGN  ||
	       t == TOK_SLASH_ASSIGN  || t == TOK_PERCENT_ASSIGN ||
	       t == TOK_AMP_ASSIGN    || t == TOK_PIPE_ASSIGN  ||
	       t == TOK_CARET_ASSIGN  || t == TOK_LSHIFT_ASSIGN||
	       t == TOK_RSHIFT_ASSIGN;
}

static AstNode *parse_assign_expr(Parser *p) {
	AstNode *left = parse_ternary(p);
	if (is_assign_op(p->cur.type)) {
		int op   = p->cur.type;
		int line = p->cur.line;
		advance(p);
		AstNode *rhs = parse_assign_expr(p);
		AstNode *n   = ast_new(AST_ASSIGN, line);
		n->u.assign.op  = op;
		n->u.assign.lhs = left;
		n->u.assign.rhs = rhs;
		return n;
	}
	return left;
}

static AstNode *parse_ternary(Parser *p) {
	AstNode *cond = parse_lor(p);
	if (check(p, TOK_QUESTION)) {
		int line = p->cur.line;
		advance(p);
		AstNode *then_expr = parse_expr(p);
		expect(p, TOK_COLON);
		AstNode *else_expr = parse_ternary(p);
		AstNode *n = ast_new(AST_TERNARY, line);
		n->u.ternary.cond      = cond;
		n->u.ternary.then_expr = then_expr;
		n->u.ternary.else_expr = else_expr;
		return n;
	}
	return cond;
}

#define BINARY_LEFT(name, next, test) \
static AstNode *name(Parser *p) { \
	AstNode *l = next(p); \
	while (test) { \
		int op = p->cur.type, line = p->cur.line; advance(p); \
		AstNode *r = next(p); \
		AstNode *n = ast_new(AST_BINARY, line); \
		n->u.binary.op = op; n->u.binary.left = l; n->u.binary.right = r; l = n; \
	} \
	return l; \
}

BINARY_LEFT(parse_lor,           parse_land,        check(p, TOK_PIPE_PIPE))
BINARY_LEFT(parse_land,          parse_bor,         check(p, TOK_AMP_AMP))
BINARY_LEFT(parse_bor,           parse_bxor,        check(p, TOK_PIPE))
BINARY_LEFT(parse_bxor,          parse_band,        check(p, TOK_CARET))
BINARY_LEFT(parse_band,          parse_equality,    check(p, TOK_AMPERSAND))
BINARY_LEFT(parse_equality,      parse_relational,  check(p,TOK_EQ_EQ)||check(p,TOK_BANG_EQ))
BINARY_LEFT(parse_relational,    parse_shift,
    check(p,TOK_LT)||check(p,TOK_GT)||check(p,TOK_LT_EQ)||check(p,TOK_GT_EQ))
BINARY_LEFT(parse_shift,         parse_additive,    check(p,TOK_LSHIFT)||check(p,TOK_RSHIFT))
BINARY_LEFT(parse_additive,      parse_multiplicative,
    check(p,TOK_PLUS)||check(p,TOK_MINUS))
BINARY_LEFT(parse_multiplicative,parse_unary,
    check(p,TOK_STAR)||check(p,TOK_SLASH)||check(p,TOK_PERCENT))

static AstNode *parse_unary(Parser *p) {
	int line = p->cur.line;
	TokenType t = p->cur.type;

	if (t == TOK_PLUS_PLUS || t == TOK_MINUS_MINUS ||
	    t == TOK_AMPERSAND || t == TOK_STAR        ||
	    t == TOK_MINUS     || t == TOK_TILDE       || t == TOK_BANG) {
		advance(p);
		AstNode *operand = parse_unary(p);
		AstNode *n = ast_new(AST_UNARY_PRE, line);
		n->u.unary.op      = t;
		n->u.unary.operand = operand;
		return n;
	}

	if (t == TOK_PLUS) { advance(p); return parse_unary(p); }

	if (t == TOK_KW_SIZEOF) {
		advance(p);
		if (check(p, TOK_LPAREN)) {
			advance(p);
			if (is_type_start(p)) {
				int dummy2;
				Type *st = parse_type_specifier(p, &dummy2);
				st = parse_abstract_declarator(p, st);
				expect(p, TOK_RPAREN);
				AstNode *n = ast_new(AST_SIZEOF_TYPE, line);
				n->u.sizeof_type.sizeof_type = st;
				return n;
			}
			AstNode *expr = parse_unary(p);
			expect(p, TOK_RPAREN);
			AstNode *n = ast_new(AST_SIZEOF_EXPR, line);
			n->u.sizeof_expr.sizeof_expr = expr;
			return n;
		}
		AstNode *n = ast_new(AST_SIZEOF_EXPR, line);
		n->u.sizeof_expr.sizeof_expr = parse_unary(p);
		return n;
	}

	if (t == TOK_LPAREN) {
		const Token *next = lexer_peek(p->lexer);
		(void)next;
		if (check2(p, TOK_KW_VOID) || check2(p, TOK_KW_CHAR) || check2(p, TOK_KW_INT) ||
		    check2(p, TOK_KW_FLOAT) || check2(p, TOK_KW_DOUBLE) || check2(p, TOK_KW_LONG) ||
		    check2(p, TOK_KW_SHORT) || check2(p, TOK_KW_UNSIGNED) || check2(p, TOK_KW_SIGNED) ||
		    check2(p, TOK_KW_STRUCT) || check2(p, TOK_KW_UNION) || check2(p, TOK_KW_ENUM)) {
			advance(p);
			int dummy3;
			Type *ct = parse_type_specifier(p, &dummy3);
			ct = parse_abstract_declarator(p, ct);
			if (check(p, TOK_RPAREN)) {
				advance(p);
				AstNode *expr = parse_unary(p);
				AstNode *n = ast_new(AST_CAST, line);
				n->u.cast.cast_type = ct;
				n->u.cast.expr      = expr;
				return n;
			}
		}
	}

	return parse_postfix(p);
}

static AstNode *parse_postfix(Parser *p) {
	AstNode *base = parse_primary(p);
	for (;;) {
		int line = p->cur.line;
		if (check(p, TOK_LBRACKET)) {
			advance(p);
			AstNode *idx = parse_expr(p);
			expect(p, TOK_RBRACKET);
			AstNode *n = ast_new(AST_SUBSCRIPT, line);
			n->u.subscript.base  = base;
			n->u.subscript.index = idx;
			base = n;
		} else if (check(p, TOK_LPAREN)) {
			advance(p);
			AstNode *call = ast_new(AST_CALL, line);
			call->u.call.callee = base;
			call->u.call.args   = NULL;
			call->u.call.argc   = 0;
			while (!check(p, TOK_RPAREN) && !check(p, TOK_EOF)) {
				AstNode *arg = parse_assign_expr(p);
				call->u.call.args = ast_list_append(call->u.call.args, arg);
				call->u.call.argc++;
				if (!match(p, TOK_COMMA)) break;
			}
			expect(p, TOK_RPAREN);
			base = call;
		} else if (check(p, TOK_DOT)) {
			advance(p);
			if (!check(p, TOK_IDENT)) { parser_error(p, "expected member name"); break; }
			if (base->kind == AST_IDENT) {
				size_t dotlen = strlen(base->u.ident.name) + 1 + strlen(p->cur.text) + 1;
				char *dotted = (char *)malloc(dotlen);
				sprintf(dotted, "%s.%s", base->u.ident.name, p->cur.text);
				Symbol *dsym = symtab_lookup(p->symtab, dotted);
				if (dsym) {
					free(base->u.ident.name);
					base->u.ident.name = dotted;
					advance(p);
					continue;
				}
				free(dotted);
			}
			AstNode *n = ast_new(AST_MEMBER, line);
			n->u.member.object      = base;
			n->u.member.member_name = strdup(p->cur.text);
			advance(p);
			base = n;
		} else if (check(p, TOK_ARROW)) {
			advance(p);
			if (!check(p, TOK_IDENT)) { parser_error(p, "expected member name"); break; }
			AstNode *n = ast_new(AST_PTR_MEMBER, line);
			n->u.member.object      = base;
			n->u.member.member_name = strdup(p->cur.text);
			advance(p);
			base = n;
		} else if (check(p, TOK_PLUS_PLUS)) {
			advance(p);
			AstNode *n = ast_new(AST_UNARY_POST, line);
			n->u.unary.op      = TOK_PLUS_PLUS;
			n->u.unary.operand = base;
			base = n;
		} else if (check(p, TOK_MINUS_MINUS)) {
			advance(p);
			AstNode *n = ast_new(AST_UNARY_POST, line);
			n->u.unary.op      = TOK_MINUS_MINUS;
			n->u.unary.operand = base;
			base = n;
		} else {
			break;
		}
	}
	return base;
}

static AstNode *parse_primary(Parser *p) {
	int line = p->cur.line;

	if (check(p, TOK_LIT_INT)) {
		AstNode *n = ast_new(AST_INT_LIT, line);
		n->u.int_lit.value = p->cur.u.ival;
		advance(p);
		return n;
	}

	if (check(p, TOK_LIT_FLOAT)) {
		AstNode *n = ast_new(AST_FLOAT_LIT, line);
		n->u.float_lit.value = p->cur.u.fval;
		advance(p);
		return n;
	}

	if (check(p, TOK_LIT_CHAR)) {
		AstNode *n = ast_new(AST_CHAR_LIT, line);
		n->u.int_lit.value = p->cur.u.ival;
		advance(p);
		return n;
	}

	if (check(p, TOK_LIT_STRING)) {
		AstNode *n = ast_new(AST_STRING_LIT, line);
		n->u.str_lit.value    = strdup(p->cur.text);
		n->u.str_lit.label_id = -1;
		advance(p);
		while (check(p, TOK_LIT_STRING)) {
			int oldlen = (int)strlen(n->u.str_lit.value);
			int addlen = (int)strlen(p->cur.text);
			n->u.str_lit.value = (char *)realloc(n->u.str_lit.value,
			    oldlen + addlen + 1);
			strcat(n->u.str_lit.value, p->cur.text);
			advance(p);
		}
		return n;
	}

	if (check(p, TOK_IDENT)) {
		AstNode *n = ast_new(AST_IDENT, line);
		n->u.ident.name = strdup(p->cur.text);
		advance(p);
		return n;
	}

	if (check(p, TOK_LPAREN)) {
		advance(p);
		AstNode *inner = parse_expr(p);
		expect(p, TOK_RPAREN);
		return inner;
	}

	parser_error(p, "unexpected token in expression");
	advance(p);
	return ast_new(AST_INT_LIT, line);
}

void parser_init(Parser *p, Lexer *l, SymTab *st) {
	memset(p, 0, sizeof(*p));
	p->lexer  = l;
	p->symtab = st;
	p->cur  = lexer_next(l);
	p->peek = lexer_next(l);
}

AstNode *parser_parse(Parser *p) {
	AstNode *unit = ast_new(AST_TRANSLATION_UNIT, 1);
	unit->u.unit.decls = NULL;
	unit->u.unit.asm_includes = NULL;
	unit->u.unit.asm_include_count = 0;
	while (!check(p, TOK_EOF)) {
		AstNode *decl = parse_decl(p, 1);
		if (decl) unit->u.unit.decls = ast_list_append(unit->u.unit.decls, decl);
	}
	if (p->lexer->asm_include_count > 0) {
		unit->u.unit.asm_includes = p->lexer->asm_includes;
		unit->u.unit.asm_include_count = p->lexer->asm_include_count;
		p->lexer->asm_includes = NULL;
		p->lexer->asm_include_count = 0;
		p->lexer->asm_include_cap = 0;
	}
	return unit;
}