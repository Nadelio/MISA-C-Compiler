# Logic and Bitwise

Logic and bitwise instructions perform logical operations. They make it possible to compare values and compute basic bit operations.

---

## Comparison

**`cmp` → Compare**
Compares two values using the specified condition and writes the result to the comparison register.
Operands: `Condition, a, b`
Pseudocode: `cr = (a Condition b) ? 1 : 0`

Conditions for the `cmp` instruction:

| Cond.  | Description              | Pseudocode            |
|--------|--------------------------|-----------------------|
| `eq`   | Equal                    | `a == b`              |
| `neq`  | Not Equal                | `a != b`              |
| `lt`   | Less Than                | `a < b`               |
| `lte`  | Less Than Equal          | `a <= b`              |
| `gt`   | Greater Than             | `a > b`               |
| `gte`  | Greater Than Equal       | `a >= b`              |
| `ltu`  | Less Than (U)            | `a < b`               |
| `lteu` | Less Than Equal (U)      | `a <= b`              |
| `gteu` | Greater Than Equal (U)   | `a >= b`              |
| `feqa` | Float Equal Approx.      | `abs(b - a) < ε`      |
| `fneqa`| Float Not Equal Approx.  | `abs(b - a) >= ε`     |
| `flt`  | Float Less Than          | `a < b`               |
| `fgt`  | Float Greater Than       | `a > b`               |
| `fnan` | Float is NaN             | `is_nan(a)`           |
| `finf` | Float is Infinity        | `is_inf(a)`           |

Note: (U) is unsigned; ε is epsilon.

---

## Bitwise

**`not` → Not [c]**
Computes the bitwise NOT of a value.
Operands: `[dest], value`
Pseudocode: `dest = ~value`
[c] Pseudocode: `value = ~value`

**`and` → And [c]**
Computes the bitwise AND of two values.
Operands: `[dest], a, b`
Pseudocode: `dest = a & b`
[c] Pseudocode: `a &= b`

**`orr` → Or [c]**
Computes the bitwise OR of two values.
Operands: `[dest], a, b`
Pseudocode: `dest = a | b`
[c] Pseudocode: `a |= b`

**`xor` → Xor [c]**
Computes the bitwise XOR of two values.
Operands: `[dest], a, b`
Pseudocode: `dest = a ^ b`
[c] Pseudocode: `a ^= b`

**`sar` → Shift Arithmetic Right [c]**
Shifts a value right while preserving the sign bit.
Operands: `[dest], value, shift`
Pseudocode: `dest = value >> shift`
[c] Pseudocode: `value >>= shift`

**`sll` → Shift Logical Left [c]**
Shifts a value left, inserting zeros.
Operands: `[dest], value, shift`
Pseudocode: `dest = value << shift`
[c] Pseudocode: `value <<= shift`

**`slr` → Shift Logical Right [c]**
Shifts a value right, inserting zeros.
Operands: `[dest], value, shift`
Pseudocode: `dest = value >>> shift`
[c] Pseudocode: `value >>>= shift`

**`rol` → Rotate Left [c]**
Rotates a value left by the specified amount.
Operands: `[dest], value, shift`
Pseudocode: `dest = rotate_left(value, shift)`
[c] Pseudocode: `value = rotate_left(value, shift)`

**`ror` → Rotate Right [c]**
Rotates a value right by the specified amount.
Operands: `[dest], value, shift`
Pseudocode: `dest = rotate_right(value, shift)`
[c] Pseudocode: `value = rotate_right(value, shift)`
