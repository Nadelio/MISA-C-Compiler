#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include "sema.h"
#include "target.h"

static void  analyze_decl(Sema *s, AstNode *n, int is_global);
static void  analyze_func(Sema *s, AstNode *n);
static void  analyze_stmt(Sema *s, AstNode *n);
static Type *analyze_expr(Sema *s, AstNode *n);
static Type *analyze_lvalue(Sema *s, AstNode *n);
static AstNode *normalize_initializer(Type *type, AstNode *init);
static void validate_initializer(Sema *s, Type *type, AstNode *init);

int sema_eval_integer_constant(SymTab *symtab, AstNode *n, long long *out) {
	long long left, right;
	Symbol *sym;
	if (!n || !out) return 0;
	switch (n->kind) {
	case AST_INT_LIT:
	case AST_CHAR_LIT:
		*out = n->u.int_lit.value;
		return 1;
	case AST_IDENT:
		sym = symtab_lookup(symtab, n->u.ident.name);
		if (sym && sym->kind == SYM_ENUM_CONST) { *out = sym->enum_value; return 1; }
		return 0;
	case AST_UNARY_PRE:
		if (!sema_eval_integer_constant(symtab, n->u.unary.operand, &right)) return 0;
		switch (n->u.unary.op) {
		case TOK_PLUS: *out = right; return 1;
		case TOK_MINUS: *out = -right; return 1;
		case TOK_TILDE: *out = ~right; return 1;
		case TOK_BANG: *out = !right; return 1;
		default: return 0;
		}
	case AST_BINARY:
		if (!sema_eval_integer_constant(symtab, n->u.binary.left, &left) ||
		    !sema_eval_integer_constant(symtab, n->u.binary.right, &right)) return 0;
		switch (n->u.binary.op) {
		case TOK_PLUS: *out = left + right; return 1;
		case TOK_MINUS: *out = left - right; return 1;
		case TOK_STAR: *out = left * right; return 1;
		case TOK_SLASH: if (!right) return 0; *out = left / right; return 1;
		case TOK_PERCENT: if (!right) return 0; *out = left % right; return 1;
		case TOK_LSHIFT: *out = left << right; return 1;
		case TOK_RSHIFT: *out = left >> right; return 1;
		case TOK_AMPERSAND: *out = left & right; return 1;
		case TOK_PIPE: *out = left | right; return 1;
		case TOK_CARET: *out = left ^ right; return 1;
		case TOK_EQ_EQ: *out = left == right; return 1;
		case TOK_BANG_EQ: *out = left != right; return 1;
		case TOK_LT: *out = left < right; return 1;
		case TOK_GT: *out = left > right; return 1;
		case TOK_LT_EQ: *out = left <= right; return 1;
		case TOK_GT_EQ: *out = left >= right; return 1;
		case TOK_AMP_AMP: *out = left && right; return 1;
		case TOK_PIPE_PIPE: *out = left || right; return 1;
		default: return 0;
		}
	case AST_TERNARY:
		if (!sema_eval_integer_constant(symtab, n->u.ternary.cond, &left)) return 0;
		return sema_eval_integer_constant(symtab,
		    left ? n->u.ternary.then_expr : n->u.ternary.else_expr, out);
	case AST_CAST:
		return sema_eval_integer_constant(symtab, n->u.cast.expr, out);
	case AST_SIZEOF_TYPE:
		*out = type_sizeof(n->u.sizeof_type.sizeof_type);
		return 1;
	case AST_SIZEOF_EXPR:
		if (!n->u.sizeof_expr.sizeof_expr || !n->u.sizeof_expr.sizeof_expr->type) return 0;
		*out = type_sizeof(n->u.sizeof_expr.sizeof_expr->type);
		return 1;
	default:
		return 0;
	}
}

static void sema_error(Sema *s, AstNode *n, const char *msg) {
	fprintf(stderr, "%d: error: %s\n", n ? n->line : 0, msg);
	s->had_error = 1;
}

/*
 * Checks a dotted extern name (e.g. "foo.someVar") against what the included
 * .asm source actually states that label as. This is only called for names
 * containing '.', if the label is not found, print a compilation error
 */
static void check_extern_asm_kind(Sema *s, AstNode *n, const char *name, int want_func) {
	AsmLabelKind k;
	if (!name || !strrchr(name, '.')) return;
	k = asm_labels_lookup(s->asm_labels, name);
	if (k == ASM_LABEL_UNKNOWN) return;
	if (want_func && k == ASM_LABEL_DATA) {
		char buf[192];
		snprintf(buf, sizeof buf,
			"'%s' is declared extern as a function, but is a data label in the included .asm source", name);
		sema_error(s, n, buf);	
	} else if (!want_func && k == ASM_LABEL_CODE) {
		char buf[192];
		snprintf(buf, sizeof buf,
		    "'%s' is declared extern as a variable, but is a code label in the included .asm source", name);
		sema_error(s, n, buf);	
	}
}

static Type *int_type(void)   { return type_make_int(0); }
static Type *float_type(void) { return type_make_float(); }
static Type *ptr_type(Type *base) { return type_make_pointer(base); }
static Type *void_type(void)  { return type_make_void(); }

static Type *integer_literal_type(const AstNode *n) {
	unsigned long long value = (unsigned long long)n->u.int_lit.value;
	int decimal = n->u.int_lit.base == 10;
	if (n->u.int_lit.has_long_suffix) {
		if (n->u.int_lit.has_unsigned_suffix || value > MISA_LONG_MAX)
			return type_make_long(1);
		return type_make_long(0);
	}
	if (n->u.int_lit.has_unsigned_suffix) {
		if (value <= MISA_UINT_MAX) return type_make_int(1);
		return type_make_long(1);
	}
	if (value <= MISA_INT_MAX) return type_make_int(0);
	if (!decimal && value <= MISA_UINT_MAX) return type_make_int(1);
	if (value <= MISA_LONG_MAX) return type_make_long(0);
	return type_make_long(1);
}

