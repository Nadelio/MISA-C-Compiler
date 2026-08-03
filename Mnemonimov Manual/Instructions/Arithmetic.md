# Arithmetic

Arithmetic instructions perform mathematical operations on integers. They include both fundamental and utility operations, like min, max, clamp, and more.

Note that arithmetic instruction operate on signed values unless noted otherwise. Unsigned variants of operations where signedness affects the result listed at the end of this page.

---

**`add` -> Add [c]**
Adds two values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = a + b;
```
[c] Pseudocode: 
```c
a += b;
```

**`sub` -> Subtract [c]**
Subtracts one value from another.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = a - b;
```
[c] Pseudocode: 
```c
a -= b;
```

**`inc` -> Increment**
Increments a register by one.
Operands: `dest`
Pseudocode: 
```c
dest++;
```

**`dec` -> Decrement**
Decrements a register by one.
Operands: `dest`
Pseudocode: 
```c
dest--;
```

**`mul` -> Multiply [c]**
Multiplies two values and stores the lower 32 bits of the result.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = (a * b)[31:0];  
```
[c] Pseudocode: 
```c
a = (a * b)[31:0]; 
```

**`mlh` -> Multiply High [c]**
Multiplies two values and stores the upper 32 bits of the result.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = (a * b)[63:32]; 
```
[c] Pseudocode: 
```c
a = (a * b)[63:32];
```

**`fmh` -> Fused Multiply-Add [c]**
Performs a fused multiply-add operation.
Operands: `[dest], a, b, c`
Pseudocode:
```c
dest = (a * b) + c;
```
[c] Pseudocode:
```c
a = (a * b) + c;
```

**`pow` -> Power [c]**
Raises one value to the power of another.
Operands: `[dest], base, exponent`
Pseudocode: 
```c
dest = base ** exponent;
```
[c] Pseudocode: 
```c
base **= exponent;
```

**`div` -> Divide [c]**
Divides one value by another.
Operands: `[dest], dividend, divisor`
Pseudocode: 
```c
dest = dividend / divisor;
```
[c] Pseudocode: 
```c
dividend /= divisor;
```

**`rem` -> Remainder [c]**
Computes the remainder of a division, preserving the dividend's sign.
Operands: `[dest], dividend, divisor`
Pseudocode: 
```c
dest = dividend % divisor;
```
[c] Pseudocode: 
```c
dividend %= divisor;
```

**`mod` -> Modulo [c]**
Computes the modulo of a division, preserving the divisor's sign.
Operands: `[dest], dividend, divisor`
Pseudocode: 
```c
dest = dividend %% divisor;
```
[c] Pseudocode: 
```c
dividend %%= divisor;
```

**`neg` -> Negate [c]**
Negates a value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = -value;
```
[c] Pseudocode: 
```c
value = -value;
```

**`abs` -> Absolute [c]**
Computes the absolute value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = abs(value); 
```
[c] Pseudocode: 
```c
value = abs(value);
```

**`sgn` -> Sign [c]**
Computes the sign of a value. Outputs a `-1`, `0`, or `1` when the value is less than, equal to, or greater than `0`, respectively.
Operands: `[dest], value`
Pseudocode: 
```c
dest = sign(value);
```
[c] Pseudocode: 
```c
value = sign(value);
```

**`min` -> Minimum [c]**
Selects the smaller of two values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = min(a, b);
```
[c] Pseudocode: 
```c
a = min(a, b);
```

**`max` -> Maximum [c]**
Selects the larger of two values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = max(a, b);
```
[c] Pseudocode: 
```c
a = max(a, b);
```

**`clp` -> Clamp [c]**
Clamps a value to the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `[dest], value, min, max`
Pseudocode: 
```c
dest = clamp(value, min, max);
```
[c] Pseudocode: 
```c
value = clamp(value, min, max);
```

**`rnd` -> Random**
Generates a pseudo-random value in the range `[min, max]`. The operand `max` is exclusive. If `max < min`, the operands are swapped.
Operands: `dest, min, max`
Pseudocode: 
```c
dest = rand_range(min, max);
```

---

## Unsigned Variants

Unsigned variants of arithmetic instructions treat values as unsigned rather than signed. They are provided only for operations where signedness affects the result.

---

**`mlhu` -> Multiply High Unsigned [c]**
Multiplies two unsignend values and stores the upper 32 bits of the result.
Operands: `[dest], a, b
Pseudocode:
```c
dest = (a * b)[63:32];
```
[c] Pseudocode:
```c
a = (a * b)[63:32];
```

**`divu` -> Divide Unsigned [c]**
Divides one unsigned value by another.
Operands: `[dest], dividend, divisor`
Pseudocode:
```c
dest = dividend / divisor;
```
[c] Pseudocode:
```c
dividend /= divisor;
```

**`remu` -> Remainder Unsigned [c]**
Computes the remainder of an unsigned division.
Operands: `[dest], dividend, divisor`
Pseudocode:
```c
dest = dividend % divisor;
```
[c] Pseudocode:
```c
dividend %= divisor;
```

**`minu` -> Minimum Unsigned [c]**
Selects the smaller of the two unsigned values.
Operands: `[dest], a, b`
Pseudocode:
```c
dest = min(a, b);
```
[c] Pseudocode:
```c
a = min(a, b);
```

**`maxu` -> Maximum Unsigned [c]**
Selects the larger of the two unsigned values.
Operands: `[dest], a, b`
Pseudocode:
```c
dest = max(a, b);
```
[c] Pseudocode:
```c
a = max(a, b);
```

**`clpu` -> Clamp Unsigned [c]**
Clamps an unsigned value to the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `[dest], value, min, max`
Pseudocode:
```c
dest = clamp(value, min, max);
```
[c] Pseudocode:
```c
value = clamp(value, min, max);
```