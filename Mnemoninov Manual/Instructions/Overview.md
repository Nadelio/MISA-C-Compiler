# Overview

## Presentation Format

Instructions are listed using the following structure:

**Mnemonic → Instruction Name [c]**
The mnemonic is a semantic abbreviation of the instruction's name. It is the keyword you use when writing assembly code.
The `[c]` tag indicates that the instruction supports an alternative compact form.

**Operands:** `[dest], a, b`
Operands are the arguments for the instruction. When the compact form is supported, the destination operand may be omitted.
Capitalized operands (e.g. `Syscall`, `Type`, `Condition`) refer to built-in MISA elements.

**Pseudocode:** `dest = a + b`
C-like pseudocode illustrating the behavior of the instruction.

**[c] Pseudocode:** `a += b`
Alternative pseudocode illustrating the compact form.

---

## Immediates

Immediate values can be used in place of register operands when the value is read:

```misa
mov t0, 40      # Loads register t0 with the immediate value 40.
add t0, 2       # Adds the immediate value 2 to register t0.
```

However, operands that are written to must be registers:

```misa
mov 42, t0      # Invalid: the destination must be a register.
swp t0, 123     # Invalid: both operands must be registers.
```

---

## Compact Form

When an instruction supports the compact form (`[c]`), the destination operand may be omitted, and the first value operand is implicitly used as the destination:

```misa
# Base form, the result is stored in a separate register.
add t1, t0, 2   # t1 = t0 + 2

# Compact form, the operation is performed in-place.
add t0, 2       # t0 += 2
```

The compact form only changes which register is used as the destination.
