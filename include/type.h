#ifndef TYPE_H
#define TYPE_H

/*
 * C type system for the MISA C compiler.
 * All types are 32-bit (MISA is a 32-bit architecture).
 */

typedef enum {
	TY_VOID,
	TY_CHAR,    /* signed 8-bit  */
	TY_UCHAR,   /* unsigned 8-bit */
	TY_SHORT,   /* signed 16-bit */
	TY_USHORT,  /* unsigned 16-bit */
	TY_INT,     /* signed 32-bit */
	TY_UINT,    /* unsigned 32-bit */
	TY_LONG,    /* signed 32-bit (same as int on MISA) */
	TY_ULONG,   /* unsigned 32-bit */
	TY_FLOAT,   /* 32-bit float */
	TY_DOUBLE,  /* mapped to float on MISA */
	TY_POINTER, /* 32-bit address */
	TY_ARRAY,
	TY_STRUCT,
	TY_UNION,
	TY_ENUM,
	TY_FUNCTION,
	TY_TYPEDEF_REF /* resolved by sema */
} TypeKind;

typedef struct Type       Type;
typedef struct TypeMember TypeMember;
typedef struct TypeParam  TypeParam;

/*
 * Member of a struct or union.
 */
struct TypeMember {
	char        *name;
	Type        *type;
	int          offset;    /* byte offset within the struct/union */
	TypeMember  *next;
};

/*
 * Parameter of a function type.
 */
struct TypeParam {
	char       *name;      /* may be NULL in prototypes */
	Type       *type;
	TypeParam  *next;
};

struct Type {
	TypeKind     kind;
	int          is_const;
	int          is_volatile;

	/* TY_POINTER | TY_ARRAY: element / base type */
	Type        *base;
	int          array_len;  /* -1 = incomplete array */

	/* TY_STRUCT | TY_UNION */
	char        *tag;
	TypeMember  *members;
	int          is_complete;  /* 1 after closing brace */

	/* TY_FUNCTION */
	TypeParam   *params;
	int          is_variadic;

	/* TY_TYPEDEF_REF */
	char        *typedef_name;

	/* TY_ENUM */
	/* enum members are stored in the symbol table */

	/* Byte size (computed lazily by type_sizeof) */
	int          size;
};

/* Constructors */
Type *type_make_void(void);
Type *type_make_char(int is_unsigned);
Type *type_make_short(int is_unsigned);
Type *type_make_int(int is_unsigned);
Type *type_make_long(int is_unsigned);
Type *type_make_float(void);
Type *type_make_double(void);
Type *type_make_pointer(Type *base);
Type *type_make_array(Type *base, int len);
Type *type_make_function(Type *ret, TypeParam *params, int is_variadic);
Type *type_make_struct(const char *tag);
Type *type_make_union(const char *tag);
Type *type_make_enum(const char *tag);
Type *type_clone(const Type *t);
void  type_free(Type *t);

/* Predicates */
int type_is_integer(const Type *t);
int type_is_unsigned(const Type *t);
int type_is_float(const Type *t);
int type_is_arithmetic(const Type *t);
int type_is_pointer(const Type *t);
int type_is_scalar(const Type *t);
int type_is_complete(const Type *t);
int type_is_compatible(const Type *a, const Type *b);
int type_equals(const Type *a, const Type *b);

/* Size / alignment */
int type_sizeof(const Type *t);   /* returns byte size */
int type_alignof(const Type *t);  /* returns alignment */

/* Type promotions */
Type *type_promote_integer(Type *t);          /* integer promotion */
Type *type_usual_arithmetic(Type *a, Type *b);/* usual arithmetic conversion result */

/* MISA type names for load/store instructions */
const char *type_misa_name(const Type *t); /* e.g. "i32t", "u8t", "f32t" */

#endif /* TYPE_H */
