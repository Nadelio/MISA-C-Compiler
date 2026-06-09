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

static void handle_directive(Lexer *l) {
	char name[64];
	int  ni = 0;

	
	while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;

	
	while (l->pos < l->len && isalpha((unsigned char)l->src[l->pos]) && ni < 63)
		name[ni++] = l->src[l->pos++];
	name[ni] = '\0';

	if (!strcmp(name, "define")) {
		
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		
		char mname[64]; int mi = 0;
		while (l->pos < l->len && is_ident_body(l->src[l->pos]) && mi < 63)
			mname[mi++] = l->src[l->pos++];
		mname[mi] = '\0';
		
		while (l->pos < l->len && l->src[l->pos] == ' ') l->pos++;
		
		char body[256]; int bi = 0;
		while (l->pos < l->len && l->src[l->pos] != '\n' && bi < 255)
			body[bi++] = l->src[l->pos++];
		body[bi] = '\0';
		
		while (bi > 0 && body[bi-1] == ' ') body[--bi] = '\0';

		if (l->macro_count >= l->macro_cap) {
			l->macro_cap = l->macro_cap ? l->macro_cap * 2 : MACRO_INIT_CAP;
			l->macros = (struct MacroDef *)realloc(l->macros,
			    l->macro_cap * sizeof(*l->macros));
		}
		l->macros[l->macro_count].name = strdup(mname);
		l->macros[l->macro_count].body = strdup(body);
		l->macro_count++;
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
			if (l->pos < l->len && l->src[l->pos] == delim_close) l->pos++;
			
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
						fr->filename_owned = l->filename_owned;
						
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
	}
	
	while (l->pos < l->len && l->src[l->pos] != '\n') l->pos++;
}

static const char *lookup_macro(Lexer *l, const char *name) {
	int i;
	for (i = 0; i < l->macro_count; i++) {
		if (!strcmp(l->macros[i].name, name)) return l->macros[i].body;
	}
	return NULL;
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
		free(l->macros[i].name);
		free(l->macros[i].body);
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
			const char *body = lookup_macro(l, buf);
			if (body) {
				
				Lexer tmp;
				lexer_init(&tmp, body, (int)strlen(body), l->filename);
				Token expanded = lex_one(&tmp);
				expanded.line = sl;
				expanded.col  = sc;
				lexer_free(&tmp);
				free(t.text);
				return expanded;
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
