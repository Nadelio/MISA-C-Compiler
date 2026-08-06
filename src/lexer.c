#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "lexer.h"

#define MACRO_INIT_CAP 16

static int is_ident_start(char c) {
	return isalpha((unsigned char)c) || c == '_';
}

static int is_ident_body(char c) {
	return isalnum((unsigned char)c) || c == '_';
}

static char peek_ch(Lexer *l) {
	if (l->pos >= l->len) return '\0';
	return l->src[l->pos];
}

static char peek_ch2(Lexer *l) {
	if (l->pos + 1 >= l->len) return '\0';
	return l->src[l->pos + 1];
}

static char advance_ch(Lexer *l) {
	char c = l->src[l->pos++];
	if (c == '\n') { l->line++; l->col = 1; }
	else           { l->col++; }
	return c;
}

static void clear_pending_doc(Lexer *l) {
	int i;
	free(l->pending_doc_brief);   l->pending_doc_brief   = NULL;
	free(l->pending_doc_details); l->pending_doc_details = NULL;
	free(l->pending_doc_return);  l->pending_doc_return  = NULL;
	for (i = 0; i < l->pending_doc_param_count; i++) {
		free(l->pending_doc_param_names[i]);
		free(l->pending_doc_param_descs[i]);
	}
	free(l->pending_doc_param_names); l->pending_doc_param_names = NULL;
	free(l->pending_doc_param_descs); l->pending_doc_param_descs = NULL;
	l->pending_doc_param_count = 0;
	l->pending_doc_param_cap   = 0;
}

static void pending_doc_add_param(Lexer *l, const char *name, const char *desc) {
	if (l->pending_doc_param_count >= l->pending_doc_param_cap) {
		l->pending_doc_param_cap = l->pending_doc_param_cap ? l->pending_doc_param_cap * 2 : 4;
		l->pending_doc_param_names = (char **)realloc(l->pending_doc_param_names,
		    l->pending_doc_param_cap * sizeof(char *));
		l->pending_doc_param_descs = (char **)realloc(l->pending_doc_param_descs,
		    l->pending_doc_param_cap * sizeof(char *));
	}
	l->pending_doc_param_names[l->pending_doc_param_count] = strdup(name);
	l->pending_doc_param_descs[l->pending_doc_param_count] = strdup(desc);
	l->pending_doc_param_count++;
}

static void skip_whitespace_and_comments(Lexer *l) {
	int in_doc_block = 0;
	for (;;) {
		while (l->pos < l->len && isspace((unsigned char)l->src[l->pos]))
			advance_ch(l);

		if (l->pos + 1 < l->len && l->src[l->pos] == '/' && l->src[l->pos+1] == '*') {
			in_doc_block = 0;
			clear_pending_doc(l);
			advance_ch(l); advance_ch(l);
			while (l->pos + 1 < l->len) {
				if (l->src[l->pos] == '*' && l->src[l->pos+1] == '/') {
					advance_ch(l); advance_ch(l);
					break;
				}
				advance_ch(l);
			}
			continue;
		}
		if (l->pos + 1 < l->len && l->src[l->pos] == '/' && l->src[l->pos+1] == '/') {
			if (l->pos + 2 < l->len && l->src[l->pos+2] == '/') {
				if (!in_doc_block) {
					clear_pending_doc(l);
					in_doc_block = 1;
				}
				advance_ch(l); advance_ch(l); advance_ch(l);
				while (l->pos < l->len && (l->src[l->pos] == ' ' || l->src[l->pos] == '\t'))
					advance_ch(l);
				{
					int start = l->pos;
					while (l->pos < l->len && l->src[l->pos] != '\n')
						advance_ch(l);
					int len = l->pos - start;
					char *line_buf = (char *)malloc(len + 1);
					memcpy(line_buf, l->src + start, len);
					line_buf[len] = '\0';
					if (strncmp(line_buf, "@brief", 6) == 0) {
						const char *p = line_buf + 6;
						while (*p == ' ' || *p == '\t') p++;
						free(l->pending_doc_brief);
						l->pending_doc_brief = strdup(p);
					} else if (strncmp(line_buf, "@details", 8) == 0) {
						const char *p = line_buf + 8;
						while (*p == ' ' || *p == '\t') p++;
						free(l->pending_doc_details);
						l->pending_doc_details = strdup(p);
					} else if (strncmp(line_buf, "@param", 6) == 0) {
						const char *p = line_buf + 6;
						while (*p == ' ' || *p == '\t') p++;
						const char *name_start = p;
						while (*p && *p != ' ' && *p != '\t') p++;
						int name_len = (int)(p - name_start);
						if (name_len > 0) {
							char *param_name = (char *)malloc(name_len + 1);
							memcpy(param_name, name_start, name_len);
							param_name[name_len] = '\0';
							while (*p == ' ' || *p == '\t') p++;
							pending_doc_add_param(l, param_name, p);
							free(param_name);
						}
					} else if (strncmp(line_buf, "@return", 7) == 0) {
						const char *p = line_buf + 7;
						while (*p == ' ' || *p == '\t') p++;
						free(l->pending_doc_return);
						l->pending_doc_return = strdup(p);
					}
					free(line_buf);
				}
				continue;
			}
			in_doc_block = 0;
			clear_pending_doc(l);
			while (l->pos < l->len && l->src[l->pos] != '\n') advance_ch(l);
			continue;
		}
		break;
	}
}

static Token make_token(TokenType type, const char *text, int line, int col) {
	Token t;
	t.type             = type;
	t.text             = strdup(text);
	t.line             = line;
	t.col              = col;
	t.u.ival           = 0;
	t.doc_brief        = NULL;
	t.doc_details      = NULL;
	t.doc_param_names  = NULL;
	t.doc_param_descs  = NULL;
	t.doc_param_count  = 0;
	t.doc_return       = NULL;
	return t;
}

