#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include "codegen.h"

typedef struct {
	BuiltinId   id;
	const char *syscall_name;
	int         tpr_mask; 
} BuiltinInfo;

static const BuiltinInfo builtin_table[] = {
	{ BUILTIN_PRINT_INT,             "SYS_PRINT_INT",             0 },
	{ BUILTIN_PRINT_FLOAT,           "SYS_PRINT_FLOAT",           0 },
	{ BUILTIN_PRINT_STRING,          "SYS_PRINT_STRING",          1 }, 
	{ BUILTIN_DRAW_RECT,             "SYS_DRAW_RECT",             0 },
	{ BUILTIN_DRAW_TEXTURE,          "SYS_DRAW_TEXTURE",          1 }, 
	{ BUILTIN_DRAW_TEXTURE_REGION,   "SYS_DRAW_TEXTURE_REGION",   1 }, 
	{ BUILTIN_STORAGE_READ,          "SYS_STORAGE_READ",          1 }, 
	{ BUILTIN_STORAGE_WRITE,         "SYS_STORAGE_WRITE",         2 }, 
	{ BUILTIN_MEM_COPY,              "SYS_MEM_COPY",              3 }, 
	{ BUILTIN_MEM_SET,               "SYS_MEM_SET",               1 }, 
	{ BUILTIN_PRESERVE_BACK_BUFFER,  "SYS_PRESERVE_BACK_BUFFER",  0 },
	{ BUILTIN_PRESERVE_FRONT_BUFFER, "SYS_PRESERVE_FRONT_BUFFER", 0 },
	{ BUILTIN_GET_INPUT,             "SYS_GET_INPUT",             0 },
	{ BUILTIN_GET_UNIX_TIME,         "SYS_GET_UNIX_TIME",         0 },
	{ BUILTIN_GET_RUNNING_TIME,      "SYS_GET_RUNNING_TIME",      0 },
	{ BUILTIN_GET_UPDATE_DELTA,      "SYS_GET_UPDATE_DELTA",      0 },
	{ BUILTIN_GET_DRAW_DELTA,        "SYS_GET_DRAW_DELTA",        0 },
	{ BUILTIN_SET_RNG_SEED,          "SYS_SET_RNG_SEED",          0 },
	{ BUILTIN_NONE, NULL, 0 }
};

static const BuiltinInfo *builtin_lookup(BuiltinId id) {
	int i;
	for (i = 0; builtin_table[i].id != BUILTIN_NONE; i++)
		if (builtin_table[i].id == id) return &builtin_table[i];
	return NULL;
}

static void asm_type_add(CodeGen *cg, const char *label, const char *misa_type) {
	if (cg->asm_type_count >= cg->asm_type_cap) {
		cg->asm_type_cap = cg->asm_type_cap ? cg->asm_type_cap * 2 : 16;
		cg->asm_type_map = (struct AsmTypeEntry *)realloc(cg->asm_type_map,
		    cg->asm_type_cap * sizeof(*cg->asm_type_map));
	}
	cg->asm_type_map[cg->asm_type_count].label     = strdup(label);
	cg->asm_type_map[cg->asm_type_count].misa_type = strdup(misa_type);
	cg->asm_type_count++;
}

static const char *asm_type_lookup(CodeGen *cg, const char *label) {
	int i;
	for (i = 0; i < cg->asm_type_count; i++)
		if (!strcmp(cg->asm_type_map[i].label, label))
			return cg->asm_type_map[i].misa_type;
	return NULL;
}

static void parse_asm_types(CodeGen *cg, const char *path) {
	FILE *f = fopen(path, "r");
	if (!f) return;
	char line[1024];
	char global_label[256];
	global_label[0] = '\0';
	while (fgets(line, sizeof(line), f)) {
		char *p = line;
		while (*p == ' ' || *p == '\t') p++;
		if (*p == '#' || *p == '\0' || *p == '\n' || *p == '\r') continue;
		if (*p == '@') continue;
		int is_local = (*p == '.');
		if (is_local) p++;
		char ident[256];
		int ident_len = 0;
		while (*p && (isalnum((unsigned char)*p) || *p == '_') && ident_len < 255)
			ident[ident_len++] = *p++;
		ident[ident_len] = '\0';
		if (ident_len == 0) continue;
		while (*p == ' ' || *p == '\t') p++;
		if (*p != ':') continue;
		p++;
		while (*p == ' ' || *p == '\t') p++;
		if (strncmp(p, "emb", 3) != 0 || isalnum((unsigned char)p[3]) || p[3] == '_') {
			if (!is_local) {
				strncpy(global_label, ident, 255);
				global_label[255] = '\0';
			}
			continue;
		}
		p += 3;
		while (*p == ' ' || *p == '\t') p++;
		char type_name[32];
		int type_len = 0;
		while (*p && !isspace((unsigned char)*p) && type_len < 31)
			type_name[type_len++] = *p++;
		type_name[type_len] = '\0';
		if (type_len == 0) continue;
		char full_label[512];
		if (is_local && global_label[0]) {
			sprintf(full_label, "%s.%s", global_label, ident);
		} else {
			strncpy(full_label, ident, 511);
			full_label[511] = '\0';
			if (!is_local) {
				strncpy(global_label, ident, 255);
				global_label[255] = '\0';
			}
		}
		asm_type_add(cg, full_label, type_name);
	}
	fclose(f);
}

static char *cg_new_label(CodeGen *cg) {
	char buf[32];
	sprintf(buf, "__L%d", cg->label_counter++);
	return strdup(buf);
}

static int cg_alloc_temp(CodeGen *cg) {
	int i;
	for (i = 0; i < 15; i++) {
		if (!cg->temp_used[i]) {
			cg->temp_used[i] = 1;
			return i;
		}
	}
	fprintf(stderr, "codegen: out of temp registers\n");
	return 0;
}

static void cg_free_temp(CodeGen *cg, int r) {
	if (r >= 0 && r < 15) cg->temp_used[r] = 0;
}

static const char *temp_name(int r) {
	static const char *names[] = {
		"t0","t1","t2","t3","t4","t5","t6","t7",
		"t8","t9","t10","t11","t12","t13","t14"
	};
	if (r < 0 || r >= 15) return "t0";
	return names[r];
}

static const char *arg_name(int r) {
	static const char *names[] = {
		"a0","a1","a2","a3","a4","a5","a6","a7",
		"a8","a9","a10","a11","a12","a13","a14","a15"
	};
	if (r < 0 || r >= 16) return "a0";
	return names[r];
}

static void emit(CodeGen *cg, const char *fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	fprintf(cg->out, "\t");
	vfprintf(cg->out, fmt, ap);
	fprintf(cg->out, "\n");
	va_end(ap);
}

static void emit_label(CodeGen *cg, const char *label) {
	fprintf(cg->out, "%s:\n", label);
}

static void emit_comment(CodeGen *cg, const char *msg) {
	fprintf(cg->out, "\t# %s\n", msg);
}

static int cg_intern_string(CodeGen *cg, const char *value) {
	int i;
	for (i = 0; i < cg->str_count; i++) {
		if (!strcmp(cg->strings[i].value, value)) return cg->strings[i].id;
	}
	if (cg->str_count >= cg->str_cap) {
		cg->str_cap = cg->str_cap ? cg->str_cap * 2 : 8;
		cg->strings = (struct StrEntry *)realloc(cg->strings,
		    cg->str_cap * sizeof(*cg->strings));
	}
	int id = cg->label_counter++;
	cg->strings[cg->str_count].value = strdup(value);
	cg->strings[cg->str_count].id    = id;
	cg->str_count++;
	return id;
}

typedef struct FrameVar {
	char           *name;
	int             fp_offset;   
	int             size;
	struct FrameVar *next;
} FrameVar;

typedef struct {
	FrameVar *vars;
	int       total;     
} FrameLayout;

static void frame_add(FrameLayout *fl, const char *name, int size, int align) {
	
	if (align < 1) align = 1;
	
	int aligned_size = (size + 3) & ~3;
	fl->total += aligned_size;
	FrameVar *fv = (FrameVar *)calloc(1, sizeof(FrameVar));
	fv->name      = name ? strdup(name) : NULL;
	fv->fp_offset = -(fl->total);
	fv->size      = aligned_size;
	fv->next      = NULL;
	if (!fl->vars) {
		fl->vars = fv;
	} else {
		FrameVar *last = fl->vars;
		while (last->next) last = last->next;
		last->next = fv;
	}
	(void)align;
}

