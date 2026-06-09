#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include "sema.h"

static void  analyze_decl(Sema *s, AstNode *n, int is_global);
static void  analyze_func(Sema *s, AstNode *n);
static void  analyze_stmt(Sema *s, AstNode *n);
static Type *analyze_expr(Sema *s, AstNode *n);
static Type *analyze_lvalue(Sema *s, AstNode *n);

static void sema_error(Sema *s, AstNode *n, const char *msg) {
	fprintf(stderr, "%d: error: %s\n", n ? n->line : 0, msg);
	s->had_error = 1;
}

static Type *int_type(void)   { return type_make_int(0); }
static Type *float_type(void) { return type_make_float(); }
static Type *ptr_type(Type *base) { return type_make_pointer(base); }
static Type *void_type(void)  { return type_make_void(); }


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
		t = int_type();
		break;
	case AST_FLOAT_LIT:
		t = float_type();
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
			t = type_is_float(ot) ? float_type() : int_type();
			break;
		case TOK_TILDE:
			t = int_type();
			break;
		case TOK_BANG:
			t = int_type();
			break;
		case TOK_PLUS_PLUS: case TOK_MINUS_MINUS:
			t = ot;
			n->is_lvalue = 0;
			break;
		case TOK_AMPERSAND:
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
		case TOK_LT:    case TOK_GT:
		case TOK_LT_EQ: case TOK_GT_EQ:
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
		case TOK_LSHIFT:    case TOK_RSHIFT:
			t = int_type();
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
	default:
		t = int_type();
	}

	if (!t) t = int_type();
	n->type = t;
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

static void analyze_decl(Sema *s, AstNode *n, int is_global) {
	if (!n) return;
	switch (n->kind) {
	case AST_VAR_DECL: {
		Symbol *sym = symtab_lookup_current(s->symtab, n->u.var.name ? n->u.var.name : "");
		if (!sym && n->u.var.name) {
			sym = symtab_define(s->symtab, n->u.var.name, SYM_VAR, n->u.var.var_type);
		}
		if (sym) {
			sym->is_global = is_global;
			if (n->u.var.is_extern) {
				sym->is_extern = 1;
				if (!sym->asm_label) sym->asm_label = strdup(n->u.var.name);
			}
		}
		if (n->u.var.init) analyze_expr(s, n->u.var.init);
		if (n->u.var.var_type && n->u.var.var_type->kind == TY_ARRAY &&
		    n->u.var.var_type->array_len < 0 &&
		    n->u.var.init && n->u.var.init->kind == AST_INIT_LIST) {
			n->u.var.var_type->array_len = ast_list_len(n->u.var.init->u.init_list.items);
		}
		break;
	}
	case AST_FUNC_DEF:
		analyze_func(s, n);
		break;
	case AST_FUNC_DECL: {
		if (n->u.func.name) {
			Symbol *sym = symtab_lookup(s->symtab, n->u.func.name);
			if (!sym) {
				sym = symtab_define(s->symtab, n->u.func.name, SYM_FUNC, n->u.func.func_type);
				const char *fn = n->u.func.name;
				if (n->u.func.is_extern || fn[0] == '_') {
					sym->func_label = strdup(fn);
				} else {
					sym->func_label = (char *)malloc(strlen(fn) + 2);
					sprintf(sym->func_label, "%s_", fn);
				}
			}
		}
		break;
	}
	case AST_TYPEDEF_DECL:
		if (n->u.typedef_decl.name) {
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

	
	if (n->u.func.name) {
		Symbol *sym = symtab_lookup(s->symtab, n->u.func.name);
		if (!sym) {
			const char *fn = n->u.func.name;
			sym = symtab_define(s->symtab, fn, SYM_FUNC, n->u.func.func_type);
			if (n->u.func.is_extern || fn[0] == '_') {
				sym->func_label = strdup(fn);
			} else {
				sym->func_label = (char *)malloc(strlen(fn) + 2);
				sprintf(sym->func_label, "%s_", fn);
			}
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

	
	reg_builtin(s, "print_int", BUILTIN_PRINT_INT,    type_make_void(), 1,
	    type_make_int(0));
	reg_builtin(s, "print_float", BUILTIN_PRINT_FLOAT,  type_make_void(), 2,
	    type_make_float(), type_make_int(0));
	reg_builtin(s, "print_string", BUILTIN_PRINT_STRING, type_make_void(), 1,
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
	reg_builtin(s, "get_input",        BUILTIN_GET_INPUT,        type_make_int(0),  0);
	reg_builtin(s, "get_unix_time",    BUILTIN_GET_UNIX_TIME,    type_make_int(0),  0);
	reg_builtin(s, "get_running_time", BUILTIN_GET_RUNNING_TIME, type_make_float(), 0);
	reg_builtin(s, "get_update_delta", BUILTIN_GET_UPDATE_DELTA, type_make_float(), 0);
	reg_builtin(s, "get_draw_delta",   BUILTIN_GET_DRAW_DELTA,   type_make_float(), 0);
	reg_builtin(s, "set_rng_seed",     BUILTIN_SET_RNG_SEED,     type_make_void(),  1,
	    type_make_int(0));

	{
		static const struct { const char *name; int val; } sysc[] = {
			{ "SYS_PRINT_INT",             0  },
			{ "SYS_PRINT_FLOAT",           1  },
			{ "SYS_PRINT_STRING",          2  },
			{ "SYS_DRAW_RECT",             3  },
			{ "SYS_DRAW_TEXTURE",          4  },
			{ "SYS_DRAW_TEXTURE_REGION",   5  },
			{ "SYS_STORAGE_READ",          6  },
			{ "SYS_STORAGE_WRITE",         7  },
			{ "SYS_MEM_COPY",              8  },
			{ "SYS_MEM_SET",               9  },
			{ "SYS_PRESERVE_BACK_BUFFER",  10 },
			{ "SYS_PRESERVE_FRONT_BUFFER", 11 },
			{ "SYS_GET_INPUT",             12 },
			{ "SYS_GET_UNIX_TIME",         13 },
			{ "SYS_GET_RUNNING_TIME",      14 },
			{ "SYS_GET_UPDATE_DELTA",      15 },
			{ "SYS_GET_DRAW_DELTA",        16 },
			{ "SYS_SET_RNG_SEED",          17 },
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
	AstList *it = unit->u.unit.decls;
	while (it) {
		analyze_decl(s, it->node, 1);
		it = it->next;
	}
}