static TokenType keyword_type(const char *s) {
	switch (s[0]) {
	case 'a':
		if (!strcmp(s, "auto"))     return TOK_KW_AUTO;
		break;
	case 'b':
		if (!strcmp(s, "break"))    return TOK_KW_BREAK;
		break;
	case 'c':
		if (!strcmp(s, "case"))     return TOK_KW_CASE;
		if (!strcmp(s, "char"))     return TOK_KW_CHAR;
		if (!strcmp(s, "const"))    return TOK_KW_CONST;
		if (!strcmp(s, "continue")) return TOK_KW_CONTINUE;
		break;
	case 'd':
		if (!strcmp(s, "default"))  return TOK_KW_DEFAULT;
		if (!strcmp(s, "do"))       return TOK_KW_DO;
		if (!strcmp(s, "double"))   return TOK_KW_DOUBLE;
		break;
	case 'e':
		if (!strcmp(s, "else"))     return TOK_KW_ELSE;
		if (!strcmp(s, "enum"))     return TOK_KW_ENUM;
		if (!strcmp(s, "extern"))   return TOK_KW_EXTERN;
		break;
	case 'f':
		if (!strcmp(s, "float"))    return TOK_KW_FLOAT;
		if (!strcmp(s, "for"))      return TOK_KW_FOR;
		break;
	case 'g':
		if (!strcmp(s, "goto"))     return TOK_KW_GOTO;
		break;
	case 'i':
		if (!strcmp(s, "if"))       return TOK_KW_IF;
		if (!strcmp(s, "int"))      return TOK_KW_INT;
		break;
	case 'l':
		if (!strcmp(s, "long"))     return TOK_KW_LONG;
		break;
	case 'r':
		if (!strcmp(s, "register")) return TOK_KW_REGISTER;
		if (!strcmp(s, "return"))   return TOK_KW_RETURN;
		break;
	case 's':
		if (!strcmp(s, "short"))    return TOK_KW_SHORT;
		if (!strcmp(s, "signed"))   return TOK_KW_SIGNED;
		if (!strcmp(s, "sizeof"))   return TOK_KW_SIZEOF;
		if (!strcmp(s, "static"))   return TOK_KW_STATIC;
		if (!strcmp(s, "struct"))   return TOK_KW_STRUCT;
		if (!strcmp(s, "switch"))   return TOK_KW_SWITCH;
		break;
	case 't':
		if (!strcmp(s, "typedef"))  return TOK_KW_TYPEDEF;
		break;
	case 'u':
		if (!strcmp(s, "union"))    return TOK_KW_UNION;
		if (!strcmp(s, "unsigned")) return TOK_KW_UNSIGNED;
		break;
	case 'v':
		if (!strcmp(s, "void"))     return TOK_KW_VOID;
		if (!strcmp(s, "volatile")) return TOK_KW_VOLATILE;
		break;
	case 'w':
		if (!strcmp(s, "while"))    return TOK_KW_WHILE;
		break;
	}
	return TOK_IDENT;
}

static char unescape_char(char c) {
	switch (c) {
	case 'n':  return '\n';
	case 't':  return '\t';
	case 'r':  return '\r';
	case '\\': return '\\';
	case '\'': return '\'';
	case '"':  return '"';
	case '0':  return '\0';
	case 'a':  return '\a';
	case 'b':  return '\b';
	case 'f':  return '\f';
	case 'v':  return '\v';
	default:   return c;
	}
}

static Token lex_string(Lexer *l, int start_line, int start_col) {
	char buf[4096];
	int  i = 0;
	advance_ch(l); 
	while (l->pos < l->len && l->src[l->pos] != '"') {
		char c = advance_ch(l);
		if (c == '\\' && l->pos < l->len) {
			c = unescape_char(advance_ch(l));
		}
		if (i < (int)(sizeof(buf) - 1)) buf[i++] = c;
	}
	buf[i] = '\0';
	if (l->pos < l->len) advance_ch(l); 
	Token t = make_token(TOK_LIT_STRING, buf, start_line, start_col);
	return t;
}

static Token lex_char_literal(Lexer *l, int start_line, int start_col) {
	advance_ch(l); 
	char c = advance_ch(l);
	if (c == '\\' && l->pos < l->len) c = unescape_char(advance_ch(l));
	if (l->pos < l->len && l->src[l->pos] == '\'') advance_ch(l);
	char buf[4]; buf[0] = c; buf[1] = '\0';
	Token t = make_token(TOK_LIT_CHAR, buf, start_line, start_col);
	t.u.ival = (unsigned char)c;
	return t;
}

static Token lex_number(Lexer *l, int start_line, int start_col) {
	char   buf[64];
	int    i = 0;
	int    is_float = 0;
	int    base = 10;

	if (peek_ch(l) == '0' && (peek_ch2(l) == 'x' || peek_ch2(l) == 'X')) {
		buf[i++] = advance_ch(l);
		buf[i++] = advance_ch(l);
		base = 16;
		while (l->pos < l->len && isxdigit((unsigned char)peek_ch(l)))
			buf[i++] = advance_ch(l);
	} else if (peek_ch(l) == '0' && (peek_ch2(l) == 'b' || peek_ch2(l) == 'B')) {
		advance_ch(l); advance_ch(l); 
		base = 2;
		while (l->pos < l->len && (peek_ch(l) == '0' || peek_ch(l) == '1'))
			buf[i++] = advance_ch(l);
	} else {
		while (l->pos < l->len && isdigit((unsigned char)peek_ch(l)))
			buf[i++] = advance_ch(l);
		if (l->pos < l->len && peek_ch(l) == '.' &&
		    l->pos+1 < l->len && isdigit((unsigned char)l->src[l->pos+1])) {
			is_float = 1;
			buf[i++] = advance_ch(l);
			while (l->pos < l->len && isdigit((unsigned char)peek_ch(l)))
				buf[i++] = advance_ch(l);
		}
	}
	
	while (l->pos < l->len && (peek_ch(l) == 'L' || peek_ch(l) == 'l' ||
	       peek_ch(l) == 'U' || peek_ch(l) == 'u' || peek_ch(l) == 'f' || peek_ch(l) == 'F')) {
		char suf = advance_ch(l);
		if (suf == 'f' || suf == 'F') is_float = 1;
	}
	buf[i] = '\0';

	Token t = make_token(is_float ? TOK_LIT_FLOAT : TOK_LIT_INT, buf, start_line, start_col);
	if (is_float) {
		t.u.fval = atof(buf);
	} else {
		char *end;
		t.u.ival = (long long)strtoull(buf, &end, base);
	}
	return t;
}

