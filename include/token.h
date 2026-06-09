#ifndef TOKEN_H
#define TOKEN_H

/*
 * Token types for C89.
 */
typedef enum {
	/* Literals */
	TOK_LIT_INT,
	TOK_LIT_FLOAT,
	TOK_LIT_CHAR,
	TOK_LIT_STRING,

	/* Identifier */
	TOK_IDENT,

	/* Keywords */
	TOK_KW_AUTO,
	TOK_KW_BREAK,
	TOK_KW_CASE,
	TOK_KW_CHAR,
	TOK_KW_CONST,
	TOK_KW_CONTINUE,
	TOK_KW_DEFAULT,
	TOK_KW_DO,
	TOK_KW_DOUBLE,
	TOK_KW_ELSE,
	TOK_KW_ENUM,
	TOK_KW_EXTERN,
	TOK_KW_FLOAT,
	TOK_KW_FOR,
	TOK_KW_GOTO,
	TOK_KW_IF,
	TOK_KW_INT,
	TOK_KW_LONG,
	TOK_KW_REGISTER,
	TOK_KW_RETURN,
	TOK_KW_SHORT,
	TOK_KW_SIGNED,
	TOK_KW_SIZEOF,
	TOK_KW_STATIC,
	TOK_KW_STRUCT,
	TOK_KW_SWITCH,
	TOK_KW_TYPEDEF,
	TOK_KW_UNION,
	TOK_KW_UNSIGNED,
	TOK_KW_VOID,
	TOK_KW_VOLATILE,
	TOK_KW_WHILE,

	/* Punctuation / operators */
	TOK_PLUS,          /* +  */
	TOK_MINUS,         /* -  */
	TOK_STAR,          /* *  */
	TOK_SLASH,         /* /  */
	TOK_PERCENT,       /* %  */
	TOK_AMPERSAND,     /* &  */
	TOK_PIPE,          /* |  */
	TOK_CARET,         /* ^  */
	TOK_TILDE,         /* ~  */
	TOK_BANG,          /* !  */
	TOK_LT,            /* <  */
	TOK_GT,            /* >  */
	TOK_ASSIGN,        /* =  */
	TOK_PLUS_ASSIGN,   /* += */
	TOK_MINUS_ASSIGN,  /* -= */
	TOK_STAR_ASSIGN,   /* *= */
	TOK_SLASH_ASSIGN,  /* /= */
	TOK_PERCENT_ASSIGN,/* %= */
	TOK_AMP_ASSIGN,    /* &= */
	TOK_PIPE_ASSIGN,   /* |= */
	TOK_CARET_ASSIGN,  /* ^= */
	TOK_LSHIFT_ASSIGN, /* <<= */
	TOK_RSHIFT_ASSIGN, /* >>= */
	TOK_LT_EQ,         /* <= */
	TOK_GT_EQ,         /* >= */
	TOK_EQ_EQ,         /* == */
	TOK_BANG_EQ,       /* != */
	TOK_AMP_AMP,       /* && */
	TOK_PIPE_PIPE,     /* || */
	TOK_LSHIFT,        /* << */
	TOK_RSHIFT,        /* >> */
	TOK_PLUS_PLUS,     /* ++ */
	TOK_MINUS_MINUS,   /* -- */
	TOK_ARROW,         /* -> */
	TOK_DOT,           /* .  */
	TOK_QUESTION,      /* ?  */
	TOK_COLON,         /* :  */
	TOK_LPAREN,        /* (  */
	TOK_RPAREN,        /* )  */
	TOK_LBRACE,        /* {  */
	TOK_RBRACE,        /* }  */
	TOK_LBRACKET,      /* [  */
	TOK_RBRACKET,      /* ]  */
	TOK_SEMICOLON,     /* ;  */
	TOK_COMMA,         /* ,  */
	TOK_ELLIPSIS,      /* ...*/
	TOK_HASH,          /* #  */

	/* Special */
	TOK_EOF,
	TOK_ERROR
} TokenType;

/*
 * A single lexed token.
 * 'text' is owned (malloc'd) and must be freed by the caller.
 */
typedef struct {
	TokenType    type;
	char        *text;        /* null-terminated source text of this token */
	int          line;
	int          col;
	union {
		long long    ival; /* TOK_LIT_INT / TOK_LIT_CHAR */
		double       fval; /* TOK_LIT_FLOAT */
	} u;
	char        *doc_brief;   /* from /// @brief */
	char        *doc_details; /* from /// @details */
	char       **doc_param_names; /* from /// @param: parameter names (owned array) */
	char       **doc_param_descs; /* from /// @param: parameter descriptions (owned array) */
	int          doc_param_count;
	char        *doc_return;  /* from /// @return */
} Token;

/*
 * Returns a static human-readable name for a token type.
 */
const char *tok_type_name(TokenType t);

#endif /* TOKEN_H */
