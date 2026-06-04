#include <stdlib.h>
#include <string.h>
#include "type.h"

static Type *type_alloc(TypeKind kind) {
	Type *t = (Type *)calloc(1, sizeof(Type));
	t->kind = kind;
	t->size = -1;
	return t;
}

Type *type_make_void(void)              { return type_alloc(TY_VOID); }
Type *type_make_float(void)             { Type *t = type_alloc(TY_FLOAT);  t->size = 4; return t; }
Type *type_make_double(void)            { Type *t = type_alloc(TY_DOUBLE); t->size = 4; return t; }

Type *type_make_char(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_UCHAR : TY_CHAR);
	t->size = 1;
	return t;
}

Type *type_make_short(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_USHORT : TY_SHORT);
	t->size = 2;
	return t;
}

Type *type_make_int(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_UINT : TY_INT);
	t->size = 4;
	return t;
}

Type *type_make_long(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_ULONG : TY_LONG);
	t->size = 4;
	return t;
}

Type *type_make_pointer(Type *base) {
	Type *t = type_alloc(TY_POINTER);
	t->base = base;
	t->size = 4;
	return t;
}

Type *type_make_array(Type *base, int len) {
	Type *t = type_alloc(TY_ARRAY);
	t->base      = base;
	t->array_len = len;
	if (len >= 0 && base && base->size >= 0)
		t->size = base->size * len;
	return t;
}

Type *type_make_function(Type *ret, TypeParam *params, int is_variadic) {
	Type *t = type_alloc(TY_FUNCTION);
	t->base        = ret;
	t->params      = params;
	t->is_variadic = is_variadic;
	t->size        = 4; 
	return t;
}

Type *type_make_struct(const char *tag) {
	Type *t = type_alloc(TY_STRUCT);
	if (tag) t->tag = strdup(tag);
	return t;
}

Type *type_make_union(const char *tag) {
	Type *t = type_alloc(TY_UNION);
	if (tag) t->tag = strdup(tag);
	return t;
}

Type *type_make_enum(const char *tag) {
	Type *t  = type_alloc(TY_ENUM);
	if (tag) t->tag = strdup(tag);
	t->size  = 4; 
	return t;
}

Type *type_clone(const Type *src) {
	Type *t = (Type *)malloc(sizeof(Type));
	memcpy(t, src, sizeof(Type));
	if (src->tag) t->tag = strdup(src->tag);
	
	return t;
}

void type_free(Type *t) {
	if (!t) return;
	free(t->tag);
	free(t);
}

int type_is_integer(const Type *t) {
	if (!t) return 0;
	switch (t->kind) {
	case TY_CHAR: case TY_UCHAR:
	case TY_SHORT: case TY_USHORT:
	case TY_INT:  case TY_UINT:
	case TY_LONG: case TY_ULONG:
	case TY_ENUM:
		return 1;
	default: return 0;
	}
}

int type_is_unsigned(const Type *t) {
	if (!t) return 0;
	return t->kind == TY_UCHAR || t->kind == TY_USHORT ||
	       t->kind == TY_UINT  || t->kind == TY_ULONG;
}

int type_is_float(const Type *t) {
	if (!t) return 0;
	return t->kind == TY_FLOAT || t->kind == TY_DOUBLE;
}

int type_is_arithmetic(const Type *t) {
	return type_is_integer(t) || type_is_float(t);
}

int type_is_pointer(const Type *t) {
	return t && (t->kind == TY_POINTER || t->kind == TY_ARRAY);
}

int type_is_scalar(const Type *t) {
	return type_is_arithmetic(t) || type_is_pointer(t);
}

int type_is_complete(const Type *t) {
	if (!t) return 0;
	if (t->kind == TY_STRUCT || t->kind == TY_UNION) return t->is_complete;
	if (t->kind == TY_ARRAY) return t->array_len >= 0;
	return t->kind != TY_VOID;
}