static struct MacroDef *lookup_macro_def(Lexer *l, const char *name) {
	int i;
	for (i = 0; i < l->macro_count; i++)
		if (!strcmp(l->macros[i].name, name)) return &l->macros[i];
	return NULL;
}

static const char *lookup_macro(Lexer *l, const char *name) {
	struct MacroDef *m = lookup_macro_def(l, name);
	return m ? m->body : NULL;
}

static void push_expansion(Lexer *l, char *heap_body, int *expanding_flag) {
	IncludeFrame *fr;
	if (l->include_depth >= l->include_cap) {
		l->include_cap = l->include_cap ? l->include_cap * 2 : 8;
		l->include_stack = (IncludeFrame *)realloc(l->include_stack,
		    l->include_cap * sizeof(IncludeFrame));
	}
	fr = &l->include_stack[l->include_depth++];
	fr->src                  = l->src;
	fr->owned_buf            = l->owned_buf;
	fr->pos                  = l->pos;
	fr->len                  = l->len;
	fr->line                 = l->line;
	fr->col                  = l->col;
	fr->filename             = l->filename;
	fr->filename_owned       = l->filename_owned;
	fr->macro_expanding_flag = expanding_flag;
	l->src            = heap_body;
	l->owned_buf      = heap_body;
	l->pos            = 0;
	l->len            = (int)strlen(heap_body);
	l->filename_owned = 0;
}

static char *substitute_params(const char *body, char **params, char **args, int nparams) {
	int   cap = 1024, ri = 0, bi = 0;
	int   blen = (int)strlen(body);
	char *out  = (char *)malloc(cap);
#define GROW(n) do { if (ri + (n) >= cap) { cap = cap * 2 + (n); out = (char *)realloc(out, cap); } } while (0)
	while (bi < blen) {
		char c = body[bi];
		if (c == '#' && bi + 1 < blen && body[bi + 1] == '#') {
			while (ri > 0 && (out[ri-1] == ' ' || out[ri-1] == '\t')) ri--;
			bi += 2;
			while (bi < blen && (body[bi] == ' ' || body[bi] == '\t')) bi++;
		} else if (c == '#') {
			int saved = bi++;
			while (bi < blen && (body[bi] == ' ' || body[bi] == '\t')) bi++;
			if (bi < blen && (isalpha((unsigned char)body[bi]) || body[bi] == '_')) {
				char pn[64]; int pi = 0, k, found = 0;
				while (bi < blen && (isalnum((unsigned char)body[bi]) || body[bi] == '_') && pi < 63)
					pn[pi++] = body[bi++];
				pn[pi] = '\0';
				for (k = 0; k < nparams && !found; k++) {
					if (!strcmp(pn, params[k])) {
						const char *a = args[k]; int alen, j;
						while (*a == ' ' || *a == '\t') a++;
						alen = (int)strlen(a);
						while (alen > 0 && (a[alen-1] == ' ' || a[alen-1] == '\t')) alen--;
						GROW(alen * 2 + 3);
						out[ri++] = '"';
						for (j = 0; j < alen; j++) {
							if (a[j] == '"' || a[j] == '\\') out[ri++] = '\\';
							out[ri++] = a[j];
						}
						out[ri++] = '"';
						found = 1;
					}
				}
				if (!found) { int len = bi - saved; GROW(len); memcpy(out + ri, body + saved, len); ri += len; }
			} else { GROW(1); out[ri++] = '#'; }
		} else if (isalpha((unsigned char)c) || c == '_') {
			char word[64]; int wi = 0, k, found = 0;
			while (bi < blen && (isalnum((unsigned char)body[bi]) || body[bi] == '_') && wi < 63)
				word[wi++] = body[bi++];
			word[wi] = '\0';
			for (k = 0; k < nparams && !found; k++) {
				if (!strcmp(word, params[k])) {
					int alen = (int)strlen(args[k]);
					GROW(alen); memcpy(out + ri, args[k], alen); ri += alen; found = 1;
				}
			}
			if (!found) { GROW(wi); memcpy(out + ri, word, wi); ri += wi; }
		} else { GROW(1); out[ri++] = body[bi++]; }
	}
#undef GROW
	out[ri] = '\0';
	return out;
}

static int collect_macro_args(Lexer *l, char **args, int max_args) {
	int  nargs = 0, paren = 0, bi = 0;
	char buf[1024];
	while (l->pos < l->len) {
		char c = l->src[l->pos];
		if (c == '(' || c == '[' || c == '{') {
			paren++;
			if (bi < 1023) buf[bi++] = c;
			advance_ch(l);
		} else if ((c == ')' || c == ']' || c == '}') && paren > 0) {
			paren--;
			if (bi < 1023) buf[bi++] = c;
			advance_ch(l);
		} else if (c == ')') {
			advance_ch(l);
			buf[bi] = '\0';
			if (nargs > 0 || bi > 0) {
				char *s = buf; int e;
				while (*s == ' ' || *s == '\t') s++;
				e = (int)strlen(s);
				while (e > 0 && (s[e-1] == ' ' || s[e-1] == '\t')) e--;
				s[e] = '\0';
				if (nargs < max_args) args[nargs++] = strdup(s);
			}
			break;
		} else if (c == ',' && paren == 0) {
			advance_ch(l);
			buf[bi] = '\0';
			{ char *s = buf; int e;
				while (*s == ' ' || *s == '\t') s++;
				e = (int)strlen(s);
				while (e > 0 && (s[e-1] == ' ' || s[e-1] == '\t')) e--;
				s[e] = '\0';
				if (nargs < max_args) args[nargs++] = strdup(s);
			}
			bi = 0;
		} else {
			if (bi < 1023) buf[bi++] = c;
			advance_ch(l);
		}
	}
	return nargs;
}