static Type *decay(Type *t) {
	if (t && t->kind == TY_ARRAY) return type_make_pointer(t->base);
	if (t && t->kind == TY_FUNCTION) return type_make_pointer(t);
	return t;
}

static Type *analyze_expr(Sema *s, AstNode *n) {
	Type *t = NULL;
	if (!n) return int_type();

	switch (n->kind) {
	case AST_INT_LIT:
		t = integer_literal_type(n);
		break;
	case AST_FLOAT_LIT:
		t = n->u.float_lit.has_float_suffix ? float_type() : type_make_double();
		break;
	case AST_CHAR_LIT:
		t = type_make_char(0);
		break;
	case AST_STRING_LIT:
		t = ptr_type(type_make_char(0));
		break;

	case AST_IDENT: {
		Symbol *sym = symtab_lookup(s->symtab, n->u.ident.name);
		if (!sym) {
			char buf[128];
			sprintf(buf, "undeclared identifier '%s'", n->u.ident.name);
			sema_error(s, n, buf);
			t = int_type();
		} else if (sym->kind == SYM_ENUM_CONST) {
			t = int_type();
		} else {
			t = decay(sym->type);
			n->is_lvalue = (sym->kind == SYM_VAR) &&
			               sym->type && sym->type->kind != TY_ARRAY &&
			               sym->type->kind != TY_FUNCTION;
		}
		break;
	}

	case AST_UNARY_PRE: {
		Type *ot = analyze_expr(s, n->u.unary.operand);
		ot = decay(ot);
		switch (n->u.unary.op) {
		case TOK_MINUS: case TOK_PLUS:
			t = type_is_complex(ot) || type_is_float(ot) ? ot : type_promote_integer(ot);
			break;
		case TOK_TILDE:
			t = type_promote_integer(ot);
			break;
		case TOK_BANG:
			t = int_type();
			break;
		case TOK_PLUS_PLUS: case TOK_MINUS_MINUS:
			t = ot;
			n->is_lvalue = 0;
			break;
		case TOK_AMPERSAND:
			if (n->u.unary.operand && n->u.unary.operand->is_bit_field)
				sema_error(s, n, "cannot take the address of a bit-field");
			t = ptr_type(ot);
			break;
		case TOK_STAR:
			if (ot && ot->kind == TY_POINTER) {
				t = ot->base;
				n->is_lvalue = 1;
			} else {
				sema_error(s, n, "dereference of non-pointer");
				t = int_type();
			}
			break;
		default:
			t = ot;
		}
		break;
	}

	case AST_UNARY_POST: {
		Type *ot = analyze_expr(s, n->u.unary.operand);
		t = decay(ot);
		n->is_lvalue = 0;
		break;
	}

	case AST_BINARY: {
		Type *lt = decay(analyze_expr(s, n->u.binary.left));
		Type *rt = decay(analyze_expr(s, n->u.binary.right));
		switch (n->u.binary.op) {
		case TOK_EQ_EQ: case TOK_BANG_EQ:
			t = int_type();
			break;
		case TOK_LT:    case TOK_GT:
		case TOK_LT_EQ: case TOK_GT_EQ:
			if (type_is_complex(lt) || type_is_complex(rt))
				sema_error(s, n, "ordering comparison is invalid for complex operands");
			t = int_type();
			break;
		case TOK_AMP_AMP: case TOK_PIPE_PIPE:
			t = int_type();
			break;
		case TOK_PLUS: case TOK_MINUS:
			if (type_is_pointer(lt)) {
				t = lt;
			} else if (type_is_pointer(rt)) {
				t = rt;
			} else {
				t = type_usual_arithmetic(lt, rt);
			}
			break;
		case TOK_AMPERSAND: case TOK_PIPE: case TOK_CARET:
			t = type_usual_arithmetic(lt, rt);
			break;
		case TOK_LSHIFT:    case TOK_RSHIFT:
			t = type_promote_integer(lt);
			break;
		default:
			t = type_usual_arithmetic(lt, rt);
		}
		break;
	}

	case AST_ASSIGN: {
		Type *lt = analyze_lvalue(s, n->u.assign.lhs);
		Type *rt = decay(analyze_expr(s, n->u.assign.rhs));
		(void)rt;
		t = lt;
		break;
	}

	case AST_TERNARY: {
		analyze_expr(s, n->u.ternary.cond);
		Type *tt = decay(analyze_expr(s, n->u.ternary.then_expr));
		Type *et = decay(analyze_expr(s, n->u.ternary.else_expr));
		t = type_usual_arithmetic(tt, et);
		break;
	}

	case AST_COMMA_EXPR:
		analyze_expr(s, n->u.binary.left);
		t = decay(analyze_expr(s, n->u.binary.right));
		break;

	case AST_CAST:
		analyze_expr(s, n->u.cast.expr);
		t = n->u.cast.cast_type;
		break;

	case AST_SIZEOF_TYPE:
		t = int_type();
		break;

	case AST_SIZEOF_EXPR:
		analyze_expr(s, n->u.sizeof_expr.sizeof_expr);
		t = int_type();
		break;

	case AST_CALL: {
		Type *ct = decay(analyze_expr(s, n->u.call.callee));
		if (ct && ct->kind == TY_POINTER && ct->base &&
		    ct->base->kind == TY_FUNCTION) {
			ct = ct->base;
		}
		if (ct && ct->kind == TY_FUNCTION) {
			t = ct->base ? ct->base : void_type();
		} else {
			t = int_type();
		}
		AstList *arg = n->u.call.args;
		while (arg) { analyze_expr(s, arg->node); arg = arg->next; }
		break;
	}

	case AST_SUBSCRIPT: {
		Type *bt = decay(analyze_expr(s, n->u.subscript.base));
		analyze_expr(s, n->u.subscript.index);
		if (bt && bt->kind == TY_POINTER) {
			t = bt->base;
			n->is_lvalue = 1;
		} else {
			sema_error(s, n, "subscript of non-array");
			t = int_type();
		}
		break;
	}

	case AST_MEMBER: {
		Type *ot = analyze_expr(s, n->u.member.object);
		if (ot && (ot->kind == TY_STRUCT || ot->kind == TY_UNION)) {
			TypeMember *m = ot->members;
			while (m) {
				if (m->name && !strcmp(m->name, n->u.member.member_name)) {
					t = m->type;
					n->is_lvalue = 1;
					n->is_bit_field = m->is_bit_field;
					break;
				}
				m = m->next;
			}
			if (!t) {
				int is_extern_base = 0;
				if (n->u.member.object->kind == AST_IDENT) {
					Symbol *sym = symtab_lookup(s->symtab,
					    n->u.member.object->u.ident.name);
					if (sym && sym->is_extern) is_extern_base = 1;
				}
				if (!is_extern_base) {
					char buf[128];
					sprintf(buf, "no member '%s' in struct/union",
					    n->u.member.member_name);
					sema_error(s, n, buf);
				}
				t = int_type();
				n->is_lvalue = 1;
			}
		} else {
			sema_error(s, n, "member access on non-struct");
			t = int_type();
		}
		break;
	}

	case AST_PTR_MEMBER: {
		Type *pt = decay(analyze_expr(s, n->u.member.object));
		if (pt && pt->kind == TY_POINTER && pt->base &&
		    (pt->base->kind == TY_STRUCT || pt->base->kind == TY_UNION)) {
			Type *ot = pt->base;
			TypeMember *m = ot->members;
			while (m) {
				if (m->name && !strcmp(m->name, n->u.member.member_name)) {
					t = m->type;
					n->is_lvalue = 1;
					n->is_bit_field = m->is_bit_field;
					break;
				}
				m = m->next;
			}
			if (!t) {
				char buf[128];
				sprintf(buf, "no member '%s' in struct/union", n->u.member.member_name);
				sema_error(s, n, buf);
				t = int_type();
			}
		} else {
			sema_error(s, n, "'->' on non-pointer-to-struct");
			t = int_type();
		}
		break;
	}

	case AST_INIT_LIST: {
		AstList *it;
		for (it = n->u.init_list.items; it; it = it->next)
			analyze_expr(s, it->node);
		t = int_type();
		break;
	}
	case AST_DESIGNATED_INIT:
		if (n->u.designated_init.index) {
			analyze_expr(s, n->u.designated_init.index);
			if (!sema_eval_integer_constant(s->symtab, n->u.designated_init.index,
			    &n->u.designated_init.index_value) || n->u.designated_init.index_value < 0)
				sema_error(s, n, "array designator requires a nonnegative integer constant");
			else
				n->u.designated_init.has_index_value = 1;
		}
		t = analyze_expr(s, n->u.designated_init.value);
		break;
	case AST_COMPOUND_LITERAL:
		n->u.compound_literal.init = normalize_initializer(
		    n->u.compound_literal.literal_type, n->u.compound_literal.init);
		analyze_expr(s, n->u.compound_literal.init);
		t = n->u.compound_literal.literal_type;
		if (t && t->kind == TY_ARRAY && t->array_len < 0 &&
		    n->u.compound_literal.init && n->u.compound_literal.init->kind == AST_INIT_LIST) {
			int next_index = 0;
			int required_len = 0;
			AstList *item;
			for (item = n->u.compound_literal.init->u.init_list.items; item; item = item->next) {
				AstNode *init = item->node;
				if (init->kind == AST_DESIGNATED_INIT && init->u.designated_init.has_index_value)
					next_index = (int)init->u.designated_init.index_value;
				if (next_index + 1 > required_len) required_len = next_index + 1;
				next_index++;
			}
			t->array_len = required_len;
		}
		if (t && (t->kind == TY_ARRAY || t->kind == TY_STRUCT || t->kind == TY_UNION) &&
		    (!n->u.compound_literal.init || n->u.compound_literal.init->kind != AST_INIT_LIST))
			sema_error(s, n, "aggregate compound literal requires a brace initializer");
		validate_initializer(s, t, n->u.compound_literal.init);
		n->is_lvalue = 1;
		break;
	default:
		t = int_type();
	}

	if (!t) t = int_type();
	n->type = t;
	n->is_integer_constant = sema_eval_integer_constant(s->symtab, n,
	    &n->integer_constant);
	return t;
}

