# MISA C Implementation Profile

MISA C is a freestanding ISO C99 implementation for the 32-bit, big-endian
MISA target. This document records behavior that ISO C99 leaves
implementation-defined.

## Bytes, integer types, and representations

- A byte is 8 bits (`CHAR_BIT == 8`).
- Plain `char` is signed and has the same range and representation as
  `signed char`.
- `char` is 8 bits, `short` and `int` are 16 bits, and `long` is 32 bits.
- Signed integer types use two's-complement representation.
- Unsigned arithmetic is reduced modulo 2 to the width of the type.
- Right shift of a negative signed integer is arithmetic.
- An `enum` has the size, alignment, representation, and rank of signed
  32-bit `long`.
- `_Bool` occupies one byte. Conversion to `_Bool` produces zero or one.
- No 64-bit integer type is provided. `long long` declarations and integer
  constants that cannot be represented by `unsigned long` are diagnosed.

| Type | Size | Alignment | Minimum | Maximum |
|---|---:|---:|---:|---:|
| `signed char` | 1 | 1 | -128 | 127 |
| `unsigned char` | 1 | 1 | 0 | 255 |
| `short` | 2 | 2 | -32768 | 32767 |
| `unsigned short` | 2 | 2 | 0 | 65535 |
| `int` | 2 | 2 | -32768 | 32767 |
| `unsigned int` | 2 | 2 | 0 | 65535 |
| `long` | 4 | 4 | -2147483648 | 2147483647 |
| `unsigned long` | 4 | 4 | 0 | 4294967295 |
| `_Bool` | 1 | 1 | 0 | 1 |
| `enum` | 4 | 4 | -2147483648 | 2147483647 |

## Floating and complex types

- `float`, `double`, and `long double` use the MISA 32-bit floating
  representation and have size and alignment 4. The compiler does not provide
  additional precision for `double` or `long double`.
- Floating evaluation uses the semantic type's precision; `FLT_EVAL_METHOD`
  is zero.
- A complex object is two adjacent 32-bit floating components. The real
  component is at offset zero and the imaginary component is at offset four.
  Complex size is 8 and alignment is 4.

## Pointers, layout, and byte order

- Object and function pointers are 32-bit addresses with size and alignment 4.
- A null pointer is represented by an all-zero address.
- The target is big-endian for multi-byte scalar objects.
- Structures preserve declaration order, align each member to its natural
  alignment, and include tail padding to the largest member alignment.
- Unions have the size of their largest member rounded to the largest member
  alignment.
- Integer bit-fields allocate from the most-significant end of an allocation
  unit of their declared type. Plain signed bit-fields are signed.

## Calling convention

- Up to sixteen argument registers (`a0` through `a15`) are available.
  Calls that exceed this fixed limit are diagnosed.
- Scalars occupy one argument register. Structures and unions are passed by
  address.
- Complex values occupy two consecutive argument registers, real component
  first. Complex return values use `a0` for the real component and `a1` for
  the imaginary component.
- All argument registers are caller-saved.

The instruction-level calling convention is also described in
[ABI Conventions](Platform%20Interface/ABI%20Conventions.md).