typedef struct { const char *s; int pos; Lexer *lx; } PPExpr;
static long long pp_ternary(PPExpr *e);
static void pp_skip(PPExpr *e) { while (e->s[e->pos]==' '||e->s[e->pos]=='\t') e->pos++; }
static long long pp_primary(PPExpr *e) {
	char c; pp_skip(e); c = e->s[e->pos];
	if (c=='(') { e->pos++; long long v=pp_ternary(e); pp_skip(e); if(e->s[e->pos]==')')e->pos++; return v; }
	if (c=='!') { e->pos++; return !pp_primary(e); }
	if (c=='~') { e->pos++; return ~pp_primary(e); }
	if (c=='-') { e->pos++; return -pp_primary(e); }
	if (c=='+') { e->pos++; return  pp_primary(e); }
	if (isdigit((unsigned char)c)) {
		char *end; long long v = (long long)strtoull(e->s+e->pos, &end, 0);
		e->pos = (int)(end - e->s);
		while (isalpha((unsigned char)e->s[e->pos])) e->pos++;
		return v;
	}
	if (isalpha((unsigned char)c) || c=='_') {
		char nm[64]; int ni = 0;
		while ((isalnum((unsigned char)e->s[e->pos])||e->s[e->pos]=='_') && ni<63) nm[ni++]=e->s[e->pos++];
		nm[ni] = '\0';
		if (!strcmp(nm, "defined")) {
			int hp; char mn[64]; int mi = 0;
			pp_skip(e); hp = (e->s[e->pos]=='('); if (hp) e->pos++;
			pp_skip(e);
			while ((isalnum((unsigned char)e->s[e->pos])||e->s[e->pos]=='_') && mi<63) mn[mi++]=e->s[e->pos++];
			mn[mi] = '\0'; pp_skip(e); if (hp && e->s[e->pos]==')') e->pos++;
			return lookup_macro(e->lx, mn) ? 1 : 0;
		}
		{ const char *body = lookup_macro(e->lx, nm);
			if (body) { PPExpr sub; sub.s=body; sub.pos=0; sub.lx=e->lx; return pp_ternary(&sub); } }
		return 0;
	}
	return 0;
}
static long long pp_mul(PPExpr *e) {
	long long v = pp_primary(e);
	for (;;) { char c; pp_skip(e); c = e->s[e->pos];
		if (c=='*') { e->pos++; v *= pp_primary(e); }
		else if (c=='/') { long long r; e->pos++; r=pp_primary(e); v=r?v/r:0; }
		else if (c=='%') { long long r; e->pos++; r=pp_primary(e); v=r?v%r:0; }
		else break; }
	return v;
}
static long long pp_add(PPExpr *e) {
	long long v = pp_mul(e);
	for (;;) { char c; pp_skip(e); c = e->s[e->pos];
		if (c=='+') { e->pos++; v += pp_mul(e); }
		else if (c=='-') { e->pos++; v -= pp_mul(e); }
		else break; }
	return v;
}
static long long pp_shift(PPExpr *e) {
	long long v = pp_add(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='<'&&e->s[e->pos+1]=='<') { e->pos+=2; v<<=pp_add(e); }
		else if (e->s[e->pos]=='>'&&e->s[e->pos+1]=='>') { e->pos+=2; v>>=pp_add(e); }
		else break; }
	return v;
}
static long long pp_rel(PPExpr *e) {
	long long v = pp_shift(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='<'&&e->s[e->pos+1]=='=') { e->pos+=2; v=v<=pp_shift(e); }
		else if (e->s[e->pos]=='>'&&e->s[e->pos+1]=='=') { e->pos+=2; v=v>=pp_shift(e); }
		else if (e->s[e->pos]=='<'&&e->s[e->pos+1]!='<') { e->pos++;  v=v<pp_shift(e); }
		else if (e->s[e->pos]=='>'&&e->s[e->pos+1]!='>') { e->pos++;  v=v>pp_shift(e); }
		else break; }
	return v;
}
static long long pp_eq(PPExpr *e) {
	long long v = pp_rel(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='='&&e->s[e->pos+1]=='=') { e->pos+=2; v=v==pp_rel(e); }
		else if (e->s[e->pos]=='!'&&e->s[e->pos+1]=='=') { e->pos+=2; v=v!=pp_rel(e); }
		else break; }
	return v;
}
static long long pp_band(PPExpr *e) {
	long long v = pp_eq(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='&'&&e->s[e->pos+1]!='&') { e->pos++; v&=pp_eq(e); }
		else break; }
	return v;
}
static long long pp_xor(PPExpr *e) {
	long long v = pp_band(e);
	for (;;) { pp_skip(e); if (e->s[e->pos]=='^') { e->pos++; v^=pp_band(e); } else break; }
	return v;
}
static long long pp_bor(PPExpr *e) {
	long long v = pp_xor(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='|'&&e->s[e->pos+1]!='|') { e->pos++; v|=pp_xor(e); }
		else break; }
	return v;
}
static long long pp_and(PPExpr *e) {
	long long v = pp_bor(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='&'&&e->s[e->pos+1]=='&') { e->pos+=2; v=v&&pp_bor(e); }
		else break; }
	return v;
}
static long long pp_or(PPExpr *e) {
	long long v = pp_and(e);
	for (;;) { pp_skip(e);
		if (e->s[e->pos]=='|'&&e->s[e->pos+1]=='|') { e->pos+=2; v=v||pp_and(e); }
		else break; }
	return v;
}
static long long pp_ternary(PPExpr *e) {
	long long v = pp_or(e), t, f; pp_skip(e);
	if (e->s[e->pos]=='?') {
		e->pos++; t=pp_ternary(e); pp_skip(e);
		if (e->s[e->pos]==':') e->pos++;
		f=pp_ternary(e); return v?t:f;
	}
	return v;
}
static long long eval_pp_expr(Lexer *l, const char *expr) {
	PPExpr e; e.s=expr; e.pos=0; e.lx=l; return pp_ternary(&e);
}