static Type *analyze_lvalue(Sema *s, AstNode *n) {
	Type *t = analyze_expr(s, n);
	if (!n->is_lvalue && n->kind != AST_UNARY_PRE && n->kind != AST_SUBSCRIPT &&
	    n->kind != AST_MEMBER && n->kind != AST_PTR_MEMBER) {
		
	}
	return t;
}

static void analyze_stmt(Sema *s, AstNode *n) {
	if (!n) return;
	AstList *it;
	switch (n->kind) {
	case AST_BLOCK:
		symtab_push(s->symtab);
		for (it = n->u.block.items; it; it = it->next) {
			if (it->node->kind == AST_VAR_DECL) analyze_decl(s, it->node, 0);
			else                                analyze_stmt(s, it->node);
		}
		symtab_pop(s->symtab);
		break;
	case AST_EXPR_STMT:
		analyze_expr(s, n->u.expr_stmt.expr);
		break;
	case AST_IF:
		analyze_expr(s, n->u.if_stmt.cond);
		analyze_stmt(s, n->u.if_stmt.then_stmt);
		analyze_stmt(s, n->u.if_stmt.else_stmt);
		break;
	case AST_WHILE:
	case AST_DO_WHILE:
		s->loop_depth++;
		analyze_expr(s, n->u.while_stmt.cond);
		analyze_stmt(s, n->u.while_stmt.body);
		s->loop_depth--;
		break;
	case AST_FOR:
		s->loop_depth++;
		if (n->u.for_stmt.init) {
			if (n->u.for_stmt.init->kind == AST_VAR_DECL)
				analyze_decl(s, n->u.for_stmt.init, 0);
			else
				analyze_stmt(s, n->u.for_stmt.init);
		}
		if (n->u.for_stmt.cond) analyze_expr(s, n->u.for_stmt.cond);
		if (n->u.for_stmt.incr) analyze_expr(s, n->u.for_stmt.incr);
		analyze_stmt(s, n->u.for_stmt.body);
		s->loop_depth--;
		break;
	case AST_SWITCH:
		s->switch_depth++;
		analyze_expr(s, n->u.switch_stmt.expr);
		analyze_stmt(s, n->u.switch_stmt.body);
		s->switch_depth--;
		break;
	case AST_CASE:
		analyze_expr(s, n->u.case_stmt.expr);
		if (!n->u.case_stmt.expr->is_integer_constant)
			sema_error(s, n, "case label is not an integer constant expression");
		analyze_stmt(s, n->u.case_stmt.stmt);
		break;
	case AST_DEFAULT:
		analyze_stmt(s, n->u.default_stmt.stmt);
		break;
	case AST_RETURN:
		if (n->u.ret_stmt.expr) analyze_expr(s, n->u.ret_stmt.expr);
		break;
	case AST_LABEL_STMT:
		analyze_stmt(s, n->u.label_stmt.stmt);
		break;
	case AST_BREAK: case AST_CONTINUE: case AST_GOTO:
	case AST_NULL_STMT:
		break;
	default:
		
		if (n->kind == AST_VAR_DECL)    analyze_decl(s, n, 0);
		else if (n->kind == AST_FUNC_DECL) {  }
		break;
	}
}