static FrameVar *frame_find(FrameLayout *fl, const char *name) {
	FrameVar *v = fl->vars;
	while (v) {
		if (v->name && !strcmp(v->name, name)) return v;
		v = v->next;
	}
	return NULL;
}

static void frame_free(FrameLayout *fl) {
	FrameVar *v = fl->vars;
	while (v) {
		FrameVar *next = v->next;
		free(v->name);
		free(v);
		v = next;
	}
	fl->vars = NULL;
	fl->total = 0;
}


static void collect_locals(AstNode *n, FrameLayout *fl, int is_param, int *param_idx) {
	if (!n) return;
	if (n->kind == AST_VAR_DECL) {
		if (!n->u.var.is_extern) {
			int sz = n->u.var.var_type ? type_sizeof(n->u.var.var_type) : 4;
			if (sz <= 0) sz = 4;
			frame_add(fl, n->u.var.name, sz, 4);
			if (is_param) n->u.var.is_param = 1;
		}
		return;
	}
	if (n->kind == AST_BLOCK) {
		AstList *it = n->u.block.items;
		while (it) {
			collect_locals(it->node, fl, 0, param_idx);
			it = it->next;
		}
		return;
	}
	
	switch (n->kind) {
	case AST_IF:
		collect_locals(n->u.if_stmt.then_stmt, fl, 0, param_idx);
		collect_locals(n->u.if_stmt.else_stmt, fl, 0, param_idx);
		break;
	case AST_WHILE: case AST_DO_WHILE:
		collect_locals(n->u.while_stmt.body, fl, 0, param_idx);
		break;
	case AST_FOR:
		collect_locals(n->u.for_stmt.init, fl, 0, param_idx);
		collect_locals(n->u.for_stmt.body, fl, 0, param_idx);
		break;
	case AST_SWITCH:
		collect_locals(n->u.switch_stmt.body, fl, 0, param_idx);
		break;
	case AST_CASE:
		collect_locals(n->u.case_stmt.stmt, fl, 0, param_idx);
		break;
	case AST_DEFAULT:
		collect_locals(n->u.default_stmt.stmt, fl, 0, param_idx);
		break;
	case AST_LABEL_STMT:
		collect_locals(n->u.label_stmt.stmt, fl, 0, param_idx);
		break;
	default:
		break;
	}
}

static void cg_load_var(CodeGen *cg, Symbol *sym, FrameLayout *fl, int dest_reg) {
	const char *dn = temp_name(dest_reg);
	const char *tn = type_misa_name(sym->type);

	if (sym->is_global) {
		emit(cg, "lod %s, %s, %s", tn, dn, sym->asm_label);
	} else {
		FrameVar *fv = frame_find(fl, sym->name);
		int off = fv ? fv->fp_offset : sym->fp_offset;
		emit(cg, "mov ea, fp");
		emit(cg, "lde %s, %s, %d", tn, dn, off);
	}
}

static void cg_store_var(CodeGen *cg, Symbol *sym, FrameLayout *fl, int src_reg) {
	const char *sn = temp_name(src_reg);
	const char *tn = type_misa_name(sym->type);

	if (sym->is_global) {
		emit(cg, "str %s, %s, %s", tn, sym->asm_label, sn);
	} else {
		FrameVar *fv = frame_find(fl, sym->name);
		int off = fv ? fv->fp_offset : sym->fp_offset;
		emit(cg, "mov ea, fp");
		emit(cg, "ste %s, %d, %s", tn, off, sn);
	}
}

static void cg_cast(CodeGen *cg, Type *from, Type *to, int reg) {
	if (!from || !to) return;
	if (type_equals(from, to)) return;
	const char *rn = temp_name(reg);
	if (type_is_float(from) && type_is_integer(to)) {
		emit(cg, "fcti %s", rn);
	} else if (type_is_integer(from) && type_is_float(to)) {
		emit(cg, "fctf %s", rn);
	} else if (type_is_integer(from) && type_is_integer(to)) {
		
		int sz = type_sizeof(to);
		if (sz == 1) {
			if (type_is_unsigned(to)) emit(cg, "ubx %s, %s, 0, 8", rn, rn);
			else                      emit(cg, "sbx %s, %s, 0, 8", rn, rn);
		} else if (sz == 2) {
			if (type_is_unsigned(to)) emit(cg, "ubx %s, %s, 0, 16", rn, rn);
			else                      emit(cg, "sbx %s, %s, 0, 16", rn, rn);
		}
	}
}

static int cg_expr(CodeGen *cg, AstNode *n, FrameLayout *fl);

static void cg_compare(CodeGen *cg, int op, Type *lt, Type *rt, int lr, int rr) {
	const char *la = temp_name(lr), *ra = temp_name(rr);
	int is_float   = type_is_float(lt) || type_is_float(rt);
	int is_uns     = (!is_float) && (type_is_unsigned(lt) || type_is_unsigned(rt));
	const char *cond;
	switch (op) {
	case TOK_EQ_EQ:   cond = is_float ? "feqa"  : "eq";  break;
	case TOK_BANG_EQ: cond = is_float ? "fneqa" : "neq"; break;
	case TOK_LT:      cond = is_float ? "flt" : (is_uns ? "ltu"  : "lt");  break;
	case TOK_GT:      cond = is_float ? "fgt" : (is_uns ? "gteu" : "gt");  break;
	case TOK_LT_EQ:   cond = is_uns ? "lteu" : "lte"; break;
	case TOK_GT_EQ:   cond = is_uns ? "gteu" : "gte"; break;
	default:          cond = "eq"; break;
	}
	emit(cg, "cmp %s, %s, %s", cond, la, ra);
}

static int cg_lvalue_addr(CodeGen *cg, AstNode *n, FrameLayout *fl) {
	int r = cg_alloc_temp(cg);
	const char *rn = temp_name(r);

	if (!n) { emit(cg, "mov %s, 0", rn); return r; }

	switch (n->kind) {
	case AST_IDENT: {
		Symbol *sym = symtab_lookup(cg->symtab, n->u.ident.name);
		if (!sym) { emit(cg, "mov %s, 0", rn); break; }
		if (sym->is_global) {
			emit(cg, "tpa %s, %s", rn, sym->asm_label);
		} else if (sym->is_param_ptr) {
			
			FrameVar *fv = frame_find(fl, sym->name);
			int off = fv ? fv->fp_offset : sym->fp_offset;
			emit(cg, "add %s, fp, %d", rn, off);
			emit(cg, "mov ea, %s", rn);
			emit(cg, "lde u32t, %s, 0", rn); 
		} else {
			FrameVar *fv = frame_find(fl, sym->name);
			int off = fv ? fv->fp_offset : sym->fp_offset;
			emit(cg, "add %s, fp, %d", rn, off);
		}
		break;
	}
	case AST_UNARY_PRE:
		if (n->u.unary.op == TOK_STAR) {
			
			int pr = cg_expr(cg, n->u.unary.operand, fl);
			emit(cg, "mov %s, %s", rn, temp_name(pr));
			cg_free_temp(cg, pr);
		} else {
			emit(cg, "mov %s, 0", rn);
		}
		break;
	case AST_SUBSCRIPT: {
		int base_r = cg_expr(cg, n->u.subscript.base, fl);
		int idx_r  = cg_expr(cg, n->u.subscript.index, fl);
		int esz = n->type ? type_sizeof(n->type) : 4;
		if (esz > 1) emit(cg, "mul %s, %d", temp_name(idx_r), esz);
		emit(cg, "add %s, %s", temp_name(base_r), temp_name(idx_r));
		emit(cg, "mov %s, %s", rn, temp_name(base_r));
		cg_free_temp(cg, base_r);
		cg_free_temp(cg, idx_r);
		break;
	}
	case AST_MEMBER: {
		if (n->u.member.object->kind == AST_IDENT) {
			Symbol *esym = symtab_lookup(cg->symtab, n->u.member.object->u.ident.name);
			if (esym && esym->is_global && esym->is_extern && esym->asm_label) {
				char local_label[256];
				sprintf(local_label, "%s.%s", esym->asm_label, n->u.member.member_name);
				emit(cg, "tpa %s, %s", rn, local_label);
				break;
			}
		}
		int base_r = cg_lvalue_addr(cg, n->u.member.object, fl);
		Type *st = n->u.member.object->type;
		int off = 0;
		if (st) {
			TypeMember *m = st->members;
			while (m) {
				if (m->name && !strcmp(m->name, n->u.member.member_name)) {
					off = m->offset; break;
				}
				m = m->next;
			}
		}
		if (off != 0) emit(cg, "add %s, %s, %d", rn, temp_name(base_r), off);
		else           emit(cg, "mov %s, %s",     rn, temp_name(base_r));
		cg_free_temp(cg, base_r);
		break;
	}
	case AST_PTR_MEMBER: {
		
		int ptr_r = cg_expr(cg, n->u.member.object, fl);
		Type *st = n->u.member.object->type;
		int off = 0;
		if (st && st->kind == TY_POINTER && st->base) {
			TypeMember *m = st->base->members;
			while (m) {
				if (m->name && !strcmp(m->name, n->u.member.member_name)) {
					off = m->offset; break;
				}
				m = m->next;
			}
		}
		if (off != 0) emit(cg, "add %s, %s, %d", rn, temp_name(ptr_r), off);
		else           emit(cg, "mov %s, %s",     rn, temp_name(ptr_r));
		cg_free_temp(cg, ptr_r);
		break;
	}
	default:
		
		{
			int er = cg_expr(cg, n, fl);
			emit(cg, "mov %s, %s", rn, temp_name(er));
			cg_free_temp(cg, er);
		}
		break;
	}
	return r;
}