static int skip_cond_block(Lexer *l, int stop_at_else) {
	int depth = 1;
	while (l->pos < l->len) {
		if (l->col != 1 || l->src[l->pos] != '#') { advance_ch(l); continue; }
		advance_ch(l);
		while (l->pos < l->len && (l->src[l->pos]==' '||l->src[l->pos]=='\t')) advance_ch(l);
		{ char dn[16]; int di = 0;
			while (l->pos < l->len && isalpha((unsigned char)l->src[l->pos]) && di < 15)
				dn[di++] = advance_ch(l);
			dn[di] = '\0';
			if (!strcmp(dn,"if")||!strcmp(dn,"ifdef")||!strcmp(dn,"ifndef")) {
				depth++;
			} else if (!strcmp(dn,"endif")) {
				depth--;
				while (l->pos < l->len && l->src[l->pos]!='\n') advance_ch(l);
				if (depth == 0) return 2;
				continue;
			} else if (depth==1 && stop_at_else && !strcmp(dn,"else")) {
				while (l->pos < l->len && l->src[l->pos]!='\n') advance_ch(l);
				return 1;
			} else if (depth==1 && stop_at_else && !strcmp(dn,"elif")) {
				char expr[256]; int ei = 0;
				while (l->pos < l->len && (l->src[l->pos]==' '||l->src[l->pos]=='\t')) advance_ch(l);
				while (l->pos < l->len && l->src[l->pos]!='\n' && ei < 255) expr[ei++] = advance_ch(l);
				expr[ei] = '\0';
				if (eval_pp_expr(l, expr)) return 1;
				continue;
			}
		}
		while (l->pos < l->len && l->src[l->pos]!='\n') advance_ch(l);
	}
	return 2;
}

