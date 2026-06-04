# Literals

Literals are constant values written directly in the source code. The assembler supports integer, floating-point, and string literals.

---

## Integer Literals

Integer literals may be written in the following bases:

```misa
42          # Decimal
0x2a        # Hexadecimal (prefix '0x')
0b101010    # Binary (prefix '0b')
0o52        # Octal (prefix '0o')
```

---

## Floating-Point Literals

Floating-point literals use the format:

```
<integer>.<integer>
```

Examples:
```misa
1.0
3.14
0.25
```

Scientific notation is not supported.

---

## Underscores

Underscores may be used as visual separators and are ignored by the assembler:

```misa
10_000
0b1010_0101
1_000.0
```

---

## No Implicit Casting of Operands

The assembler does not implicitly convert operands to the types expected by instructions or system calls. Since the binary representation of integers and floats is fundamentally different, operations using the wrong operand types will yield incorrect results.

Correct — the integer and float instructions execute with an integer and float value, respectively:
```misa
add t0, 1
fadd t1, 1.0
```

Incorrect — the integer and float instructions execute with the wrong type, yielding unexpected results:
```misa
add t0, 1.0
fadd t1, 1
```

If a value is meant to be a float, always include the decimal part.

---

## String Literals

String literals are supported with text enclosed by double quotation marks (`"`):

```misa
"Hello, World!"
```
