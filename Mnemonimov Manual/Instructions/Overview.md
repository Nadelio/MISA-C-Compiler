# Overview

## Presentation Format

Instructions are listed using the following structure:

**Mnemonic -> Instruction Name [c]**
The mnemonic is a semantic abbreviation of the instruction's name. It is the keyword you use when writing assembly code.
The `[c]` tag indicates that the instruction supports an alternative compact form.

**Description**
A brief explanation of what the instruction does.

**Operands:** `[dest], a, b`
Operands are the arguments for the instruction. When the compact form is supported, the destination operand may be omitted.
Capitalized operands (e.g. `Syscall`, `Type`, `Condition`) refer to built-in MISA elements.

**Pseudocode:** `dest = a + b`
C-like pseudocode illustrating the behavior of the instruction.

**[c] Pseudocode:** `a += b`
Alternative pseudocode illustrating the compact form.

---

## Syntax
Instructions are separated by newlines, meaning that there can only be one instruction per line. Operands are separated by commas.

MISA has a destination-first syntax. This means that for instructions that output a value, the destination operand is listed before any source operands.

Memory access in MISA is exposed through explicit load and store instructions rather than memory operands.

---

## Immediates

Immediate values can be used in place of register operands when the value is read:

```
mov t0, 40      # Loads register t0 with the immediate value 40.
add t0, 2       # Adds the immediate value 2 to register t0.
```

However, operands that are written to must be registers:

```
mov 42, t0      # Invalid: the destination must be a register.
swp t0, 123     # Invalid: both operands must be registers.
```

---

## Type and Signedness

The assembler does not implicitly convert operands to the types expected by instructions or system calls. If a value is intended to be a float, always write it as a floating-point literal by including the decimal part. See *No Implicit Casting of Operands* in the [Literals](../Assembly/Literals.md) chapter for details.

Unless noted otherwise, integer operands and results are interpreted as signed.

---

## Compact Form

When an instruction supports the compact form (`[c]`), the destination operand may be omitted, and the first value operand is implicitly used as the destination:

```
# Base form, the result is stored in a separate register.
add t1, t0, 2   # t1 = t0 + 2

# Compact form, the operation is performed in-place.
add t0, 2       # t0 += 2
```

The compact form only changes which register is used as the destination.