static void handle_directive(Lexer *l) {
	char name[64];
	int  ni = 0;

	while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
	while (l->pos < l->len && isalpha((unsigned char)l->src[l->pos]) && ni < 63)
		name[ni++] = l->src[l->pos++];
	name[ni] = '\0';

	if (!strcmp(name, "define")) {
		char mname[64]; int mi = 0;
		int is_func = 0;
		char *fparams[64];
		int nfp = 0;
		char body[1024]; int bi = 0;
		int k;
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		while (l->pos < l->len && is_ident_body(l->src[l->pos]) && mi < 63)
			mname[mi++] = l->src[l->pos++];
		mname[mi] = '\0';
		if (l->pos < l->len && l->src[l->pos] == '(') {
			is_func = 1; l->pos++;
			while (l->pos < l->len && l->src[l->pos] != ')' && l->src[l->pos] != '\n') {
				char pn[64]; int pi = 0;
				while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
				if (l->pos < l->len && l->src[l->pos] == ')') break;
				if (l->pos+2 < l->len && l->src[l->pos]=='.'&&l->src[l->pos+1]=='.'&&l->src[l->pos+2]=='.') {
					if (nfp < 64) fparams[nfp++] = strdup("..."); l->pos += 3; break;
				}
				while (l->pos < l->len && is_ident_body(l->src[l->pos]) && pi < 63)
					pn[pi++] = l->src[l->pos++];
				pn[pi] = '\0';
				if (pi > 0 && nfp < 64) fparams[nfp++] = strdup(pn);
				while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
				if (l->pos < l->len && l->src[l->pos] == ',') l->pos++;
			}
			if (l->pos < l->len && l->src[l->pos] == ')') l->pos++;
		}
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		while (l->pos < l->len && l->src[l->pos] != '\n' && bi < 1023)
			body[bi++] = l->src[l->pos++];
		body[bi] = '\0';
		while (bi > 0 && body[bi-1] == ' ') body[--bi] = '\0';
		if (l->macro_count >= l->macro_cap) {
			l->macro_cap = l->macro_cap ? l->macro_cap * 2 : MACRO_INIT_CAP;
			l->macros = (struct MacroDef *)realloc(l->macros,
			    l->macro_cap * sizeof(*l->macros));
		}
		{ struct MacroDef *m = &l->macros[l->macro_count++];
			m->name             = strdup(mname);
			m->body             = strdup(body);
			m->is_function_like = is_func;
			m->param_count      = nfp;
			m->expanding        = 0;
			if (is_func && nfp > 0) {
				m->params = (char **)malloc(nfp * sizeof(char *));
				for (k = 0; k < nfp; k++) m->params[k] = fparams[k];
			} else {
				m->params = NULL;
				for (k = 0; k < nfp; k++) free(fparams[k]);
			}
		}
	} else if (!strcmp(name, "include")) {
		
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		char delim_open = l->src[l->pos];
		char delim_close = (delim_open == '"') ? '"' : '>';
		if (l->pos < l->len && (delim_open == '"' || delim_open == '<')) {
			l->pos++;
			char path[512]; int pi = 0;
			while (l->pos < l->len && l->src[l->pos] != delim_close
			    && l->src[l->pos] != '\n' && pi < 511)
				path[pi++] = l->src[l->pos++];
			path[pi] = '\0';
			if (l->pos < l->len && l->src[l->pos] == delim_close) {
				l->pos++;
			} else {
				lexer_error(l, "missing closing delimiter in #include");
				return;
			}

			int plen = pi;
			if (plen >= 4 && !strcmp(path + plen - 4, ".asm")) {
				
				char resolved[512];
				FILE *probe = fopen(path, "r");
				if (!probe && l->filename) {
					
					const char *last_sep = NULL;
					const char *p2 = l->filename;
					while (*p2) {
						if (*p2 == '/' || *p2 == '\\') last_sep = p2;
						p2++;
					}
					if (last_sep) {
						int dir_len = (int)(last_sep - l->filename) + 1;
						if (dir_len + pi < 511) {
							memcpy(resolved, l->filename, dir_len);
							memcpy(resolved + dir_len, path, pi + 1);
							probe = fopen(resolved, "r");
							if (probe) { fclose(probe); strcpy(path, resolved); }
						}
					}
				} else {
					fclose(probe);
				}
				
				if (l->asm_include_count >= l->asm_include_cap) {
					l->asm_include_cap = l->asm_include_cap ? l->asm_include_cap * 2 : 4;
					l->asm_includes = (char **)realloc(l->asm_includes,
					    l->asm_include_cap * sizeof(char *));
				}
				l->asm_includes[l->asm_include_count++] = strdup(path);
			} else {
				
				char resolved[512];
				strncpy(resolved, path, 511); resolved[511] = '\0';
				FILE *probe = fopen(resolved, "r");
				if (!probe && l->filename) {
					const char *last_sep = NULL;
					const char *p2 = l->filename;
					while (*p2) {
						if (*p2 == '/' || *p2 == '\\') last_sep = p2;
						p2++;
					}
					if (last_sep) {
						int dir_len = (int)(last_sep - l->filename) + 1;
						if (dir_len + pi < 511) {
							memcpy(resolved, l->filename, dir_len);
							memcpy(resolved + dir_len, path, pi + 1);
							probe = fopen(resolved, "r");
						}
					}
				}
				if (!probe && delim_open == '<') {
					const char *search[3];
					int nsearch = 0;
					if (l->sys_include_dir)
						search[nsearch++] = l->sys_include_dir;
#ifdef _WIN32
					search[nsearch++] = "C:/MinGW/include/";
#else
					search[nsearch++] = "/usr/include/";
#endif
					search[nsearch] = NULL;
					int di;
					for (di = 0; di < nsearch && !probe; di++) {
						int slen = (int)strlen(search[di]);
						if (slen + pi < 511) {
							memcpy(resolved, search[di], slen);
							memcpy(resolved + slen, path, pi + 1);
							probe = fopen(resolved, "r");
						}
					}
				}
				if (!probe) {
					fprintf(stderr, "%s:%d: warning: cannot open include '%s'\n",
					    l->filename, l->line, path);
				} else {
					fclose(probe);
					
					int already = 0;
					int si;
					for (si = 0; si < l->seen_count; si++) {
						if (!strcmp(l->seen_includes[si], resolved)) { already = 1; break; }
					}
					if (!already) {
						if (l->seen_count >= l->seen_cap) {
							l->seen_cap = l->seen_cap ? l->seen_cap * 2 : 8;
							l->seen_includes = (char **)realloc(l->seen_includes,
							    l->seen_cap * sizeof(char *));
						}
						l->seen_includes[l->seen_count++] = strdup(resolved);
						
						FILE *f2 = fopen(resolved, "rb");
						fseek(f2, 0, SEEK_END);
						long fsz = ftell(f2);
						rewind(f2);
						char *fbuf = (char *)malloc(fsz + 1);
						fread(fbuf, 1, fsz, f2);
						fbuf[fsz] = '\0';
						fclose(f2);
						
						if (l->include_depth >= l->include_cap) {
							l->include_cap = l->include_cap ? l->include_cap * 2 : 8;
							l->include_stack = (IncludeFrame *)realloc(l->include_stack,
							    l->include_cap * sizeof(IncludeFrame));
						}
						IncludeFrame *fr = &l->include_stack[l->include_depth++];
						fr->src            = l->src;
						fr->owned_buf      = l->owned_buf;
						fr->pos            = l->pos;
						fr->len            = l->len;
						fr->line           = l->line;
						fr->col            = l->col;
						fr->filename       = l->filename;
						fr->filename_owned       = l->filename_owned;
						fr->macro_expanding_flag = NULL;
						
						l->src            = fbuf;
						l->owned_buf      = fbuf;
						l->pos            = 0;
						l->len            = (int)fsz;
						l->line           = 1;
						l->col            = 1;
						l->filename       = strdup(resolved);
						l->filename_owned = 1;
						return; 
					}
				}
			}
		}
	} else if (!strcmp(name, "undef")) {
		char mname[64]; int mi = 0, k;
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		while (l->pos < l->len && is_ident_body(l->src[l->pos]) && mi < 63)
			mname[mi++] = l->src[l->pos++];
		mname[mi] = '\0';
		for (k = 0; k < l->macro_count; k++) {
			if (!strcmp(l->macros[k].name, mname)) {
				int j;
				free(l->macros[k].name); free(l->macros[k].body);
				for (j = 0; j < l->macros[k].param_count; j++) free(l->macros[k].params[j]);
				free(l->macros[k].params);
				l->macros[k] = l->macros[--l->macro_count];
				break;
			}
		}
	} else if (!strcmp(name, "ifdef") || !strcmp(name, "ifndef")) {
		int want_defined = !strcmp(name, "ifdef");
		char mname[64]; int mi = 0;
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		while (l->pos < l->len && is_ident_body(l->src[l->pos]) && mi < 63)
			mname[mi++] = l->src[l->pos++];
		mname[mi] = '\0';
		while (l->pos < l->len && l->src[l->pos] != '\n') l->pos++;
		{ int defined = (lookup_macro(l, mname) != NULL);
			int taken   = (defined == want_defined);
			if (l->cond_depth < 63) l->cond_depth++;
			if (taken) {
				l->cond_stack[l->cond_depth] = 1;
				l->cond_done[l->cond_depth]  = 1;
			} else {
				int r = skip_cond_block(l, 1);
				if (r == 1) {
					l->cond_stack[l->cond_depth] = 1;
					l->cond_done[l->cond_depth]  = 1;
				} else {
					if (l->cond_depth > 0) l->cond_depth--;
				}
			}
		}
		return;
	} else if (!strcmp(name, "if")) {
		char expr[256]; int ei = 0;
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		while (l->pos < l->len && l->src[l->pos] != '\n' && ei < 255)
			expr[ei++] = l->src[l->pos++];
		expr[ei] = '\0';
		{ long long val = eval_pp_expr(l, expr);
			if (l->cond_depth < 63) l->cond_depth++;
			if (val) {
				l->cond_stack[l->cond_depth] = 1;
				l->cond_done[l->cond_depth]  = 1;
			} else {
				int r = skip_cond_block(l, 1);
				if (r == 1) {
					l->cond_stack[l->cond_depth] = 1;
					l->cond_done[l->cond_depth]  = 1;
				} else {
					if (l->cond_depth > 0) l->cond_depth--;
				}
			}
		}
		return;
	} else if (!strcmp(name, "elif")) {
		while (l->pos < l->len && l->src[l->pos] != '\n') l->pos++;
		if (l->cond_depth > 0 && l->cond_stack[l->cond_depth]) {
			skip_cond_block(l, 0);
			l->cond_depth--;
		}
		return;
	} else if (!strcmp(name, "else")) {
		while (l->pos < l->len && l->src[l->pos] != '\n') l->pos++;
		if (l->cond_depth > 0 && l->cond_stack[l->cond_depth]) {
			skip_cond_block(l, 0);
			l->cond_depth--;
		}
		return;
	} else if (!strcmp(name, "endif")) {
		if (l->cond_depth > 0) l->cond_depth--;
	}

	while (l->pos < l->len && l->src[l->pos] != '\n') l->pos++;
}