static int cg_expr(CodeGen *cg, AstNode *n, FrameLayout *fl) {
	if (!n) {
		int r = cg_alloc_temp(cg);
		emit(cg, "mov %s, zr", temp_name(r));
		return r;
	}

	int r = cg_alloc_temp(cg);
	const char *rn = temp_name(r);

	switch (n->kind) {

	case AST_INT_LIT:
	case AST_CHAR_LIT:
		emit(cg, "mov %s, %lld", rn, n->u.int_lit.value);
		break;

	case AST_FLOAT_LIT: {
		
		char buf[64];
		double v = n->u.float_lit.value;
		sprintf(buf, "%.10g", v);
		
		if (!strchr(buf, '.') && !strchr(buf, 'e') && !strchr(buf, 'n'))
			strcat(buf, ".0");
		emit(cg, "mov %s, %s", rn, buf);
		break;
	}

	case AST_STRING_LIT: {
		int id = cg_intern_string(cg, n->u.str_lit.value);
		char lbl[32];
		sprintf(lbl, "__str_%d", id);
		emit(cg, "tpa %s, %s", rn, lbl);
		break;
	}

	case AST_IDENT: {
		Symbol *sym = symtab_lookup(cg->symtab, n->u.ident.name);
		if (!sym) {
			emit(cg, "mov %s, 0", rn);
			break;
		}
		if (sym->kind == SYM_ENUM_CONST) {
			emit(cg, "mov %s, %lld", rn, sym->enum_value);
			break;
		}
		if (sym->kind == SYM_FUNC) {
			
			const char *fl2 = sym->func_label ? sym->func_label : sym->name;
			emit(cg, "tpa %s, %s", rn, fl2);
			break;
		}
		if (sym->type && sym->type->kind == TY_ARRAY) {
			
			if (sym->is_global) {
				emit(cg, "tpa %s, %s", rn, sym->asm_label);
			} else {
				FrameVar *fv = frame_find(fl, sym->name);
				int off = fv ? fv->fp_offset : sym->fp_offset;
				emit(cg, "add %s, fp, %d", rn, off);
			}
		} else {
			cg_load_var(cg, sym, fl, r);
		}
		break;
	}

	case AST_UNARY_PRE: {
		int op = n->u.unary.op;
		if (op == TOK_AMPERSAND) {
			
			int ar = cg_lvalue_addr(cg, n->u.unary.operand, fl);
			emit(cg, "mov %s, %s", rn, temp_name(ar));
			cg_free_temp(cg, ar);
			break;
		}
		if (op == TOK_STAR) {
			
			int pr = cg_expr(cg, n->u.unary.operand, fl);
			emit(cg, "mov ea, %s", temp_name(pr));
			const char *tn = n->type ? type_misa_name(n->type) : "i32t";
			emit(cg, "lde %s, %s, 0", tn, rn);
			cg_free_temp(cg, pr);
			break;
		}
		int er = cg_expr(cg, n->u.unary.operand, fl);
		const char *en = temp_name(er);
		Type *et = n->u.unary.operand->type;
		switch (op) {
		case TOK_MINUS:
			if (type_is_float(et)) emit(cg, "fneg %s, %s", rn, en);
			else                   emit(cg, "neg %s, %s", rn, en);
			break;
		case TOK_PLUS:
			emit(cg, "mov %s, %s", rn, en);
			break;
		case TOK_TILDE:
			emit(cg, "not %s, %s", rn, en);
			break;
		case TOK_BANG: {
			emit(cg, "cmp eq, %s, zr", en);
			emit(cg, "sel %s, 1, 0", rn);
			break;
		}
		case TOK_PLUS_PLUS: {
			emit(cg, "mov %s, %s", rn, en);
			if (type_is_float(et)) emit(cg, "fadd %s, 1.0", en);
			else                   emit(cg, "inc %s", en);
			
			if (n->u.unary.operand->kind == AST_IDENT) {
				Symbol *sym = symtab_lookup(cg->symtab,
				    n->u.unary.operand->u.ident.name);
				if (sym) cg_store_var(cg, sym, fl, er);
			}
			emit(cg, "mov %s, %s", rn, en);
			break;
		}
		case TOK_MINUS_MINUS: {
			emit(cg, "mov %s, %s", rn, en);
			if (type_is_float(et)) emit(cg, "fsub %s, 1.0", en);
			else                   emit(cg, "dec %s", en);
			if (n->u.unary.operand->kind == AST_IDENT) {
				Symbol *sym = symtab_lookup(cg->symtab,
				    n->u.unary.operand->u.ident.name);
				if (sym) cg_store_var(cg, sym, fl, er);
			}
			emit(cg, "mov %s, %s", rn, en);
			break;
		}
		default:
			emit(cg, "mov %s, %s", rn, en);
		}
		cg_free_temp(cg, er);
		break;
	}

	case AST_UNARY_POST: {
		int er = cg_expr(cg, n->u.unary.operand, fl);
		const char *en = temp_name(er);
		emit(cg, "mov %s, %s", rn, en); 
		Type *et = n->u.unary.operand->type;
		if (n->u.unary.op == TOK_PLUS_PLUS) {
			if (type_is_float(et)) emit(cg, "fadd %s, 1.0", en);
			else                   emit(cg, "inc %s", en);
		} else {
			if (type_is_float(et)) emit(cg, "fsub %s, 1.0", en);
			else                   emit(cg, "dec %s", en);
		}
		
		if (n->u.unary.operand->kind == AST_IDENT) {
			Symbol *sym = symtab_lookup(cg->symtab,
			    n->u.unary.operand->u.ident.name);
			if (sym) cg_store_var(cg, sym, fl, er);
		}
		cg_free_temp(cg, er);
		break;
	}

	case AST_BINARY: {
		int op  = n->u.binary.op;
		Type *lt = n->u.binary.left->type  ? n->u.binary.left->type  : type_make_int(0);
		Type *rt = n->u.binary.right->type ? n->u.binary.right->type : type_make_int(0);

		
		if (op == TOK_AMP_AMP) {
			char *end_lbl = cg_new_label(cg);
			int lr = cg_expr(cg, n->u.binary.left, fl);
			emit(cg, "mov %s, %s", rn, temp_name(lr));
			cg_free_temp(cg, lr);
			emit(cg, "cmp eq, %s, zr", rn);
			emit(cg, "jtr %s", end_lbl);
			int rr = cg_expr(cg, n->u.binary.right, fl);
			emit(cg, "cmp neq, %s, zr", temp_name(rr));
			emit(cg, "sel %s, 1, 0", rn);
			cg_free_temp(cg, rr);
			emit_label(cg, end_lbl);
			free(end_lbl);
			break;
		}
		if (op == TOK_PIPE_PIPE) {
			char *end_lbl = cg_new_label(cg);
			int lr = cg_expr(cg, n->u.binary.left, fl);
			emit(cg, "mov %s, %s", rn, temp_name(lr));
			cg_free_temp(cg, lr);
			emit(cg, "cmp neq, %s, zr", rn);
			emit(cg, "jtr %s", end_lbl);
			int rr = cg_expr(cg, n->u.binary.right, fl);
			emit(cg, "cmp neq, %s, zr", temp_name(rr));
			emit(cg, "sel %s, 1, 0", rn);
			cg_free_temp(cg, rr);
			emit_label(cg, end_lbl);
			free(end_lbl);
			break;
		}

		int lr  = cg_expr(cg, n->u.binary.left,  fl);
		int rr2 = cg_expr(cg, n->u.binary.right, fl);
		const char *la = temp_name(lr), *ra = temp_name(rr2);
		int is_float = type_is_float(lt) || type_is_float(rt);

		
		if (type_is_pointer(lt) && type_is_integer(rt) &&
		    (op == TOK_PLUS || op == TOK_MINUS)) {
			int esz = lt->base ? type_sizeof(lt->base) : 1;
			if (esz > 1) emit(cg, "mul %s, %d", ra, esz);
		}

		switch (op) {
		case TOK_PLUS:
			if (is_float) emit(cg, "fadd %s, %s, %s", rn, la, ra);
			else          emit(cg, "add %s, %s, %s",  rn, la, ra);
			break;
		case TOK_MINUS:
			if (is_float) emit(cg, "fsub %s, %s, %s", rn, la, ra);
			else          emit(cg, "sub %s, %s, %s",  rn, la, ra);
			break;
		case TOK_STAR:
			if (is_float) emit(cg, "fmul %s, %s, %s", rn, la, ra);
			else          emit(cg, "mul %s, %s, %s",  rn, la, ra);
			break;
		case TOK_SLASH:
			if (is_float) emit(cg, "fdiv %s, %s, %s", rn, la, ra);
			else          emit(cg, "div %s, %s, %s",  rn, la, ra);
			break;
		case TOK_PERCENT:
			if (is_float) emit(cg, "frem %s, %s, %s", rn, la, ra);
			else          emit(cg, "rem %s, %s, %s",  rn, la, ra);
			break;
		case TOK_AMPERSAND:
			emit(cg, "and %s, %s, %s", rn, la, ra); break;
		case TOK_PIPE:
			emit(cg, "orr %s, %s, %s", rn, la, ra); break;
		case TOK_CARET:
			emit(cg, "xor %s, %s, %s", rn, la, ra); break;
		case TOK_LSHIFT:
			emit(cg, "sll %s, %s, %s", rn, la, ra); break;
		case TOK_RSHIFT:
			if (type_is_unsigned(lt)) emit(cg, "slr %s, %s, %s", rn, la, ra);
			else                      emit(cg, "sar %s, %s, %s", rn, la, ra);
			break;
		case TOK_EQ_EQ: case TOK_BANG_EQ:
		case TOK_LT:    case TOK_GT:
		case TOK_LT_EQ: case TOK_GT_EQ:
			cg_compare(cg, op, lt, rt, lr, rr2);
			emit(cg, "sel %s, 1, 0", rn);
			break;
		default:
			emit(cg, "mov %s, %s", rn, la);
		}
		cg_free_temp(cg, lr);
		cg_free_temp(cg, rr2);
		break;
	}

	case AST_ASSIGN: {
		int val_r = cg_expr(cg, n->u.assign.rhs, fl);
		Type *lhs_type = n->u.assign.lhs->type;
		const char *tn = lhs_type ? type_misa_name(lhs_type) : "i32t";

		
		if (n->u.assign.op != TOK_ASSIGN) {
			int lhs_r = cg_expr(cg, n->u.assign.lhs, fl);
			int rhs_r = val_r;
			int res_r = cg_alloc_temp(cg);
			const char *ln = temp_name(lhs_r), *vrn = temp_name(rhs_r);
			const char *resn = temp_name(res_r);
			int is_float = lhs_type && type_is_float(lhs_type);
			switch (n->u.assign.op) {
			case TOK_PLUS_ASSIGN:
				if (is_float) emit(cg, "fadd %s, %s, %s", resn, ln, vrn);
				else          emit(cg, "add %s, %s, %s",  resn, ln, vrn);
				break;
			case TOK_MINUS_ASSIGN:
				if (is_float) emit(cg, "fsub %s, %s, %s", resn, ln, vrn);
				else          emit(cg, "sub %s, %s, %s",  resn, ln, vrn);
				break;
			case TOK_STAR_ASSIGN:
				if (is_float) emit(cg, "fmul %s, %s, %s", resn, ln, vrn);
				else          emit(cg, "mul %s, %s, %s",  resn, ln, vrn);
				break;
			case TOK_SLASH_ASSIGN:
				if (is_float) emit(cg, "fdiv %s, %s, %s", resn, ln, vrn);
				else          emit(cg, "div %s, %s, %s",  resn, ln, vrn);
				break;
			case TOK_PERCENT_ASSIGN:
				emit(cg, "rem %s, %s, %s", resn, ln, vrn); break;
			case TOK_AMP_ASSIGN:
				emit(cg, "and %s, %s, %s", resn, ln, vrn); break;
			case TOK_PIPE_ASSIGN:
				emit(cg, "orr %s, %s, %s", resn, ln, vrn); break;
			case TOK_CARET_ASSIGN:
				emit(cg, "xor %s, %s, %s", resn, ln, vrn); break;
			case TOK_LSHIFT_ASSIGN:
				emit(cg, "sll %s, %s, %s", resn, ln, vrn); break;
			case TOK_RSHIFT_ASSIGN:
				emit(cg, "sar %s, %s, %s", resn, ln, vrn); break;
			default:
				emit(cg, "mov %s, %s", resn, vrn);
			}
			cg_free_temp(cg, lhs_r);
			cg_free_temp(cg, val_r);
			val_r = res_r;
		}

		
		AstNode *lhs = n->u.assign.lhs;
		if (lhs->kind == AST_IDENT) {
			Symbol *sym = symtab_lookup(cg->symtab, lhs->u.ident.name);
			if (sym) cg_store_var(cg, sym, fl, val_r);
		} else if (lhs->kind == AST_UNARY_PRE && lhs->u.unary.op == TOK_STAR) {
			int addr_r = cg_expr(cg, lhs->u.unary.operand, fl);
			emit(cg, "mov ea, %s", temp_name(addr_r));
			emit(cg, "ste %s, 0, %s", tn, temp_name(val_r));
			cg_free_temp(cg, addr_r);
		} else if (lhs->kind == AST_SUBSCRIPT) {
			int base_r = cg_expr(cg, lhs->u.subscript.base, fl);
			int idx_r  = cg_expr(cg, lhs->u.subscript.index, fl);
			int esz = lhs->type ? type_sizeof(lhs->type) : 4;
			if (esz > 1) emit(cg, "mul %s, %d", temp_name(idx_r), esz);
			emit(cg, "add %s, %s", temp_name(base_r), temp_name(idx_r));
			emit(cg, "mov ea, %s", temp_name(base_r));
			emit(cg, "ste %s, 0, %s", tn, temp_name(val_r));
			cg_free_temp(cg, base_r);
			cg_free_temp(cg, idx_r);
		} else if (lhs->kind == AST_MEMBER) {
			int done = 0;
			if (lhs->u.member.object->kind == AST_IDENT) {
				Symbol *esym = symtab_lookup(cg->symtab, lhs->u.member.object->u.ident.name);
				if (esym && esym->is_global && esym->is_extern && esym->asm_label) {
					char local_label[256];
					sprintf(local_label, "%s.%s", esym->asm_label, lhs->u.member.member_name);
					const char *field_tn = asm_type_lookup(cg, local_label);
					if (!field_tn) field_tn = tn;
					emit(cg, "str %s, %s, %s", field_tn, local_label, temp_name(val_r));
					done = 1;
				}
			}
			if (!done) {
				int obj_r = cg_lvalue_addr(cg, lhs->u.member.object, fl);
				Type *st = lhs->u.member.object->type;
				int off = 0;
				if (st) {
					TypeMember *m = st->members;
					while (m) {
						if (m->name && !strcmp(m->name, lhs->u.member.member_name)) {
							off = m->offset; break;
						}
						m = m->next;
					}
				}
				emit(cg, "mov ea, %s", temp_name(obj_r));
				emit(cg, "ste %s, %d, %s", tn, off, temp_name(val_r));
				cg_free_temp(cg, obj_r);
			}
		} else if (lhs->kind == AST_PTR_MEMBER) {
			int obj_r = cg_expr(cg, lhs->u.member.object, fl);
			Type *st = lhs->u.member.object->type;
			int off = 0;
			if (st && st->kind == TY_POINTER && st->base) {
				TypeMember *m = st->base->members;
				while (m) {
					if (m->name && !strcmp(m->name, lhs->u.member.member_name)) {
						off = m->offset; break;
					}
					m = m->next;
				}
			}
			emit(cg, "mov ea, %s", temp_name(obj_r));
			emit(cg, "ste %s, %d, %s", tn, off, temp_name(val_r));
			cg_free_temp(cg, obj_r);
		}

		emit(cg, "mov %s, %s", rn, temp_name(val_r));
		cg_free_temp(cg, val_r);
		break;
	}

	case AST_TERNARY: {
		char *else_lbl = cg_new_label(cg);
		char *end_lbl  = cg_new_label(cg);
		int cond_r = cg_expr(cg, n->u.ternary.cond, fl);
		emit(cg, "cmp eq, %s, zr", temp_name(cond_r));
		cg_free_temp(cg, cond_r);
		emit(cg, "jtr %s", else_lbl);
		int tr = cg_expr(cg, n->u.ternary.then_expr, fl);
		emit(cg, "mov %s, %s", rn, temp_name(tr));
		cg_free_temp(cg, tr);
		emit(cg, "jmp %s", end_lbl);
		emit_label(cg, else_lbl);
		int er = cg_expr(cg, n->u.ternary.else_expr, fl);
		emit(cg, "mov %s, %s", rn, temp_name(er));
		cg_free_temp(cg, er);
		emit_label(cg, end_lbl);
		free(else_lbl); free(end_lbl);
		break;
	}

	case AST_COMMA_EXPR: {
		int lr = cg_expr(cg, n->u.binary.left,  fl);
		cg_free_temp(cg, lr);
		int rr = cg_expr(cg, n->u.binary.right, fl);
		emit(cg, "mov %s, %s", rn, temp_name(rr));
		cg_free_temp(cg, rr);
		break;
	}

	case AST_CAST: {
		int er = cg_expr(cg, n->u.cast.expr, fl);
		emit(cg, "mov %s, %s", rn, temp_name(er));
		cg_cast(cg, n->u.cast.expr->type, n->u.cast.cast_type, r);
		cg_free_temp(cg, er);
		break;
	}

	case AST_SIZEOF_TYPE:
		emit(cg, "mov %s, %d", rn, type_sizeof(n->u.sizeof_type.sizeof_type));
		break;

	case AST_SIZEOF_EXPR:
		emit(cg, "mov %s, %d", rn, n->u.sizeof_expr.sizeof_expr &&
		    n->u.sizeof_expr.sizeof_expr->type ?
		    type_sizeof(n->u.sizeof_expr.sizeof_expr->type) : 4);
		break;

	case AST_SUBSCRIPT: {
		int base_r = cg_expr(cg, n->u.subscript.base, fl);
		int idx_r  = cg_expr(cg, n->u.subscript.index, fl);
		int esz = n->type ? type_sizeof(n->type) : 4;
		if (esz > 1) emit(cg, "mul %s, %d", temp_name(idx_r), esz);
		emit(cg, "add %s, %s", temp_name(base_r), temp_name(idx_r));
		emit(cg, "mov ea, %s", temp_name(base_r));
		const char *tn = n->type ? type_misa_name(n->type) : "i32t";
		emit(cg, "lde %s, %s, 0", tn, rn);
		cg_free_temp(cg, base_r);
		cg_free_temp(cg, idx_r);
		break;
	}

	case AST_MEMBER: {
		if (n->u.member.object->kind == AST_IDENT) {
			Symbol *esym = symtab_lookup(cg->symtab, n->u.member.object->u.ident.name);
			if (esym && esym->is_global && esym->is_extern && esym->asm_label) {
				char local_label[256];
				sprintf(local_label, "%s.%s", esym->asm_label, n->u.member.member_name);
				const char *tn = asm_type_lookup(cg, local_label);
				if (!tn) tn = n->type ? type_misa_name(n->type) : "i32t";
				emit(cg, "lod %s, %s, %s", tn, rn, local_label);
				break;
			}
		}
		int obj_r = cg_lvalue_addr(cg, n->u.member.object, fl);
		Type *st  = n->u.member.object->type;
		int off   = 0;
		if (st) {
			TypeMember *m = st->members;
			while (m) {
				if (m->name && !strcmp(m->name, n->u.member.member_name)) {
					off = m->offset; break;
				}
				m = m->next;
			}
		}
		emit(cg, "mov ea, %s", temp_name(obj_r));
		const char *tn = n->type ? type_misa_name(n->type) : "i32t";
		emit(cg, "lde %s, %s, %d", tn, rn, off);
		cg_free_temp(cg, obj_r);
		break;
	}

	case AST_PTR_MEMBER: {
		int ptr_r = cg_expr(cg, n->u.member.object, fl);
		Type *st  = n->u.member.object->type;
		int off   = 0;
		if (st && st->kind == TY_POINTER && st->base) {
			TypeMember *m = st->base->members;
			while (m) {
				if (m->name && !strcmp(m->name, n->u.member.member_name)) {
					off = m->offset; break;
				}
				m = m->next;
			}
		}
		emit(cg, "mov ea, %s", temp_name(ptr_r));
		const char *tn = n->type ? type_misa_name(n->type) : "i32t";
		emit(cg, "lde %s, %s, %d", tn, rn, off);
		cg_free_temp(cg, ptr_r);
		break;
	}

	case AST_CALL: {
		
		int saved[15]; int nsaved = 0;
		int i;
		for (i = 0; i < 15; i++) {
			if (cg->temp_used[i] && i != r) {
				emit(cg, "psh %s", temp_name(i));
				saved[nsaved++] = i;
				cg->temp_used[i] = 0; 
			}
		}

		AstList *arg = n->u.call.args;
		int argc = 0;
		int arg_regs[16];
		while (arg && argc < 16) {
			AstNode *anode = arg->node;
			Type *atype = anode->type;
			int is_agg = atype && (atype->kind == TY_STRUCT || atype->kind == TY_UNION);
			if (is_agg) {
				arg_regs[argc] = cg_lvalue_addr(cg, anode, fl);
			} else {
				arg_regs[argc] = cg_expr(cg, anode, fl);
			}
			argc++;
			arg = arg->next;
		}
		
		for (i = argc - 1; i >= 0; i--) {
			emit(cg, "mov %s, %s", arg_name(i), temp_name(arg_regs[i]));
			cg_free_temp(cg, arg_regs[i]);
		}

		
		if (n->u.call.callee->kind == AST_IDENT) {
			Symbol *sym = symtab_lookup(cg->symtab, n->u.call.callee->u.ident.name);
			if (sym && sym->builtin_id != BUILTIN_NONE) {
				const BuiltinInfo *bi = builtin_lookup(sym->builtin_id);
				if (bi) {
					int j;
					for (j = 0; j < argc; j++) {
						if (bi->tpr_mask & (1 << j))
							emit(cg, "tpr %s", arg_name(j));
					}
					emit(cg, "syscall %s", bi->syscall_name);
				}
			} else if (sym && sym->kind == SYM_FUNC) {
				emit(cg, "cal %s", sym->func_label ? sym->func_label : sym->name);
			} else {
				int cr = cg_expr(cg, n->u.call.callee, fl);
				emit(cg, "tpr %s", temp_name(cr));
				emit(cg, "sub %s, @__ical+", temp_name(cr));
				fprintf(cg->out, "@__ical:\n");
				emit(cg, "cal %s", temp_name(cr));
				cg_free_temp(cg, cr);
			}
		} else {
			int cr = cg_expr(cg, n->u.call.callee, fl);
			emit(cg, "tpr %s", temp_name(cr));
			emit(cg, "sub %s, @__ical+", temp_name(cr));
			fprintf(cg->out, "@__ical:\n");
			emit(cg, "cal %s", temp_name(cr));
			cg_free_temp(cg, cr);
		}

		
		emit(cg, "mov %s, a0", rn);

		
		for (i = nsaved - 1; i >= 0; i--) {
			emit(cg, "pop %s", temp_name(saved[i]));
			cg->temp_used[saved[i]] = 1;
		}
		break;
	}

	default:
		emit(cg, "mov %s, zr", rn);
	}

	return r;
}

