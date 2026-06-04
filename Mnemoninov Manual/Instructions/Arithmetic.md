# Arithmetic

Arithmetic instructions perform mathematical operations on integers. They include both fundamental and utility operations, like min, max, clamp, and more.

---

**`add` → Add [c]**
Adds two values.
Operands: `[dest], a, b`
Pseudocode: `dest = a + b`
[c] Pseudocode: `a += b`

**`sub` → Subtract [c]**
Subtracts one value from another.
Operands: `[dest], a, b`
Pseudocode: `dest = a - b`
[c] Pseudocode: `a -= b`

**`inc` → Increment**
Increments a register by one.
Operands: `dest`
Pseudocode: `dest++`

**`dec` → Decrement**
Decrements a register by one.
Operands: `dest`
Pseudocode: `dest--`

**`mul` → Multiply [c]**
Multiplies two values and stores the lower 32 bits of the result.
Operands: `[dest], a, b`
Pseudocode: `dest = (a * b)[31:0]`
[c] Pseudocode: `a = (a * b)[31:0]`

**`mlh` → Multiply High [c]**
Multiplies two values and stores the upper 32 bits of the result.
Operands: `[dest], a, b`
Pseudocode: `dest = (a * b)[63:32]`
[c] Pseudocode: `a = (a * b)[63:32]`

**`pow` → Power [c]**
Raises one value to the power of another.
Operands: `[dest], base, exponent`
Pseudocode: `dest = base ** exponent`
[c] Pseudocode: `base **= exponent`

**`div` → Divide [c]**
Divides one value by another.
Operands: `[dest], dividend, divisor`
Pseudocode: `dest = dividend / divisor`
[c] Pseudocode: `dividend /= divisor`

**`rem` → Remainder [c]**
Computes the remainder of a division, preserving the dividend's sign.
Operands: `[dest], dividend, divisor`
Pseudocode: `dest = dividend % divisor`
[c] Pseudocode: `dividend %= divisor`

**`mod` → Modulo [c]**
Computes the modulo of a division, preserving the divisor's sign.
Operands: `[dest], dividend, divisor`
Pseudocode: `dest = dividend %% divisor`
[c] Pseudocode: `dividend %%= divisor`

**`neg` → Negate [c]**
Negates a value.
Operands: `[dest], value`
Pseudocode: `dest = -value`
[c] Pseudocode: `value = -value`

**`abs` → Absolute [c]**
Computes the absolute value.
Operands: `[dest], value`
Pseudocode: `dest = abs(value)`
[c] Pseudocode: `value = abs(value)`

**`sgn` → Sign [c]**
Computes the sign of a value.
Operands: `[dest], value`
Pseudocode: `dest = sign(value)`
[c] Pseudocode: `value = sign(value)`

**`min` → Minimum [c]**
Selects the smaller of two values.
Operands: `[dest], a, b`
Pseudocode: `dest = min(a, b)`
[c] Pseudocode: `a = min(a, b)`

**`max` → Maximum [c]**
Selects the larger of two values.
Operands: `[dest], a, b`
Pseudocode: `dest = max(a, b)`
[c] Pseudocode: `a = max(a, b)`

**`clp` → Clamp [c]**
Clamps a value to the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `[dest], value, min, max`
Pseudocode: `dest = clamp(value, min, max)`
[c] Pseudocode: `value = clamp(value, min, max)`

**`rnd` → Random**
Generates a pseudo-random value in the range `[min, max]`. The operand `max` is exclusive. If `max < min`, the operands are swapped.
Operands: `dest, min, max`
Pseudocode: `dest = rand_range(min, max)`