void lexer_init(Lexer *l, const char *src, int len, const char *filename) {
	memset(l, 0, sizeof(*l));
	l->src      = src;
	l->len      = len;
	l->filename = filename;
	l->line     = 1;
	l->col      = 1;
}

void lexer_free(Lexer *l) {
	int i;
	for (i = 0; i < l->macro_count; i++) {
		int j;
		free(l->macros[i].name);
		free(l->macros[i].body);
		for (j = 0; j < l->macros[i].param_count; j++) free(l->macros[i].params[j]);
		free(l->macros[i].params);
	}
	free(l->macros);
	for (i = 0; i < l->asm_include_count; i++) free(l->asm_includes[i]);
	free(l->asm_includes);
	free(l->owned_buf);
	if (l->filename_owned) free((char *)l->filename);
	for (i = 0; i < l->include_depth; i++) {
		free(l->include_stack[i].owned_buf);
		if (l->include_stack[i].filename_owned)
			free((char *)l->include_stack[i].filename);
	}
	free(l->include_stack);
	for (i = 0; i < l->seen_count; i++) free(l->seen_includes[i]);
	free(l->seen_includes);
	if (l->has_lookahead) free(l->lookahead.text);
	free(l->pending_doc_brief);
	free(l->pending_doc_details);
	free(l->pending_doc_return);
	{
		int i;
		for (i = 0; i < l->pending_doc_param_count; i++) {
			free(l->pending_doc_param_names[i]);
			free(l->pending_doc_param_descs[i]);
		}
	}
	free(l->pending_doc_param_names);
	free(l->pending_doc_param_descs);
}

Token lexer_error(Lexer *l, const char *msg) {
	fprintf(stderr, "%s:%d:%d: error: %s\n", l->filename, l->line, l->col, msg);
	l->had_error = 1;
	return make_token(TOK_ERROR, "<error>", l->line, l->col);
}

