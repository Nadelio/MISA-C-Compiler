# Expressions

The assembler supports expressions in places where a value is expected. Expressions can combine integer and float literals, user-defined constants, labels, and built-in symbols.

Expressions are evaluated at assemble-time.

---

## Supported Elements

Expressions may include:
- Integer literals (e.g. `42`, `0x2a`, `0b101010`)
- Floating-point literals (e.g. `3.14`)
- User-defined constants (defined with `def`)
- Labels (evaluated to pa-relative addresses)
- Built-in symbols (e.g. `PI`, `true`, `false`)
- The assembler address symbol `$`

Built-in symbols are documented on the Built-In Symbols page.

---

## Operators

Expressions support standard arithmetic and bitwise operators:
- Addition, subtraction, multiplication, division: `+`, `-`, `*`, `/`
- Unary negation: `-`
- Modulo (preserves divisor's sign): `%`
- Bit-shift left and right: `<<`, `>>`
- Bitwise not, and, or, xor: `~`, `&`, `|`, `^`

Logical operators are also supported. They evaluate to `1` or `0`.
- Logical not, and, or: `!`, `&&`, `||`
- Equality equal and not equal: `==`, `!=`
- Relational less than, greater than, less than equal, greater than equal: `<`, `>`, `<=`, `>=`

The assembler also implements non-standard operators:
- Power: `**`
- Remainder (preserves dividend's sign): `%%`
- Unary integer cast: `icast`
- Unary float cast: `fcast`

Operator precedence is equivalent to the C language. Parentheses can be used to override precedence:

```misa
2 * (3 + 4)  # Evaluates to 14 with parentheses and 10 without.
```

**General examples:**
```misa
def HALF_SCREEN_WIDTH (SCREEN_WIDTH / 2)
def CIRCLE_AREA       (PI * (RADIUS ** 2))
def ENABLE_SHADOWS    (QUALITY >= 2)
```

---

## Casting

When binary operators are evaluated, if an operand is a float, the other will be implicitly cast to a float:

```misa
5   / 2    # Evaluates to 2
5.0 / 2    # Evaluates to 2.5
5   / 2.0  # Evaluates to 2.5
```

Values can be explicitly converted using the unary cast operators:

```misa
icast 3.14  # Evaluates to 3
fcast 42    # Evaluates to 42.0
```

---

## Using Labels in Expressions

Labels evaluate to pa-relative addresses and can be used in arithmetic expressions. This is convenient for computing offsets to struct components, and calculating the struct size:

```misa
MY_STRUCT:
    .foo: emb u32t 42
    .bar: emb u32t 99
    def ._FOO  (.foo - MY_STRUCT)
    def ._BAR  (.bar - MY_STRUCT)
    def .STRUCT_SIZE ($ - MY_STRUCT)
```

In the example above, subtracting two labels results in the byte offset between them, while subtracting the struct start label from the current assembler address evaluates to the struct size.