static void cg_stmt(CodeGen *cg, AstNode *n, FrameLayout *fl);

static void cg_stmt(CodeGen *cg, AstNode *n, FrameLayout *fl) {
	if (!n) return;
	AstList *it;

	switch (n->kind) {

	case AST_NULL_STMT:
		break;

	case AST_BLOCK:
		for (it = n->u.block.items; it; it = it->next)
			cg_stmt(cg, it->node, fl);
		break;

	case AST_VAR_DECL: {
		
		if (n->u.var.init && n->u.var.name) {
			if (n->u.var.init->kind == AST_INIT_LIST &&
			    n->u.var.var_type && n->u.var.var_type->kind == TY_ARRAY) {
				Symbol *sym = symtab_lookup(cg->symtab, n->u.var.name);
				if (sym) {
					Type *elem_t = n->u.var.var_type->base;
					if (!elem_t) elem_t = n->u.var.var_type;
					const char *elem_misa = type_misa_name(elem_t);
					int elem_size = type_sizeof(elem_t);
					if (elem_size <= 0) elem_size = 4;
					FrameVar *fv = frame_find(fl, n->u.var.name);
					int base_off = fv ? fv->fp_offset : 0;
					AstList *items = n->u.var.init->u.init_list.items;
					int i = 0;
					while (items) {
						int vr = cg_expr(cg, items->node, fl);
						int ar = cg_alloc_temp(cg);
						emit(cg, "add %s, fp, %d", temp_name(ar), base_off + i * elem_size);
						emit(cg, "mov ea, %s", temp_name(ar));
						emit(cg, "ste %s, 0, %s", elem_misa, temp_name(vr));
						cg_free_temp(cg, vr);
						cg_free_temp(cg, ar);
						items = items->next;
						i++;
					}
				}
			} else {
				int vr = cg_expr(cg, n->u.var.init, fl);
				cg_cast(cg, n->u.var.init->type, n->u.var.var_type, vr);
				Symbol *sym = symtab_lookup(cg->symtab, n->u.var.name);
				if (sym) cg_store_var(cg, sym, fl, vr);
				cg_free_temp(cg, vr);
			}
		}
		break;
	}

	case AST_EXPR_STMT: {
		int r = cg_expr(cg, n->u.expr_stmt.expr, fl);
		cg_free_temp(cg, r);
		break;
	}

	case AST_IF: {
		char *else_lbl = cg_new_label(cg);
		char *end_lbl  = cg_new_label(cg);
		int cr = cg_expr(cg, n->u.if_stmt.cond, fl);
		emit(cg, "cmp eq, %s, zr", temp_name(cr));
		cg_free_temp(cg, cr);
		emit(cg, "jtr %s", else_lbl);
		cg_stmt(cg, n->u.if_stmt.then_stmt, fl);
		if (n->u.if_stmt.else_stmt) {
			emit(cg, "jmp %s", end_lbl);
			emit_label(cg, else_lbl);
			cg_stmt(cg, n->u.if_stmt.else_stmt, fl);
		} else {
			emit_label(cg, else_lbl);
		}
		emit_label(cg, end_lbl);
		free(else_lbl); free(end_lbl);
		break;
	}

	case AST_WHILE: {
		char *loop_lbl  = cg_new_label(cg);
		char *break_lbl = cg_new_label(cg);
		char *saved_brk = cg->break_label;
		char *saved_cnt = cg->continue_label;
		cg->break_label    = break_lbl;
		cg->continue_label = loop_lbl;

		emit_label(cg, loop_lbl);
		int cr = cg_expr(cg, n->u.while_stmt.cond, fl);
		emit(cg, "cmp eq, %s, zr", temp_name(cr));
		cg_free_temp(cg, cr);
		emit(cg, "jtr %s", break_lbl);
		cg_stmt(cg, n->u.while_stmt.body, fl);
		emit(cg, "jmp %s", loop_lbl);
		emit_label(cg, break_lbl);

		cg->break_label    = saved_brk;
		cg->continue_label = saved_cnt;
		free(loop_lbl); free(break_lbl);
		break;
	}

	case AST_DO_WHILE: {
		char *loop_lbl  = cg_new_label(cg);
		char *break_lbl = cg_new_label(cg);
		char *cont_lbl  = cg_new_label(cg);
		char *saved_brk = cg->break_label;
		char *saved_cnt = cg->continue_label;
		cg->break_label    = break_lbl;
		cg->continue_label = cont_lbl;

		emit_label(cg, loop_lbl);
		cg_stmt(cg, n->u.while_stmt.body, fl);
		emit_label(cg, cont_lbl);
		int cr = cg_expr(cg, n->u.while_stmt.cond, fl);
		emit(cg, "cmp neq, %s, zr", temp_name(cr));
		cg_free_temp(cg, cr);
		emit(cg, "jtr %s", loop_lbl);
		emit_label(cg, break_lbl);

		cg->break_label    = saved_brk;
		cg->continue_label = saved_cnt;
		free(loop_lbl); free(break_lbl); free(cont_lbl);
		break;
	}

	case AST_FOR: {
		char *loop_lbl  = cg_new_label(cg);
		char *incr_lbl  = cg_new_label(cg);
		char *break_lbl = cg_new_label(cg);
		char *saved_brk = cg->break_label;
		char *saved_cnt = cg->continue_label;
		cg->break_label    = break_lbl;
		cg->continue_label = incr_lbl;

		if (n->u.for_stmt.init) cg_stmt(cg, n->u.for_stmt.init, fl);
		emit_label(cg, loop_lbl);
		if (n->u.for_stmt.cond) {
			int cr = cg_expr(cg, n->u.for_stmt.cond, fl);
			emit(cg, "cmp eq, %s, zr", temp_name(cr));
			cg_free_temp(cg, cr);
			emit(cg, "jtr %s", break_lbl);
		}
		cg_stmt(cg, n->u.for_stmt.body, fl);
		emit_label(cg, incr_lbl);
		if (n->u.for_stmt.incr) {
			int ir = cg_expr(cg, n->u.for_stmt.incr, fl);
			cg_free_temp(cg, ir);
		}
		emit(cg, "jmp %s", loop_lbl);
		emit_label(cg, break_lbl);

		cg->break_label    = saved_brk;
		cg->continue_label = saved_cnt;
		free(loop_lbl); free(incr_lbl); free(break_lbl);
		break;
	}

	case AST_SWITCH: {
		char *break_lbl  = cg_new_label(cg);
		char *default_lbl = NULL;
		char *saved_brk  = cg->break_label;
		cg->break_label  = break_lbl;

		int expr_r = cg_expr(cg, n->u.switch_stmt.expr, fl);

		emit(cg, "mov t14, %s", temp_name(expr_r));
		cg_free_temp(cg, expr_r);

		AstNode *body = n->u.switch_stmt.body;
		char **case_lbls = NULL;
		long long *case_vals = NULL;
		int num_cases = 0;

		if (body && body->kind == AST_BLOCK) {
			AstList *bl = body->u.block.items;
			while (bl) {
				if (bl->node && bl->node->kind == AST_CASE) num_cases++;
				if (bl->node && bl->node->kind == AST_DEFAULT) {
					default_lbl = cg_new_label(cg);
				}
				bl = bl->next;
			}
			case_lbls = (char **)calloc(num_cases, sizeof(char *));
			case_vals = (long long *)calloc(num_cases, sizeof(long long));
			int ci = 0;
			bl = body->u.block.items;
			while (bl) {
				if (bl->node && bl->node->kind == AST_CASE) {
					case_lbls[ci] = cg_new_label(cg);
					if (bl->node->u.case_stmt.expr &&
					    bl->node->u.case_stmt.expr->kind == AST_INT_LIT) {
						case_vals[ci] = bl->node->u.case_stmt.expr->u.int_lit.value;
					}
					ci++;
				}
				bl = bl->next;
			}
		}

		
		int i;
		for (i = 0; i < num_cases; i++) {
			emit(cg, "cmp eq, t14, %lld", case_vals[i]);
			emit(cg, "jtr %s", case_lbls[i]);
		}
		if (default_lbl) emit(cg, "jmp %s", default_lbl);
		else             emit(cg, "jmp %s", break_lbl);

		
		int ci = 0;
		if (body && body->kind == AST_BLOCK) {
			AstList *bl = body->u.block.items;
			while (bl) {
				AstNode *item = bl->node;
				if (item && item->kind == AST_CASE) {
					emit_label(cg, case_lbls[ci]);
					free(case_lbls[ci]);
					ci++;
					cg_stmt(cg, item->u.case_stmt.stmt, fl);
				} else if (item && item->kind == AST_DEFAULT) {
					if (default_lbl) {
						emit_label(cg, default_lbl);
						free(default_lbl);
						default_lbl = NULL;
					}
					cg_stmt(cg, item->u.default_stmt.stmt, fl);
				} else {
					cg_stmt(cg, item, fl);
				}
				bl = bl->next;
			}
		}
		emit_label(cg, break_lbl);

		free(case_lbls); free(case_vals);
		cg->break_label = saved_brk;
		free(break_lbl);
		break;
	}

	case AST_RETURN: {
		if (n->u.ret_stmt.expr) {
			int vr = cg_expr(cg, n->u.ret_stmt.expr, fl);
			emit(cg, "mov a0, %s", temp_name(vr));
			cg_free_temp(cg, vr);
		}
		if (fl->total > 0) emit(cg, "add sp, %d", fl->total);
		emit(cg, "ret");
		break;
	}

	case AST_BREAK:
		if (cg->break_label) emit(cg, "jmp %s", cg->break_label);
		break;

	case AST_CONTINUE:
		if (cg->continue_label) emit(cg, "jmp %s", cg->continue_label);
		break;

	case AST_GOTO: {
		char lbl[64];
		sprintf(lbl, "__user_%s", n->u.goto_stmt.label);
		emit(cg, "jmp %s", lbl);
		break;
	}

	case AST_LABEL_STMT: {
		char lbl[64];
		sprintf(lbl, "__user_%s", n->u.label_stmt.name);
		emit_label(cg, lbl);
		cg_stmt(cg, n->u.label_stmt.stmt, fl);
		break;
	}

	default:
		break;
	}
}

