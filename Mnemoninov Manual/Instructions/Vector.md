# Vector

Vector instructions operate on contiguous ranges of registers. They make it possible to push, pop, and move registers in bulk, and to execute fundamental arithmetic operations on float vectors using a single instruction.

---

## Syntax

Vector instructions infer their working size from the first operand, which is always a register range, written using the range operator `..` as shown below:

```misa
s0..s2
```

This defines both the destination registers and the vector size.

All remaining operands specify only their starting registers, but their behavior depends on whether the range operator is present:
- When present (e.g. `t4..`), the operand is treated as a vector range with the same size as the destination range.
- When omitted (e.g. `a2`), the operand is treated as a scalar value and is broadcast across all elements of the destination.

Full example using the Vector Float Add instruction:

```misa
vfadd s0..s2, t4.., a2
```

In this case:
- `s0..s2` defines a three-element destination vector: `[s0, s1, s2]`.
- `t4..` is interpreted as a three-element source vector: `[t4, t5, t6]`.
- `a2` is interpreted as a scalar value applied to all elements: `[a2, a2, a2]`.

---

**`vpsh` → Vector Push**
Pushes a range of registers onto the stack.
Operands: `register_range`
Pseudocode: `vector_push(register_range)`

**`vpop` → Vector Pop**
Pops a range of registers from the stack.
Operands: `register_range`
Pseudocode: `vector_pop(register_range)`

**`vmov` → Vector Move**
Copies a range of registers to another.
Operands: `dest_range, source_start`
Pseudocode: `vector_move(dest_range, source_start)`

**`vfadd` → Vector Float Add [c]**
Adds two ranges of float values.
Operands: `[dest_range], a_start, b_start`
Pseudocode: `vector_fadd(dest_range, a_start, b_start)`
[c] Pseudocode: `vector_fadd(a_range, b_start)`

**`vfsub` → Vector Float Sub [c]**
Subtracts two ranges of float values.
Operands: `[dest_range], a_start, b_start`
Pseudocode: `vector_fsub(dest_range, a_start, b_start)`
[c] Pseudocode: `vector_fsub(a_range, b_start)`

**`vfmul` → Vector Float Multiply [c]**
Multiplies two ranges of float values.
Operands: `[dest_range], a_start, b_start`
Pseudocode: `vector_fmul(dest_range, a_start, b_start)`
[c] Pseudocode: `vector_fmul(a_range, b_start)`

**`vffma` → Vector Float Fused Multiply-Add [c]**
Performs a fused multiply-add operation with ranges of float values.
Operands: `[dest_range], a_start, b_start, c_start`
Pseudocode: `vector_ffma(dest_range, a_start, b_start, c_start)`
[c] Pseudocode: `vector_ffma(a_range, b_start, c_start)`

**`vfdiv` → Vector Float Divide [c]**
Divides two ranges of float values.
Operands: `[dest_range], a_start, b_start`
Pseudocode: `vector_fdiv(dest_range, a_start, b_start)`
[c] Pseudocode: `vector_fdiv(a_range, b_start)`