static Token lex_one(Lexer *l) {
	skip_whitespace_and_comments(l);

	if (l->pos >= l->len) {
		if (l->include_depth > 0) {
			free(l->owned_buf);
			if (l->filename_owned) free((char *)l->filename);
			IncludeFrame *fr = &l->include_stack[--l->include_depth];
			if (fr->macro_expanding_flag) *fr->macro_expanding_flag = 0;
			l->src            = fr->src;
			l->owned_buf      = fr->owned_buf;
			l->pos            = fr->pos;
			l->len            = fr->len;
			l->line           = fr->line;
			l->col            = fr->col;
			l->filename       = fr->filename;
			l->filename_owned = fr->filename_owned;
			return lex_one(l);
		}
		return make_token(TOK_EOF, "<eof>", l->line, l->col);
	}

	int    sl = l->line, sc = l->col;
	char   c  = l->src[l->pos];

	
	if (c == '#' && l->col == 1) {
		advance_ch(l);
		handle_directive(l);
		return lex_one(l);
	}

	
	if (c == '"') return lex_string(l, sl, sc);

	
	if (c == '\'') return lex_char_literal(l, sl, sc);

	
	if (isdigit((unsigned char)c) || (c == '.' && isdigit((unsigned char)peek_ch2(l)))) {
		return lex_number(l, sl, sc);
	}

	
	if (is_ident_start(c)) {
		char buf[256]; int i = 0;
		while (l->pos < l->len && is_ident_body(l->src[l->pos]) && i < 255)
			buf[i++] = advance_ch(l);
		buf[i] = '\0';
		TokenType kw = keyword_type(buf);
		Token t = make_token(kw, buf, sl, sc);
		
		if (kw == TOK_IDENT) {
			struct MacroDef *mdef = lookup_macro_def(l, buf);
			if (mdef && !mdef->expanding) {
				if (mdef->is_function_like) {
					int sp = l->pos, sl2 = l->line, sc2 = l->col;
					while (l->pos < l->len &&
					    (l->src[l->pos]==' '||l->src[l->pos]=='\t'||l->src[l->pos]=='\n'))
						advance_ch(l);
					if (l->pos < l->len && l->src[l->pos] == '(') {
						char *eargs[64]; int neargs, use, k;
						char *ebuf;
						advance_ch(l);
						neargs = collect_macro_args(l, eargs, 64);
						use  = neargs < mdef->param_count ? neargs : mdef->param_count;
						ebuf = substitute_params(mdef->body, mdef->params, eargs, use);
						for (k = 0; k < neargs; k++) free(eargs[k]);
						mdef->expanding = 1;
						push_expansion(l, ebuf, &mdef->expanding);
						free(t.text);
						return lex_one(l);
					} else {
						l->pos = sp; l->line = sl2; l->col = sc2;
					}
				} else {
					mdef->expanding = 1;
					push_expansion(l, strdup(mdef->body), &mdef->expanding);
					free(t.text);
					return lex_one(l);
				}
			}
		}
		return t;
	}

	advance_ch(l);

	
	char n = peek_ch(l);
	switch (c) {
	case '+':
		if (n == '+') { advance_ch(l); return make_token(TOK_PLUS_PLUS,   "++", sl, sc); }
		if (n == '=') { advance_ch(l); return make_token(TOK_PLUS_ASSIGN,  "+=", sl, sc); }
		return make_token(TOK_PLUS, "+", sl, sc);
	case '-':
		if (n == '-') { advance_ch(l); return make_token(TOK_MINUS_MINUS,  "--", sl, sc); }
		if (n == '=') { advance_ch(l); return make_token(TOK_MINUS_ASSIGN, "-=", sl, sc); }
		if (n == '>') { advance_ch(l); return make_token(TOK_ARROW,        "->", sl, sc); }
		return make_token(TOK_MINUS, "-", sl, sc);
	case '*':
		if (n == '=') { advance_ch(l); return make_token(TOK_STAR_ASSIGN,  "*=", sl, sc); }
		return make_token(TOK_STAR, "*", sl, sc);
	case '/':
		if (n == '=') { advance_ch(l); return make_token(TOK_SLASH_ASSIGN, "/=", sl, sc); }
		return make_token(TOK_SLASH, "/", sl, sc);
	case '%':
		if (n == '=') { advance_ch(l); return make_token(TOK_PERCENT_ASSIGN, "%=", sl, sc); }
		return make_token(TOK_PERCENT, "%", sl, sc);
	case '&':
		if (n == '&') { advance_ch(l); return make_token(TOK_AMP_AMP,    "&&", sl, sc); }
		if (n == '=') { advance_ch(l); return make_token(TOK_AMP_ASSIGN,  "&=", sl, sc); }
		return make_token(TOK_AMPERSAND, "&", sl, sc);
	case '|':
		if (n == '|') { advance_ch(l); return make_token(TOK_PIPE_PIPE,   "||", sl, sc); }
		if (n == '=') { advance_ch(l); return make_token(TOK_PIPE_ASSIGN,  "|=", sl, sc); }
		return make_token(TOK_PIPE, "|", sl, sc);
	case '^':
		if (n == '=') { advance_ch(l); return make_token(TOK_CARET_ASSIGN, "^=", sl, sc); }
		return make_token(TOK_CARET, "^", sl, sc);
	case '~': return make_token(TOK_TILDE, "~", sl, sc);
	case '!':
		if (n == '=') { advance_ch(l); return make_token(TOK_BANG_EQ,  "!=", sl, sc); }
		return make_token(TOK_BANG, "!", sl, sc);
	case '<':
		if (n == '<') {
			advance_ch(l);
			if (peek_ch(l) == '=') { advance_ch(l); return make_token(TOK_LSHIFT_ASSIGN, "<<=", sl, sc); }
			return make_token(TOK_LSHIFT, "<<", sl, sc);
		}
		if (n == '=') { advance_ch(l); return make_token(TOK_LT_EQ, "<=", sl, sc); }
		return make_token(TOK_LT, "<", sl, sc);
	case '>':
		if (n == '>') {
			advance_ch(l);
			if (peek_ch(l) == '=') { advance_ch(l); return make_token(TOK_RSHIFT_ASSIGN, ">>=", sl, sc); }
			return make_token(TOK_RSHIFT, ">>", sl, sc);
		}
		if (n == '=') { advance_ch(l); return make_token(TOK_GT_EQ, ">=", sl, sc); }
		return make_token(TOK_GT, ">", sl, sc);
	case '=':
		if (n == '=') { advance_ch(l); return make_token(TOK_EQ_EQ, "==", sl, sc); }
		return make_token(TOK_ASSIGN, "=", sl, sc);
	case '.':
		if (n == '.' && l->pos + 1 < l->len && l->src[l->pos+1] == '.') {
			advance_ch(l); advance_ch(l);
			return make_token(TOK_ELLIPSIS, "...", sl, sc);
		}
		return make_token(TOK_DOT, ".", sl, sc);
	case '?': return make_token(TOK_QUESTION, "?", sl, sc);
	case ':': return make_token(TOK_COLON, ":", sl, sc);
	case '(': return make_token(TOK_LPAREN, "(", sl, sc);
	case ')': return make_token(TOK_RPAREN, ")", sl, sc);
	case '{': return make_token(TOK_LBRACE, "{", sl, sc);
	case '}': return make_token(TOK_RBRACE, "}", sl, sc);
	case '[': return make_token(TOK_LBRACKET, "[", sl, sc);
	case ']': return make_token(TOK_RBRACKET, "]", sl, sc);
	case ';': return make_token(TOK_SEMICOLON, ";", sl, sc);
	case ',': return make_token(TOK_COMMA, ",", sl, sc);
	case '#': return make_token(TOK_HASH, "#", sl, sc);
	default:  {
		char msg[32];
		sprintf(msg, "unexpected character '%c'", c);
		return lexer_error(l, msg);
	}
	}
}

Token lexer_next(Lexer *l) {
	if (l->has_lookahead) {
		Token t = l->lookahead;
		l->has_lookahead = 0;
		return t;
	}
	{
		Token t = lex_one(l);
		t.doc_brief            = l->pending_doc_brief;
		t.doc_details          = l->pending_doc_details;
		t.doc_param_names      = l->pending_doc_param_names;
		t.doc_param_descs      = l->pending_doc_param_descs;
		t.doc_param_count      = l->pending_doc_param_count;
		t.doc_return           = l->pending_doc_return;
		l->pending_doc_brief        = NULL;
		l->pending_doc_details      = NULL;
		l->pending_doc_param_names  = NULL;
		l->pending_doc_param_descs  = NULL;
		l->pending_doc_param_count  = 0;
		l->pending_doc_param_cap    = 0;
		l->pending_doc_return       = NULL;
		return t;
	}
}

const Token *lexer_peek(Lexer *l) {
	if (!l->has_lookahead) {
		l->lookahead = lex_one(l);
		l->lookahead.doc_brief            = l->pending_doc_brief;
		l->lookahead.doc_details          = l->pending_doc_details;
		l->lookahead.doc_param_names      = l->pending_doc_param_names;
		l->lookahead.doc_param_descs      = l->pending_doc_param_descs;
		l->lookahead.doc_param_count      = l->pending_doc_param_count;
		l->lookahead.doc_return           = l->pending_doc_return;
		l->pending_doc_brief        = NULL;
		l->pending_doc_details      = NULL;
		l->pending_doc_param_names  = NULL;
		l->pending_doc_param_descs  = NULL;
		l->pending_doc_param_count  = 0;
		l->pending_doc_param_cap    = 0;
		l->pending_doc_return       = NULL;
		l->has_lookahead = 1;
	}
	return &l->lookahead;
}