static int initializer_type_is_aggregate(Type *type) {
	return type && (type->kind == TY_ARRAY || type->kind == TY_STRUCT ||
	    type->kind == TY_UNION);
}

static AstNode *normalize_initializer(Type *type, AstNode *init);

static AstNode *consume_initializer_object(Type *type, AstList **cursor, int line) {
	AstNode *node;
	AstList *entry;
	if (!cursor || !*cursor) return NULL;
	if (initializer_type_is_aggregate(type) &&
	    !(type->kind == TY_ARRAY && (*cursor)->node->kind == AST_STRING_LIT)) {
		if ((*cursor)->node->kind == AST_INIT_LIST) {
			entry = *cursor;
			*cursor = entry->next;
			node = entry->node;
			free(entry);
			return normalize_initializer(type, node);
		}
		node = ast_new(AST_INIT_LIST, line);
		if (type->kind == TY_ARRAY) {
			int index = 0;
			while (*cursor && (type->array_len < 0 || index < type->array_len)) {
				AstNode *child = consume_initializer_object(type->base, cursor, line);
				if (!child) break;
				node->u.init_list.items = ast_list_append(node->u.init_list.items, child);
				index++;
			}
		} else {
			TypeMember *member;
			for (member = type->members; member && *cursor; member = member->next) {
				AstNode *child;
				if (!member->name) continue;
				child = consume_initializer_object(member->type, cursor, line);
				if (!child) break;
				node->u.init_list.items = ast_list_append(node->u.init_list.items, child);
				if (type->kind == TY_UNION) break;
			}
		}
		return node;
	}
	entry = *cursor;
	*cursor = entry->next;
	node = entry->node;
	free(entry);
	return node;
}

static AstNode *normalize_initializer(Type *type, AstNode *init) {
	AstList *item;
	AstList *cursor;
	AstList *normalized = NULL;
	if (!initializer_type_is_aggregate(type) || !init || init->kind != AST_INIT_LIST)
		return init;
	for (item = init->u.init_list.items; item; item = item->next)
		if (item->node && item->node->kind == AST_DESIGNATED_INIT) return init;
	cursor = init->u.init_list.items;
	init->u.init_list.items = NULL;
	if (type->kind == TY_ARRAY) {
		int index = 0;
		while (cursor && (type->array_len < 0 || index < type->array_len)) {
			AstNode *child = consume_initializer_object(type->base, &cursor, init->line);
			if (!child) break;
			normalized = ast_list_append(normalized, child);
			index++;
		}
	} else {
		TypeMember *member;
		for (member = type->members; member && cursor; member = member->next) {
			AstNode *child;
			if (!member->name) continue;
			child = consume_initializer_object(member->type, &cursor, init->line);
			if (!child) break;
			normalized = ast_list_append(normalized, child);
			if (type->kind == TY_UNION) break;
		}
	}
	if (cursor) {
		AstList *tail = normalized;
		if (!tail) normalized = cursor;
		else {
			while (tail->next) tail = tail->next;
			tail->next = cursor;
		}
	}
	init->u.init_list.items = normalized;
	return init;
}

