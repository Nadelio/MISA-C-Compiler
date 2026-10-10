#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include "type.h"
#include "target.h"

static Type *type_alloc(TypeKind kind) {
	Type *t = (Type *)calloc(1, sizeof(Type));
	t->kind = kind;
	t->size = -1;
	return t;
}

Type *type_make_void(void)              { return type_alloc(TY_VOID); }
Type *type_make_float(void)             { Type *t = type_alloc(TY_FLOAT);  t->size = MISA_FLOAT_SIZE; return t; }
Type *type_make_double(void)            { Type *t = type_alloc(TY_DOUBLE); t->size = MISA_DOUBLE_SIZE; return t; }
Type *type_make_complex(Type *real_type) {
	Type *t = type_alloc(TY_COMPLEX);
	t->base = real_type;
	t->size = MISA_COMPLEX_SIZE;
	return t;
}

Type *type_make_char(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_UCHAR : TY_CHAR);
	t->size = MISA_CHAR_SIZE;
	return t;
}

Type *type_make_short(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_USHORT : TY_SHORT);
	t->size = MISA_SHORT_SIZE;
	return t;
}

Type *type_make_int(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_UINT : TY_INT);
	t->size = MISA_INT_SIZE;
	return t;
}

Type *type_make_long(int is_unsigned) {
	Type *t = type_alloc(is_unsigned ? TY_ULONG : TY_LONG);
	t->size = MISA_LONG_SIZE;
	return t;
}