int type_equals(const Type *a, const Type *b) {
	if (!a || !b) return a == b;
	if (a->kind != b->kind) return 0;
	switch (a->kind) {
	case TY_POINTER: return type_equals(a->base, b->base);
	case TY_ARRAY:
		return a->array_len == b->array_len && type_equals(a->base, b->base);
	case TY_STRUCT:
	case TY_UNION:
		return a == b || (a->tag && b->tag && !strcmp(a->tag, b->tag));
	default: return 1;
	}
}

int type_is_compatible(const Type *a, const Type *b) {
	if (type_is_arithmetic(a) && type_is_arithmetic(b)) return 1;
	if (type_equals(a, b)) return 1;
	
	if (type_is_pointer(a) && type_is_pointer(b)) {
		if (a->base && a->base->kind == TY_VOID) return 1;
		if (b->base && b->base->kind == TY_VOID) return 1;
		return type_equals(a->base, b->base);
	}
	
	if (type_is_integer(a) && type_is_pointer(b)) return 1;
	if (type_is_pointer(a) && type_is_integer(b)) return 1;
	return 0;
}

int type_sizeof(const Type *t) {
	if (!t) return 0;
	if (t->size >= 0) return t->size;
	switch (t->kind) {
	case TY_VOID:    return 0;
	case TY_CHAR: case TY_UCHAR: return 1;
	case TY_SHORT: case TY_USHORT: return 2;
	case TY_INT: case TY_UINT:
	case TY_LONG: case TY_ULONG:
	case TY_FLOAT: case TY_DOUBLE:
	case TY_POINTER: case TY_FUNCTION: case TY_ENUM: return 4;
	case TY_ARRAY:
		if (t->array_len < 0 || !t->base) return 0;
		return type_sizeof(t->base) * t->array_len;
	case TY_STRUCT: case TY_UNION: {
		TypeMember *m;
		int sz = 0, align = 1;
		for (m = t->members; m; m = m->next) {
			int msz = type_sizeof(m->type);
			int ma  = type_alignof(m->type);
			if (t->kind == TY_STRUCT) {
				
				if (ma > 0) sz = (sz + ma - 1) & ~(ma - 1);
				m->offset = sz;
				sz += msz;
			} else { 
				m->offset = 0;
				if (msz > sz) sz = msz;
			}
			if (ma > align) align = ma;
		}
		
		if (align > 0) sz = (sz + align - 1) & ~(align - 1);
		return sz;
	}
	default: return 4;
	}
}

int type_alignof(const Type *t) {
	if (!t) return 1;
	switch (t->kind) {
	case TY_CHAR: case TY_UCHAR: return 1;
	case TY_SHORT: case TY_USHORT: return 2;
	case TY_ARRAY: return t->base ? type_alignof(t->base) : 1;
	case TY_STRUCT: case TY_UNION: {
		TypeMember *m;
		int align = 1;
		for (m = t->members; m; m = m->next) {
			int ma = type_alignof(m->type);
			if (ma > align) align = ma;
		}
		return align;
	}
	default: return 4;
	}
}

Type *type_promote_integer(Type *t) {
	if (!t) return type_make_int(0);
	switch (t->kind) {
	case TY_CHAR: case TY_UCHAR:
	case TY_SHORT: case TY_USHORT:
		return type_make_int(0);
	default: return t;
	}
}

Type *type_usual_arithmetic(Type *a, Type *b) {
	if (!a || !b) return type_make_int(0);
	
	if (type_is_float(a) || type_is_float(b)) return type_make_float();
	
	a = type_promote_integer(a);
	b = type_promote_integer(b);
	
	if (type_is_unsigned(a) || type_is_unsigned(b))
		return type_make_int(1);
	return type_make_int(0);
}

const char *type_misa_name(const Type *t) {
	if (!t) return "i32t";
	switch (t->kind) {
	case TY_CHAR:            return "i8t";
	case TY_UCHAR:           return "u8t";
	case TY_SHORT:           return "i16t";
	case TY_USHORT:          return "u16t";
	case TY_INT: case TY_LONG: case TY_ENUM: return "i32t";
	case TY_UINT: case TY_ULONG: case TY_POINTER: return "u32t";
	case TY_FLOAT: case TY_DOUBLE: return "f32t";
	default: return "u32t";
	}
}