static void validate_initializer(Sema *s, Type *type, AstNode *init) {
	if (!type || !init) return;
	if (init->kind == AST_STRING_LIT) {
		if (type->kind == TY_ARRAY) {
			int string_len = (int)strlen(init->u.str_lit.value);
			if (!type->base || (type->base->kind != TY_CHAR && type->base->kind != TY_UCHAR))
				sema_error(s, init, "string literal can only initialize a character array");
			else if (type->array_len >= 0 && type->array_len < string_len)
				sema_error(s, init, "initializer string is too long for character array");
		} else if (type->kind != TY_POINTER) {
			sema_error(s, init, "string literal is invalid for this initializer");
		}
		return;
	}
	if (init->kind == AST_DESIGNATED_INIT) {
		if (init->u.designated_init.index) {
			if (type->kind != TY_ARRAY) {
				sema_error(s, init, "array designator is invalid for this initializer");
				return;
			}
			if (init->u.designated_init.has_index_value && type->array_len >= 0 &&
			    init->u.designated_init.index_value >= type->array_len)
				sema_error(s, init, "array designator index exceeds array bounds");
			validate_initializer(s, type->base, init->u.designated_init.value);
			return;
		}
		if (init->u.designated_init.member_name) {
			TypeMember *member;
			if (type->kind != TY_STRUCT && type->kind != TY_UNION) {
				sema_error(s, init, "member designator is invalid for this initializer");
				return;
			}
			member = type->members;
			while (member && (!member->name ||
			       strcmp(member->name, init->u.designated_init.member_name)))
				member = member->next;
			if (!member) {
				sema_error(s, init, "initializer designates an unknown member");
				return;
			}
			validate_initializer(s, member->type, init->u.designated_init.value);
		}
		return;
	}
	if (init->kind != AST_INIT_LIST) return;

	if (type->kind == TY_ARRAY) {
		int cursor = 0;
		AstList *item;
		for (item = init->u.init_list.items; item; item = item->next) {
			AstNode *value = item->node;
			if (value->kind == AST_DESIGNATED_INIT) {
				validate_initializer(s, type, value);
				if (value->u.designated_init.has_index_value)
					cursor = (int)value->u.designated_init.index_value;
			} else {
				if (type->array_len >= 0 && cursor >= type->array_len)
					sema_error(s, value, "excess elements in array initializer");
				else
					validate_initializer(s, type->base, value);
			}
			cursor++;
		}
		return;
	}

	if (type->kind == TY_STRUCT || type->kind == TY_UNION) {
		TypeMember *member = type->members;
		AstList *item;
		for (item = init->u.init_list.items; item; item = item->next) {
			AstNode *value = item->node;
			if (value->kind == AST_DESIGNATED_INIT) {
				validate_initializer(s, type, value);
				if (value->u.designated_init.member_name) {
					member = type->members;
					while (member && (!member->name ||
					       strcmp(member->name, value->u.designated_init.member_name)))
						member = member->next;
				}
			} else if (!member) {
				sema_error(s, value, "excess elements in struct or union initializer");
			} else {
				validate_initializer(s, member->type, value);
			}
			if (member) member = member->next;
			if (type->kind == TY_UNION && item->next)
				sema_error(s, item->next->node, "excess elements in union initializer");
		}
		return;
	}

	if (init->u.init_list.items) {
		AstList *excess = init->u.init_list.items->next;
		if (type_is_complex(type) && excess) excess = excess->next;
		if (excess)
			sema_error(s, excess->node, "excess elements in scalar initializer");
	}
}

static void analyze_vm_bounds(Sema *s, Type *type) {
	if (!type) return;
	if (type->kind == TY_ARRAY) {
		if (type->vla_size) {
			Type *bound_type = analyze_expr(s, type->vla_size);
			if (!type_is_integer(bound_type))
				sema_error(s, type->vla_size,
				    "variable-length array bound must have integer type");
		}
		analyze_vm_bounds(s, type->base);
	} else if (type->kind == TY_POINTER) {
		analyze_vm_bounds(s, type->base);
	}
}

static void check_function_declaration(Sema *s, AstNode *n, int is_definition) {
	Symbol *sym;
	int declared_linkage;
	if (!n || !n->u.func.name) return;
	sym = symtab_lookup(s->symtab, n->u.func.name);
	if (!sym) {
		sym = symtab_define(s->symtab, n->u.func.name, SYM_FUNC,
		    n->u.func.func_type);
		sym->func_label = func_label_for(n->u.func.name, n->u.func.is_extern);
	}
	declared_linkage = n->u.func.is_static ? 1 : 2;
	if (n->u.func.is_extern && sym->linkage) declared_linkage = sym->linkage;
	if (sym->linkage && sym->linkage != declared_linkage)
		sema_error(s, n, "conflicting linkage for function declaration");
	else if (!sym->linkage)
		sym->linkage = declared_linkage;
	if (is_definition) {
		if (sym->has_definition)
			sema_error(s, n, "redefinition of function");
		else
			sym->has_definition = 1;
	}
}

