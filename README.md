# MISA C Compiler
A C89 compiler that targets the MISA/Mnemonimov VM architecture.

## Building

Requires `clang`. Run:

```
make
```

Or manually:

```
clang -Iinclude -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE \
  src/token.c src/ast.c src/type.c src/symtab.c \
  src/lexer.c src/parser.c src/sema.c src/codegen.c src/main.c -o misacc.exe
```

## Usage

```
misacc.exe <input.c> [-o output.misa]
```

- `<input.c>` — C89 source file to compile (required)
- `-o output.misa` — write output to a file instead of stdout

**Examples:**

```
misacc.exe program.c -o program.misa
misacc.exe program.c > program.misa
```