static void cg_register_locals(CodeGen *cg, AstNode *n, FrameLayout *fl) {
	if (!n) return;
	if (n->kind == AST_VAR_DECL) {
		if (!n->u.var.name || n->u.var.is_extern) return;
		Symbol *sym = symtab_lookup_current(cg->symtab, n->u.var.name);
		if (!sym)
			sym = symtab_define(cg->symtab, n->u.var.name,
			    SYM_VAR, n->u.var.var_type);
		sym->is_global = 0;
		FrameVar *fv = frame_find(fl, n->u.var.name);
		if (fv) sym->fp_offset = fv->fp_offset;
		return;
	}
	if (n->kind == AST_BLOCK) {
		AstList *it = n->u.block.items;
		while (it) {
			cg_register_locals(cg, it->node, fl);
			it = it->next;
		}
		return;
	}
	switch (n->kind) {
	case AST_IF:
		cg_register_locals(cg, n->u.if_stmt.then_stmt, fl);
		cg_register_locals(cg, n->u.if_stmt.else_stmt, fl);
		break;
	case AST_WHILE: case AST_DO_WHILE:
		cg_register_locals(cg, n->u.while_stmt.body, fl);
		break;
	case AST_FOR:
		cg_register_locals(cg, n->u.for_stmt.init, fl);
		cg_register_locals(cg, n->u.for_stmt.body, fl);
		break;
	case AST_SWITCH:
		cg_register_locals(cg, n->u.switch_stmt.body, fl);
		break;
	case AST_CASE:
		cg_register_locals(cg, n->u.case_stmt.stmt, fl);
		break;
	case AST_DEFAULT:
		cg_register_locals(cg, n->u.default_stmt.stmt, fl);
		break;
	case AST_LABEL_STMT:
		cg_register_locals(cg, n->u.label_stmt.stmt, fl);
		break;
	default:
		break;
	}
}