static void analyze_decl(Sema *s, AstNode *n, int is_global) {
	if (!n) return;
	switch (n->kind) {
	case AST_VAR_DECL: {
		n->u.var.init = normalize_initializer(n->u.var.var_type, n->u.var.init);
		if (type_is_variably_modified(n->u.var.var_type)) {
			analyze_vm_bounds(s, n->u.var.var_type);
			if (is_global)
				sema_error(s, n, "variably modified declaration is only allowed at block scope");
			if (n->u.var.is_static)
				sema_error(s, n, "variably modified object cannot have static storage duration");
			if (n->u.var.is_extern)
				sema_error(s, n, "variably modified object cannot have linkage");
			if (n->u.var.var_type->kind == TY_ARRAY &&
			    n->u.var.var_type->vla_size && n->u.var.init)
				sema_error(s, n, "variable-length array cannot have an initializer");
		}
		Symbol *sym = symtab_lookup_current(s->symtab, n->u.var.name ? n->u.var.name : "");
		if (!sym && n->u.var.name) {
			sym = symtab_define(s->symtab, n->u.var.name, SYM_VAR, n->u.var.var_type);
		}
		if (sym) {
			if (is_global) {
				int declared_linkage = n->u.var.is_static ? 1 : 2;
				if (n->u.var.is_extern && sym->linkage) declared_linkage = sym->linkage;
				if (sym->linkage && sym->linkage != declared_linkage)
					sema_error(s, n, "conflicting linkage for object declaration");
				else if (!sym->linkage)
					sym->linkage = declared_linkage;
				if (n->u.var.init) {
					if (sym->has_definition)
						sema_error(s, n, "redefinition of file-scope object");
					else
						sym->has_definition = 1;
				}
			}
			sym->is_global = is_global;
			sym->is_vla = n->u.var.var_type && n->u.var.var_type->kind == TY_ARRAY &&
			    n->u.var.var_type->vla_size != NULL;
			if (n->u.var.is_extern) {
				sym->is_extern = 1;
				if (!sym->asm_label) sym->asm_label = strdup(n->u.var.name);
				check_extern_asm_kind(s, n, n->u.var.name, 0);
			}
		}
		if (n->u.var.init) analyze_expr(s, n->u.var.init);
		if (n->u.var.var_type && n->u.var.var_type->kind == TY_ARRAY &&
		    n->u.var.var_type->array_len < 0 && n->u.var.init &&
		    n->u.var.init->kind == AST_STRING_LIT && n->u.var.var_type->base &&
		    (n->u.var.var_type->base->kind == TY_CHAR ||
		     n->u.var.var_type->base->kind == TY_UCHAR))
			n->u.var.var_type->array_len = (int)strlen(n->u.var.init->u.str_lit.value) + 1;
		if (n->u.var.var_type && n->u.var.var_type->kind == TY_ARRAY &&
		    n->u.var.var_type->array_len < 0 &&
		    n->u.var.init && n->u.var.init->kind == AST_INIT_LIST) {
			int next_index = 0;
			int required_len = 0;
			AstList *item;
			for (item = n->u.var.init->u.init_list.items; item; item = item->next) {
				AstNode *init = item->node;
				if (init->kind == AST_DESIGNATED_INIT && init->u.designated_init.member_name)
					sema_error(s, init, "member designator is invalid for an array initializer");
				if (init->kind == AST_DESIGNATED_INIT && init->u.designated_init.has_index_value)
					next_index = (int)init->u.designated_init.index_value;
				if (next_index + 1 > required_len) required_len = next_index + 1;
				next_index++;
			}
			n->u.var.var_type->array_len = required_len;
		}
		validate_initializer(s, n->u.var.var_type, n->u.var.init);
		break;
	}
	case AST_FUNC_DEF:
		analyze_func(s, n);
		break;
	case AST_FUNC_DECL: {
		check_function_declaration(s, n, 0);
		if (n->u.func.name) {
			Symbol *sym = symtab_lookup(s->symtab, n->u.func.name);
			if (!sym) {
				sym = symtab_define(s->symtab, n->u.func.name, SYM_FUNC, n->u.func.func_type);
				sym->func_label = func_label_for(n->u.func.name, n->u.func.is_extern);
			}
			sym->is_extern = n->u.func.is_extern;
			if (n->u.func.is_extern)
				check_extern_asm_kind(s, n, n->u.func.name, 1);
		}
		break;
	}
	case AST_TYPEDEF_DECL:
		if (n->u.typedef_decl.name) {
			if (type_is_variably_modified(n->u.typedef_decl.alias_type)) {
				if (is_global)
					sema_error(s, n,
					    "variably modified typedef is only allowed at block scope");
				else
					analyze_vm_bounds(s, n->u.typedef_decl.alias_type);
			}
			Symbol *existing = symtab_lookup_current(s->symtab, n->u.typedef_decl.name);
			if (!existing) {
				symtab_define(s->symtab, n->u.typedef_decl.name, SYM_TYPEDEF,
				    n->u.typedef_decl.alias_type);
			}
		}
		break;
	case AST_BLOCK:
		for (AstList *it = n->u.block.items; it; it = it->next)
			analyze_decl(s, it->node, is_global);
		break;
	default:
		break;
	}
}

static void analyze_func(Sema *s, AstNode *n) {
	Type *ret = n->u.func.func_type ? n->u.func.func_type->base : NULL;
	Type *saved = s->current_func_ret;
	s->current_func_ret = ret;
	check_function_declaration(s, n, 1);

	
	if (n->u.func.name) {
		Symbol *sym = symtab_lookup(s->symtab, n->u.func.name);
		if (!sym) {
			const char *fn = n->u.func.name;
			sym = symtab_define(s->symtab, fn, SYM_FUNC, n->u.func.func_type);
			sym->func_label = func_label_for(fn, n->u.func.is_extern);
		}
	}

	symtab_push(s->symtab);
	
	AstList *pl = n->u.func.params;
	while (pl) {
		AstNode *pn = pl->node;
		if (pn->u.var.name) {
			Symbol *sym = symtab_define(s->symtab, pn->u.var.name, SYM_VAR, pn->u.var.var_type);
			sym->is_global = 0;
		}
		pl = pl->next;
	}
	if (n->u.func.body) {
		AstList *it = n->u.func.body->u.block.items;
		while (it) {
			if (it->node->kind == AST_VAR_DECL)
				analyze_decl(s, it->node, 0);
			else
				analyze_stmt(s, it->node);
			it = it->next;
		}
	}
	symtab_pop(s->symtab);

	s->current_func_ret = saved;
}

static void reg_builtin(Sema *s, const char *name, BuiltinId bid,
                        Type *ret, int nparams, ...) {
	TypeParam *head = NULL, **cur = &head;
	va_list ap;
	int i;
	va_start(ap, nparams);
	for (i = 0; i < nparams; i++) {
		TypeParam *p = (TypeParam *)calloc(1, sizeof(TypeParam));
		p->type = va_arg(ap, Type *);
		*cur = p;
		cur = &p->next;
	}
	va_end(ap);
	{
		Symbol *sym = symtab_define(s->symtab, name, SYM_FUNC,
		    type_make_function(ret, head, 0));
		sym->builtin_id = bid;
	}
}