Type *type_make_pointer(Type *base) {
	Type *t = type_alloc(TY_POINTER);
	t->base = base;
	t->size = MISA_POINTER_SIZE;
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

Type *type_make_vla(Type *base, struct AstNode *size_expr) {
	Type *t = type_make_array(base, -1);
	t->vla_size = size_expr;
	return t;
}

Type *type_make_function(Type *ret, TypeParam *params, int is_variadic) {
	Type *t = type_alloc(TY_FUNCTION);
	t->base        = ret;
	t->params      = params;
	t->is_variadic = is_variadic;
	t->has_prototype = 1;
	t->size        = MISA_POINTER_SIZE;
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
	t->size  = MISA_ENUM_SIZE;
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

int type_is_complex(const Type *t) {
	return t && t->kind == TY_COMPLEX;
}

int type_is_arithmetic(const Type *t) {
	return type_is_integer(t) || type_is_float(t) || type_is_complex(t);
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
	if (t->kind == TY_ARRAY) return t->array_len >= 0 || t->vla_size;
	return t->kind != TY_VOID;
}

int type_is_variably_modified(const Type *t) {
	if (!t) return 0;
	if (t->kind == TY_ARRAY)
		return t->vla_size || type_is_variably_modified(t->base);
	if (t->kind == TY_POINTER)
		return type_is_variably_modified(t->base);
	return 0;
}

int type_equals(const Type *a, const Type *b) {
	if (!a || !b) return a == b;
	if (a->kind != b->kind) return 0;
	switch (a->kind) {
	case TY_COMPLEX: return type_equals(a->base, b->base);
	case TY_POINTER: return type_equals(a->base, b->base);
	case TY_ARRAY:
		return a->array_len == b->array_len && type_equals(a->base, b->base);
	case TY_FUNCTION: {
		TypeParam *ap = a->params;
		TypeParam *bp = b->params;
		if (!type_equals(a->base, b->base) || a->is_variadic != b->is_variadic ||
		    a->has_prototype != b->has_prototype)
			return 0;
		while (ap && bp) {
			if (!type_equals(ap->type, bp->type)) return 0;
			ap = ap->next;
			bp = bp->next;
		}
		return !ap && !bp;
	}
	case TY_STRUCT:
	case TY_UNION:
		return a == b;
	default: return 1;
	}
}

static Type *type_default_argument_promoted(Type *type) {
	if (type && type->kind == TY_FLOAT) return type_make_double();
	return type_promote_integer(type);
}

int type_declaration_compatible(const Type *a, const Type *b) {
	if (!a || !b || a->kind != b->kind) return 0;
	if (a->kind == TY_ARRAY) {
		if (a->array_len >= 0 && b->array_len >= 0 && a->array_len != b->array_len)
			return 0;
		return type_declaration_compatible(a->base, b->base);
	}
	if (a->kind == TY_POINTER || a->kind == TY_COMPLEX)
		return type_declaration_compatible(a->base, b->base);
	if (a->kind == TY_FUNCTION) {
		TypeParam *ap = a->params;
		TypeParam *bp = b->params;
		if (!type_declaration_compatible(a->base, b->base))
			return 0;
		if (a->has_prototype && b->has_prototype &&
		    a->is_variadic != b->is_variadic) return 0;
		if (a->has_prototype != b->has_prototype) {
			TypeParam *prototype = a->has_prototype ? ap : bp;
			TypeParam *old_style = a->has_prototype ? bp : ap;
			if ((a->has_prototype ? a : b)->is_variadic) return 0;
			if (!old_style) {
				while (prototype) {
					Type *promoted = type_default_argument_promoted(prototype->type);
					if (!type_declaration_compatible(promoted, prototype->type)) return 0;
					prototype = prototype->next;
				}
				return 1;
			}
			while (prototype && old_style) {
				Type *promoted = type_default_argument_promoted(old_style->type);
				if (!type_declaration_compatible(prototype->type, promoted)) return 0;
				prototype = prototype->next;
				old_style = old_style->next;
			}
			return !prototype && !old_style;
		}
		while (ap && bp) {
			if (!type_declaration_compatible(ap->type, bp->type)) return 0;
			ap = ap->next;
			bp = bp->next;
		}
		return !ap && !bp;
	}
	return type_equals(a, b);
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
	case TY_CHAR: case TY_UCHAR: return MISA_CHAR_SIZE;
	case TY_SHORT: case TY_USHORT: return MISA_SHORT_SIZE;
	case TY_INT: case TY_UINT: return MISA_INT_SIZE;
	case TY_COMPLEX: return MISA_COMPLEX_SIZE;
	case TY_LONG: case TY_ULONG: return MISA_LONG_SIZE;
	case TY_FLOAT: return MISA_FLOAT_SIZE;
	case TY_DOUBLE: return MISA_DOUBLE_SIZE;
	case TY_POINTER: case TY_FUNCTION: return MISA_POINTER_SIZE;
	case TY_ENUM: return MISA_ENUM_SIZE;
	case TY_ARRAY:
		if (t->array_len < 0 || !t->base) return 0;
		return type_sizeof(t->base) * t->array_len;
	case TY_STRUCT: case TY_UNION: {
		TypeMember *m;
		int sz = 0, align = 1;
		int bit_unit_offset = 0, bit_unit_size = 0, bit_used = 0;
		for (m = t->members; m; m = m->next) {
			int msz = type_sizeof(m->type);
			int ma  = type_alignof(m->type);
			if (m->is_bit_field) {
				int unit_bits = msz * 8;
				if (t->kind == TY_UNION) {
					m->offset = 0;
					m->bit_offset = 0;
					if (msz > sz) sz = msz;
				} else if (m->bit_width == 0) {
					bit_unit_size = bit_used = 0;
					if (ma > 0) sz = (sz + ma - 1) & ~(ma - 1);
					m->offset = sz;
					m->bit_offset = 0;
				} else {
					if (!bit_unit_size || bit_unit_size != msz ||
					    bit_used + m->bit_width > unit_bits) {
						if (ma > 0) sz = (sz + ma - 1) & ~(ma - 1);
						bit_unit_offset = sz;
						bit_unit_size = msz;
						bit_used = 0;
						sz += msz;
					}
					m->offset = bit_unit_offset;
					m->bit_offset = bit_used;
					bit_used += m->bit_width;
				}
				if (ma > align) align = ma;
				continue;
			}
			bit_unit_size = bit_used = 0;
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
	case TY_CHAR: case TY_UCHAR: return MISA_CHAR_ALIGN;
	case TY_SHORT: case TY_USHORT: return MISA_SHORT_ALIGN;
	case TY_INT: case TY_UINT: return MISA_INT_ALIGN;
	case TY_LONG: case TY_ULONG: return MISA_LONG_ALIGN;
	case TY_FLOAT: return MISA_FLOAT_ALIGN;
	case TY_DOUBLE: return MISA_DOUBLE_ALIGN;
	case TY_COMPLEX: return MISA_COMPLEX_ALIGN;
	case TY_POINTER: case TY_FUNCTION: return MISA_POINTER_ALIGN;
	case TY_ENUM: return MISA_ENUM_ALIGN;
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
	default: return MISA_LONG_ALIGN;
	}
}

Type *type_promote_integer(Type *t) {
	if (!t) return type_make_int(0);
	switch (t->kind) {
	case TY_CHAR:
	case TY_UCHAR:
		return type_make_int(0);
	case TY_SHORT:
		return type_make_int(0);
	case TY_USHORT:
		return type_make_int(1);
	case TY_ENUM:
		return t;
	default: return t;
	}
}

static int integer_rank(const Type *t) {
	if (!t) return 0;
	switch (t->kind) {
	case TY_CHAR: case TY_UCHAR: return 1;
	case TY_SHORT: case TY_USHORT: return 2;
	case TY_INT: case TY_UINT: return 3;
	case TY_LONG: case TY_ULONG: case TY_ENUM: return 4;
	default: return 0;
	}
}

static Type *integer_type_for(int rank, int is_unsigned) {
	if (rank >= 4) return type_make_long(is_unsigned);
	if (rank == 2) return type_make_short(is_unsigned);
	if (rank == 1) return type_make_char(is_unsigned);
	return type_make_int(is_unsigned);
}

Type *type_usual_arithmetic(Type *a, Type *b) {
	if (!a || !b) return type_make_int(0);
	if (type_is_complex(a) || type_is_complex(b)) {
		Type *real = (type_is_complex(a) && a->base && a->base->kind == TY_DOUBLE) ||
		    (type_is_complex(b) && b->base && b->base->kind == TY_DOUBLE) ||
		    a->kind == TY_DOUBLE || b->kind == TY_DOUBLE
		    ? type_make_double() : type_make_float();
		return type_make_complex(real);
	}
	
	if ((a && a->kind == TY_DOUBLE) || (b && b->kind == TY_DOUBLE))
		return type_make_double();
	if (type_is_float(a) || type_is_float(b)) return type_make_float();
	
	a = type_promote_integer(a);
	b = type_promote_integer(b);
	{
		int ar = integer_rank(a);
		int br = integer_rank(b);
		int au = type_is_unsigned(a);
		int bu = type_is_unsigned(b);
		if (a->kind == b->kind) return a;
		if (au == bu) return integer_type_for(ar > br ? ar : br, au);
		if (au && ar >= br) return integer_type_for(ar, 1);
		if (bu && br >= ar) return integer_type_for(br, 1);
		if (!au && type_sizeof(a) > type_sizeof(b))
			return integer_type_for(ar, 0);
		if (!bu && type_sizeof(b) > type_sizeof(a))
			return integer_type_for(br, 0);
		return integer_type_for(ar > br ? ar : br, 1);
	}
}

const char *type_misa_name(const Type *t) {
	if (!t) return "i32t";
	switch (t->kind) {
	case TY_CHAR:            return "i8t";
	case TY_UCHAR:           return "u8t";
	case TY_SHORT:           return "i16t";
	case TY_USHORT:          return "u16t";
	case TY_INT:  return "i16t";
	case TY_UINT: return "u16t";
	case TY_LONG: case TY_ENUM: return "i32t";
	case TY_ULONG: case TY_POINTER: return "u32t";
	case TY_FLOAT: case TY_DOUBLE: return "f32t";
	case TY_COMPLEX: return "f32t";
	default: return "u32t";
	}
}