static void cg_func(CodeGen *cg, AstNode *n) {
	if (!n->u.func.name) return;

	
	FrameLayout fl;
	memset(&fl, 0, sizeof(fl));

	
	int param_idx = 0;
	AstList *pl = n->u.func.params;
	while (pl) {
		AstNode *pn = pl->node;
		if (pn->u.var.name) {
			Type *pt = pn->u.var.var_type;
			int is_agg = pt && (pt->kind == TY_STRUCT || pt->kind == TY_UNION);
			int sz = is_agg ? 4 : (pt ? type_sizeof(pt) : 4);
			if (sz <= 0) sz = 4;
			frame_add(&fl, pn->u.var.name, sz, 4);
		}
		param_idx++;
		pl = pl->next;
	}
	
	if (n->u.func.body) collect_locals(n->u.func.body, &fl, 0, &param_idx);

	symtab_push(cg->symtab);

	pl = n->u.func.params;
	int ai = 0;
	while (pl) {
		AstNode *pn = pl->node;
		if (pn->u.var.name) {
			Type *pt = pn->u.var.var_type;
			int is_agg = pt && (pt->kind == TY_STRUCT || pt->kind == TY_UNION);
			Symbol *sym = symtab_define(cg->symtab, pn->u.var.name, SYM_VAR, pt);
			sym->is_global = 0;
			sym->is_param_ptr = is_agg; 
			FrameVar *fv = frame_find(&fl, pn->u.var.name);
			if (fv) sym->fp_offset = fv->fp_offset;
		}
		ai++;
		pl = pl->next;
	}

	if (n->u.func.body) {
		cg_register_locals(cg, n->u.func.body, &fl);
	}

	fprintf(cg->out, "\n");
	{
		Symbol *fsym = symtab_lookup(cg->symtab, n->u.func.name);
		const char *flbl = (fsym && fsym->func_label) ? fsym->func_label : n->u.func.name;
		emit_label(cg, flbl);
	}
	
	if (fl.total > 0) emit(cg, "sub sp, %d", fl.total);
	
	pl = n->u.func.params;
	ai = 0;
	while (pl && ai < 16) {
		AstNode *pn = pl->node;
		if (pn->u.var.name) {
			Symbol *sym = symtab_lookup(cg->symtab, pn->u.var.name);
			if (sym) {
				FrameVar *fv = frame_find(&fl, pn->u.var.name);
				int off = fv ? fv->fp_offset : sym->fp_offset;
				int scratch = 14;
				
				const char *tn = sym->is_param_ptr ? "u32t" :
				    (pn->u.var.var_type ? type_misa_name(pn->u.var.var_type) : "i32t");
				emit(cg, "mov ea, fp");
				emit(cg, "ste %s, %d, %s", tn, off, arg_name(ai));
			}
		}
		ai++;
		pl = pl->next;
	}

	cg->frame_size = fl.total;
	AstNode *last_stmt = NULL;
	if (n->u.func.body) {
		AstList *bl = n->u.func.body->u.block.items;
		while (bl) {
			cg_stmt(cg, bl->node, &fl);
			last_stmt = bl->node;
			bl = bl->next;
		}
	}

	if (!last_stmt || last_stmt->kind != AST_RETURN) {
		if (fl.total > 0) emit(cg, "add sp, %d", fl.total);
		emit(cg, "ret");
	}

	symtab_pop(cg->symtab);
	frame_free(&fl);
}