void sema_init(Sema *s, SymTab *st) {
	memset(s, 0, sizeof(*s));
	s->symtab = st;

	
	reg_builtin(s, "print_int",        BUILTIN_PRINT_INT,       type_make_void(), 1,
	    type_make_int(0));
	reg_builtin(s, "println_int",   BUILTIN_PRINT_LINE_INT,  type_make_void(), 1,
	    type_make_int(0));
	reg_builtin(s, "print_float",      BUILTIN_PRINT_FLOAT,     type_make_void(), 2,
	    type_make_float(), type_make_int(0));
	reg_builtin(s, "println_float", BUILTIN_PRINT_LINE_FLOAT, type_make_void(), 2,
	    type_make_float(), type_make_int(0));
	reg_builtin(s, "print_string",     BUILTIN_PRINT_STRING,    type_make_void(), 1,
	    type_make_pointer(type_make_char(0)));
	reg_builtin(s, "println_string", BUILTIN_PRINT_LINE_STRING, type_make_void(), 1,
	    type_make_pointer(type_make_char(0)));
	reg_builtin(s, "draw_rect",   BUILTIN_DRAW_RECT,   type_make_void(), 5,
	    type_make_int(0), type_make_int(0), type_make_int(0),
	    type_make_int(0), type_make_int(0));
	reg_builtin(s, "draw_texture", BUILTIN_DRAW_TEXTURE, type_make_void(), 4,
	    type_make_pointer(type_make_void()), type_make_int(0),
	    type_make_int(0), type_make_int(0));
	reg_builtin(s, "draw_texture_region", BUILTIN_DRAW_TEXTURE_REGION, type_make_void(), 8,
	    type_make_pointer(type_make_void()), type_make_int(0), type_make_int(0),
	    type_make_int(0), type_make_int(0), type_make_int(0),
	    type_make_int(0), type_make_int(0));
	reg_builtin(s, "storage_read",  BUILTIN_STORAGE_READ,  type_make_void(), 3,
	    type_make_pointer(type_make_void()),
	    type_make_pointer(type_make_void()), type_make_int(0));
	reg_builtin(s, "storage_write", BUILTIN_STORAGE_WRITE, type_make_void(), 3,
	    type_make_pointer(type_make_void()),
	    type_make_pointer(type_make_void()), type_make_int(0));
	reg_builtin(s, "mem_copy",   BUILTIN_MEM_COPY,  type_make_void(), 3,
	    type_make_pointer(type_make_void()),
	    type_make_pointer(type_make_void()), type_make_int(0));
	reg_builtin(s, "mem_set",    BUILTIN_MEM_SET,   type_make_void(), 3,
	    type_make_pointer(type_make_void()), type_make_int(0), type_make_int(0));
	reg_builtin(s, "preserve_back_buffer",  BUILTIN_PRESERVE_BACK_BUFFER,  type_make_void(), 0);
	reg_builtin(s, "preserve_front_buffer", BUILTIN_PRESERVE_FRONT_BUFFER, type_make_void(), 0);
	reg_builtin(s, "get_input",               BUILTIN_GET_INPUT,               type_make_int(0),  0);
	reg_builtin(s, "get_mouse_x",             BUILTIN_GET_MOUSE_X,             type_make_int(0),  0);
	reg_builtin(s, "get_mouse_y",             BUILTIN_GET_MOUSE_Y,             type_make_int(0),  0);
	reg_builtin(s, "get_mouse_button_input",  BUILTIN_GET_MOUSE_BUTTON_INPUT,  type_make_int(0),  0);
	reg_builtin(s, "get_keyboard_input",      BUILTIN_GET_KEYBOARD_INPUT,      type_make_int(0),  0);
	reg_builtin(s, "get_keyboard_input_flags", BUILTIN_GET_KEYBOARD_INPUT_FLAGS, type_make_int(0), 0);
	reg_builtin(s, "get_terminal_input_size", BUILTIN_GET_TERMINAL_INPUT_SIZE, type_make_int(0),  0);
	reg_builtin(s, "read_terminal_input",     BUILTIN_READ_TERMINAL_INPUT,     type_make_int(0),  2,
	    type_make_pointer(type_make_char(0)), type_make_int(0));
	reg_builtin(s, "get_unix_time",    BUILTIN_GET_UNIX_TIME,    type_make_int(0),  0);
	reg_builtin(s, "get_running_time", BUILTIN_GET_RUNNING_TIME, type_make_float(), 0);
	reg_builtin(s, "get_update_delta", BUILTIN_GET_UPDATE_DELTA, type_make_float(), 0);
	reg_builtin(s, "get_draw_delta",   BUILTIN_GET_DRAW_DELTA,   type_make_float(), 0);
	reg_builtin(s, "set_rng_seed",     BUILTIN_SET_RNG_SEED,     type_make_void(),  1,
	    type_make_int(0));

	{
		static const struct { const char *name; int val; } sysc[] = {
			{ "SYS_PRINT_INT",                0  },
			{ "SYS_PRINT_LINE_INT",           1  },
			{ "SYS_PRINT_FLOAT",              2  },
			{ "SYS_PRINT_LINE_FLOAT",         3  },
			{ "SYS_PRINT_STRING",             4  },
			{ "SYS_PRINT_LINE_STRING",        5  },
			{ "SYS_DRAW_RECT",                6  },
			{ "SYS_DRAW_TEXTURE",             7  },
			{ "SYS_DRAW_TEXTURE_REGION",      8  },
			{ "SYS_PRESERVE_BACK_BUFFER",     9  },
			{ "SYS_PRESERVE_FRONT_BUFFER",    10 },
			{ "SYS_GET_INPUT",                11 },
			{ "SYS_GET_MOUSE_POSITION",       24 },
			{ "SYS_GET_MOUSE_BUTTON_INPUT",   25 },
			{ "SYS_GET_KEYBOARD_INPUT",       26 },
			{ "SYS_GET_TERMINAL_INPUT_SIZE",  12 },
			{ "SYS_READ_TERMINAL_INPUT",      13 },
			{ "SYS_STORAGE_READ",             14 },
			{ "SYS_STORAGE_WRITE",            15 },
			{ "SYS_MEM_COPY",                 16 },
			{ "SYS_MEM_SET",                  17 },
			{ "SYS_GET_UNIX_TIME",            18 },
			{ "SYS_GET_RUNNING_TIME",         19 },
			{ "SYS_GET_UPDATE_DELTA",         20 },
			{ "SYS_GET_DRAW_DELTA",           21 },
			{ "SYS_SET_RNG_SEED",             22 },
			{ "SYS_ALLOW_UNSAFE_JUMP",        23 },
			{ NULL, 0 }
		};
		int i;
		for (i = 0; sysc[i].name; i++) {
			Symbol *sym = symtab_define(s->symtab, sysc[i].name,
			    SYM_ENUM_CONST, type_make_int(0));
			sym->enum_value = sysc[i].val;
		}
	}

	{
		static const struct { const char *name; int val; } mbtn[] = {
			{ "MOUSE_BTN_LEFT",       1  },
			{ "MOUSE_BTN_RIGHT",      2  },
			{ "MOUSE_BTN_MIDDLE",     4  },
			{ "MOUSE_BTN_WHEEL_UP",   8  },
			{ "MOUSE_BTN_WHEEL_DOWN", 16 },
			{ NULL, 0 }
		};
		int i;
		for (i = 0; mbtn[i].name; i++) {
			Symbol *sym = symtab_define(s->symtab, mbtn[i].name,
			    SYM_ENUM_CONST, type_make_int(0));
			sym->enum_value = mbtn[i].val;
		}
	}

	{
		static const struct { const char *name; int val; } btn[] = {
			{ "BTN_SELECT", 512 },
			{ "BTN_START", 256 },
			{ "BTN_LEFT", 128 },
			{ "BTN_RIGHT", 64 },
			{ "BTN_UP", 32 },
			{ "BTN_DOWN", 16 },
			{ "BTN_A", 8 },
			{ "BTN_B", 4 },
			{ "BTN_X", 2 },
			{ "BTN_Y", 1 },
			{ NULL, 0 }
		};
		int i;
		for (i = 0; btn[i].name; i++) {
			Symbol *sym = symtab_define(s->symtab, btn[i].name,
			    SYM_ENUM_CONST, type_make_int(0));
			sym->enum_value = btn[i].val;
		}
	}

	{
		static const struct { const char *name; int val; } kbe[] = {
			{ "KBE_PRESSED", 1 },
			{ "KBE_REPEAT", 2 },
			{ "KBE_CTRL", 4 },
			{ "KBE_SHIFT", 8 },
			{ "KBE_ALT", 16 },
			{ NULL, 0 }
		};
		int i;
		for (i = 0; kbe[i].name; i++) {
			Symbol *sym = symtab_define(s->symtab, kbe[i].name,
			    SYM_ENUM_CONST, type_make_int(0));
			sym->enum_value = kbe[i].val;
		}
	}

	{
		static const struct { const char *name; int val; } key[] = {
			{ "KEY_TAB", 0x80 },
			{ "KEY_BACKSPACE", 0x81 },
			{ "KEY_ENTER", 0x82 },
			{ "KEY_ESC", 0x83 },
			{ "KEY_CTRL", 0x84 },
			{ "KEY_SHIFT", 0x85 },
			{ "KEY_ALT", 0x86 },
			{ "KEY_LEFT", 0x87 },
			{ "KEY_RIGHT", 0x88 },
			{ "KEY_UP", 0x89 },
			{ "KEY_DOWN", 0x8a },
			{ "KEY_INSERT", 0x8b },
			{ "KEY_DELETE", 0x8c },
			{ "KEY_HOME", 0x8d },
			{ "KEY_END", 0x8e },
			{ "KEY_PAGE_UP", 0x8f },
			{ "KEY_PAGE_DOWN", 0x90 },
			{ NULL, 0 }
		};
		int i;
		for (i = 0; key[i].name; i++) {
			Symbol *sym = symtab_define(s->symtab, key[i].name,
			    SYM_ENUM_CONST, type_make_int(0));
			sym->enum_value = key[i].val;
		}
	}

	{
		TypeParam *p = (TypeParam *)calloc(1, sizeof(TypeParam));
		p->type = type_make_int(0);
		Symbol *sym = symtab_define(s->symtab, "syscall", SYM_FUNC,
		    type_make_function(type_make_int(0), p, 1));
		sym->builtin_id = BUILTIN_SYSCALL;
	}

	reg_builtin(s, "to_pa", BUILTIN_TO_PA, type_make_int(0), 1,
	    type_make_pointer(type_make_void()));

	reg_builtin(s, "yield", BUILTIN_YIELD, type_make_void(), 0);
	reg_builtin(s, "exit",  BUILTIN_EXIT,  type_make_void(), 0);
	reg_builtin(s, "break",   BUILTIN_BREAK, type_make_void(), 0);
}

void sema_analyze(Sema *s, AstNode *unit) {
	if (!unit || unit->kind != AST_TRANSLATION_UNIT) return;
	s->asm_labels = asm_labels_scan(unit->u.unit.asm_includes, unit->u.unit.asm_include_count);
	AstList *it = unit->u.unit.decls;
	while (it) {
		analyze_decl(s, it->node, 1);
		it = it->next;
	}
	asm_labels_free(s->asm_labels);
	s->asm_labels = NULL;
}
