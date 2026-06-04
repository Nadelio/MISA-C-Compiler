# Specification Scope

This page defines what aspects of MISA are part of the specification, and what aspects are not. Knowing the distinction helps you write robust programs which remain compatible across console versions. It also prepares you for breaking changes when they are introduced.

---

## Specified Behavior

The MISA specification covers program semantics, and includes:

- Instruction semantics and behavior.
- Registers and their intended roles.
- Calling conventions and register usage conventions.
- Flow control.
- System calls and their behaviors.
- Types and conditions.
- Expression evaluation rules.
- Built-in symbols.

Programs may rely on these behaviors as they are considered stable. Stability does not mean these behaviors are immutable across console versions. It means they can be assumed to remain unchanged unless changes are explicitly introduced, which may include breaking changes.

---

## Unspecified Behavior

The MISA specification does not cover exact binary representations, and excludes:

- Instruction encoding.
- The byte values associated with built-in operands (e.g. `Type`, `Syscall`, `Condition`).
- Assembler code generation strategies.
- Internal binary layouts or encodings not explicitly documented.
- Instruction ordering or other choices made by the assembler.

Programs may **not** rely on these behaviors as they are considered unstable. Instability here means these behaviors are implementation-defined and may completely change across versions without notice. As a result, identical source code assembled under different console versions may produce different binaries.

---

## Notes

Most programs will not be affected by implementation details. As long as your programs rely on specified behavior, they will continue to run as intended across updates.

Note that unspecified behavior should not be confused with undefined behavior. Unspecified behavior produces well-defined results for a given implementation.