static void cg_global_var(CodeGen *cg, AstNode *n) {
	if (!n->u.var.name || n->u.var.is_extern) return;
	Type *t = n->u.var.var_type;
	if (!t) return;

	
	char lbl[128];
	sprintf(lbl, "g__%s", n->u.var.name);

	
	Symbol *sym = symtab_lookup(cg->symtab, n->u.var.name);
	if (!sym) {
		sym = symtab_define(cg->symtab, n->u.var.name, SYM_VAR, t);
	}
	sym->is_global = 1;
	if (!sym->asm_label) sym->asm_label = strdup(lbl);

	
	int sz = type_sizeof(t);
	if (sz <= 0) sz = 4;

	if (n->u.var.init && n->u.var.init->kind == AST_INT_LIT) {
		fprintf(cg->out, "%s:\temb %s %lld\n", lbl,
		    type_misa_name(t), n->u.var.init->u.int_lit.value);
	} else if (n->u.var.init && n->u.var.init->kind == AST_FLOAT_LIT) {
		fprintf(cg->out, "%s:\temb %s %.10g\n", lbl,
		    type_misa_name(t), n->u.var.init->u.float_lit.value);
	} else if (n->u.var.init && n->u.var.init->kind == AST_CHAR_LIT) {
		fprintf(cg->out, "%s:\temb %s %lld\n", lbl,
		    type_misa_name(t), n->u.var.init->u.int_lit.value);
	} else if (n->u.var.init && n->u.var.init->kind == AST_STRING_LIT) {
		fprintf(cg->out, "%s:\temb string \"%s\"\n", lbl,
		    n->u.var.init->u.str_lit.value);
	} else if (t->kind == TY_ARRAY) {
		if (n->u.var.init && n->u.var.init->kind == AST_INIT_LIST) {
			Type *elem_t = t->base ? t->base : t;
			fprintf(cg->out, "%s:\temb %s", lbl, type_misa_name(elem_t));
			AstList *items = n->u.var.init->u.init_list.items;
			int first = 1;
			while (items) {
				AstNode *elem = items->node;
				if (!first) fprintf(cg->out, ",");
				if (elem->kind == AST_INT_LIT || elem->kind == AST_CHAR_LIT) {
					fprintf(cg->out, " %lld", elem->u.int_lit.value);
				} else if (elem->kind == AST_FLOAT_LIT) {
					fprintf(cg->out, " %.10g", elem->u.float_lit.value);
				} else if (elem->kind == AST_UNARY_PRE && elem->u.unary.op == TOK_MINUS &&
				           elem->u.unary.operand &&
				           elem->u.unary.operand->kind == AST_INT_LIT) {
					fprintf(cg->out, " %lld", -elem->u.unary.operand->u.int_lit.value);
				} else if (elem->kind == AST_UNARY_PRE && elem->u.unary.op == TOK_MINUS &&
				           elem->u.unary.operand &&
				           elem->u.unary.operand->kind == AST_FLOAT_LIT) {
					fprintf(cg->out, " %.10g", -elem->u.unary.operand->u.float_lit.value);
				} else {
					fprintf(cg->out, " 0");
				}
				first = 0;
				items = items->next;
			}
			fprintf(cg->out, "\n");
		} else {
			int count = t->array_len > 0 ? t->array_len : 1;
			Type *elem_t = t->base ? t->base : t;
			int elem_sz = type_sizeof(elem_t);
			if (elem_sz <= 0) elem_sz = 4;
			// Here (sz + 3) / 4 does ensure its ceil during the sz division
			fprintf(cg->out, "%s:\tres %s %d, 0\n", lbl,
			    type_misa_name(t->base ? t->base : t), count * ((elem_sz + 3) / 4));
		}
	} else if (t->kind == TY_STRUCT || t->kind == TY_UNION) {
		// same as above, (sz + 3) / 4 does ensure its ceil during the sz division
		fprintf(cg->out, "%s:\tres u32t %d, 0\n", lbl, (sz + 3) / 4);
	} else {
		fprintf(cg->out, "%s:\tres %s 1, 0\n", lbl, type_misa_name(t));
	}
}

void codegen_init(CodeGen *cg, FILE *out, SymTab *st) {
	memset(cg, 0, sizeof(*cg));
	cg->out    = out;
	cg->symtab = st;
}

void codegen_free(CodeGen *cg) {
	int i;
	for (i = 0; i < cg->str_count; i++) free(cg->strings[i].value);
	free(cg->strings);
	free(cg->func_end_label);
	for (i = 0; i < cg->asm_type_count; i++) {
		free(cg->asm_type_map[i].label);
		free(cg->asm_type_map[i].misa_type);
	}
	free(cg->asm_type_map);
}

void codegen_emit(CodeGen *cg, AstNode *unit) {
	if (!unit || unit->kind != AST_TRANSLATION_UNIT) return;

	int i;
	for (i = 0; i < unit->u.unit.asm_include_count; i++)
		parse_asm_types(cg, unit->u.unit.asm_includes[i]);

	AstList *it = unit->u.unit.decls;
	while (it) {
		AstNode *n = it->node;
		if (n && n->kind == AST_VAR_DECL && n->u.var.name) {
			Symbol *sym;
			sym = symtab_lookup(cg->symtab, n->u.var.name);
			if (!sym) sym = symtab_define(cg->symtab, n->u.var.name, SYM_VAR,
			    n->u.var.var_type);
			sym->is_global = 1;
			if (n->u.var.is_extern) {
				sym->is_extern = 1;
				if (!sym->asm_label) sym->asm_label = strdup(n->u.var.name);
			} else {
				char lbl[128];
				sprintf(lbl, "g__%s", n->u.var.name);
				if (!sym->asm_label) sym->asm_label = strdup(lbl);
			}
		}
		it = it->next;
	}

	
	it = unit->u.unit.decls;
	while (it) {
		AstNode *n = it->node;
		if (n && (n->kind == AST_FUNC_DEF || n->kind == AST_FUNC_DECL)) {
			if (n->u.func.name) {
				Symbol *sym = symtab_lookup(cg->symtab, n->u.func.name);
				if (!sym) {
					sym = symtab_define(cg->symtab, n->u.func.name, SYM_FUNC,
					    n->u.func.func_type);
				}
				if (!sym->func_label) {
					const char *fn = n->u.func.name;
					if (n->u.func.is_extern || fn[0] == '_') {
						sym->func_label = strdup(fn);
					} else {
						char *lbl = (char *)malloc(strlen(fn) + 2);
						sprintf(lbl, "%s_", fn);
						sym->func_label = lbl;
					}
				}
			}
		}
		it = it->next;
	}

	
	fprintf(cg->out, "_start:\n");
	{
		Symbol *msym = symtab_lookup(cg->symtab, "main");
		const char *mlbl = (msym && msym->func_label) ? msym->func_label : "main_";
		fprintf(cg->out, "\tcal %s\n", mlbl);
	}
	fprintf(cg->out, "\texit\n");

	
	it = unit->u.unit.decls;
	while (it) {
		AstNode *n = it->node;
		if (n && n->kind == AST_FUNC_DEF) {
			cg_func(cg, n);
		}
		it = it->next;
	}

	
	fprintf(cg->out, "\n");
	it = unit->u.unit.decls;
	while (it) {
		AstNode *n = it->node;
		if (n && n->kind == AST_VAR_DECL) {
			cg_global_var(cg, n);
		}
		it = it->next;
	}

	
	for (i = 0; i < cg->str_count; i++) {
		char lbl[32];
		sprintf(lbl, "__str_%d", cg->strings[i].id);
		
		fprintf(cg->out, "%s:\temb string \"", lbl);
		const char *p = cg->strings[i].value;
		while (*p) {
			if (*p == '"')       fprintf(cg->out, "\\\"");
			else if (*p == '\\') fprintf(cg->out, "\\\\");
			else if (*p == '\n') fprintf(cg->out, "\\n");
			else if (*p == '\t') fprintf(cg->out, "\\t");
			else if (*p == '\r') fprintf(cg->out, "\\r");
			else                 fputc(*p, cg->out);
			p++;
		}
		fprintf(cg->out, "\"\n");
	}

	for (i = 0; i < unit->u.unit.asm_include_count; i++) {
		const char *path = unit->u.unit.asm_includes[i];
		FILE *af = fopen(path, "r");
		if (!af) {
			fprintf(stderr, "codegen: cannot open asm include '%s'\n", path);
			cg->had_error = 1;
			continue;
		}
		fprintf(cg->out, "\n");
		char buf[4096];
		size_t n2;
		while ((n2 = fread(buf, 1, sizeof(buf), af)) > 0)
			fwrite(buf, 1, n2, cg->out);
		fclose(af);
	}
}
