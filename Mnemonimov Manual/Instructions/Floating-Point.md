# Floating-Point

Floating point instructions perform mathematical operations on floats. They include both fundamental and utility operations, like trigonometric functions.

---

## Conversion

**`fcti` -> Float Convert Float to Int [c]**
Converts a floating-point value to an integer.
Operands: `[dest], value`
Pseudocode: 
```c
dest = (int)value;
```
[c] Pseudocode: 
```c
value = (int)value;
```

**`fctf` -> Float Convert Int to Float [c]**
Converts an integer value to floating-point.
Operands: `[dest], value`
Pseudocode: 
```c
dest = (float)value;
```
[c] Pseudocode: 
```c
value = (float)value;
```

---

## Arithmetic

**`fadd` -> Float Add [c]**
Adds two float values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = a + b;
```
[c] Pseudocode: 
```c
a += b;
```

**`fsub` -> Float Subtract [c]**
Subtracts one float value from another.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = a - b;
```
[c] Pseudocode: 
```c
a -= b;
```

**`fmul` -> Float Multiply [c]**
Multiplies two float values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = a * b;
```
[c] Pseudocode: 
```c
a *= b;
```

**`ffma` -> Float Fused Multiply-Add [c]**
Performs a fused multiply-add operation.
Operands: `[dest], a, b, c`
Pseudocode: 
```c
dest = a * b + c;
```
[c] Pseudocode: 
```c
a = a * b + c;
```

**`fdiv` -> Float Divide [c]**
Divides one float value by another.
Operands: `[dest], dividend, divisor`
Pseudocode: 
```c
dest = dividend / divisor;
```
[c] Pseudocode: 
```c
dividend /= divisor;
```

**`frem` -> Float Remainder [c]**
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

**`fmod` -> Float Modulo [c]**
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

**`fpow` -> Float Power [c]**
Raises one float value to the power of another.
Operands: `[dest], base, exponent`
Pseudocode: 
```c
dest = base ** exponent;
```
[c] Pseudocode: 
```c
base **= exponent;
```

**`fsqrt` -> Float Square Root [c]**
Computes the square root of a float value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = sqrt(value);
```
[c] Pseudocode: 
```c
value = sqrt(value);
```

**`frsqrt` -> Float Reciprocal Square Root [c]**
Computes the reciprocal (multiplicative inverse) of the square root.
Operands: `[dest], value`
Pseudocode: 
```c
dest = 1.0 / sqrt(value);
```
[c] Pseudocode: 
```c
value = 1.0 / sqrt(value);
```

**`fexp` -> Float Exponential Function [c]**
Computes the exponential function.
Operands: `[dest], value`
Pseudocode: 
```c
dest = exp(value);
```
[c] Pseudocode: 
```c
value = exp(value);
```

**`flog` -> Float Natural Log [c]**
Computes the natural logarithm.
Operands: `[dest], value`
Pseudocode: 
```c
dest = log(value);
```
[c] Pseudocode: 
```c
value = log(value);
```

---

## Utility

**`fneg` -> Float Negate [c]**
Negates a float value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = -value;
```
[c] Pseudocode: 
```c
value = -value;
```

**`fabs` -> Float Absolute [c]**
Computes the absolute float value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = abs(value);
```
[c] Pseudocode: 
```c
value = abs(value);
```

**`fsgn` -> Float Sign [c]**
Computes the sign of a float value. Outputs `-1.0`, `0.0`, or `1.0` when `value` is less than, equal to, or greater than `0.0` respectively.
Operands: `[dest], value`
Pseudocode: 
```c
dest = sign(value);
```
[c] Pseudocode: 
```c
value = sign(value);
```

**`fmin` -> Float Minimum [c]**
Selects the smaller of two float values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = min(a, b);
```
[c] Pseudocode: 
```c
a = min(a, b);
```

**`fmax` -> Float Maximum [c]**
Selects the larger of two float values.
Operands: `[dest], a, b`
Pseudocode: 
```c
dest = max(a, b);
```
[c] Pseudocode: 
```c
a = max(a, b);
```

**`fclp` -> Float Clamp [c]**
Clamps a float value to the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `[dest], value, min, max`
Pseudocode: 
```c
dest = clamp(value, min, max);
```
[c] Pseudocode: 
```c
value = clamp(value, min, max);
```

**`fwrp` -> Float Wrap [c]**
Wraps a float value within a specified range.
Operands: `[dest], value, min, max`
Pseudocode: 
```c
dest = wrap(value, min, max);
```
[c] Pseudocode: 
```c
value = wrap(value, min, max);
```

**`flrp` -> Float Linear Interpolation**
Performs linear interpolation between two float values.
Operands: `dest, a, b, t`
Pseudocode: 
```c
dest = lerp(a, b, t);
```

**`frnd` -> Float Random**
Generates a pseudo-random float value in the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `dest, min, max`
Pseudocode: 
```c
dest = rand_range(min, max);
```

---

## Rounding

**`fflo` -> Float Floor [c]**
Floors a float value (the result remains a float).
Operands: `[dest], value`
Pseudocode: 
```c
dest = floor(value);
```
[c] Pseudocode: 
```c
value = floor(value);
```

**`fcei` -> Float Ceiling [c]**
Ceils a float value (the result remains a float).
Operands: `[dest], value`
Pseudocode: 
```c
dest = ceil(value);
```
[c] Pseudocode: 
```c
value = ceil(value);
```

**`frou` -> Float Round [c]**
Rounds a float value using round-half-to-even (the result remains a float).
Operands: `[dest], value`
Pseudocode: 
```c
dest = round(value);
```
[c] Pseudocode: 
```c
value = round(value);
```

**`ftru` -> Float Truncate [c]**
Truncates the fractional part of a float value, rounding it toward zero (the result remains a float).
Operands: `[dest], value`
Pseudocode: 
```c
dest = trunc(value);
```
[c] Pseudocode: 
```c
value = trunc(value);
```

**`ffra` -> Float Fractional [c]**
Extracts the fractional part of a float value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = fract(value);
```
[c] Pseudocode: 
```c
value = fract(value);
```

---

## Trigonometry

**`fsin` -> Float Sine [c]**
Computes the sine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: 
```c
dest = sin(value);
```
[c] Pseudocode: 
```c
value = sin(value);
```

**`fcos` -> Float Cosine [c]**
Computes the cosine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: 
```c
dest = cos(value);
```
[c] Pseudocode: 
```c
value = cos(value);
```

**`ftan` -> Float Tangent [c]**
Computes the tangent of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: 
```c
dest = tan(value);
```
[c] Pseudocode: 
```c
value = tan(value);
```

**`fasin` -> Float Arcsin [c]**
Computes the arcsine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: 
```c
dest = asin(value);
```
[c] Pseudocode: 
```c
value = asin(value);
```

**`facos` -> Float Arccos [c]**
Computes the arccosine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: 
```c
dest = acos(value);
```
[c] Pseudocode: 
```c
value = acos(value);
```

**`fatan` -> Float Arctan [c]**
Computes the arctangent of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: 
```c
dest = atan(value);
```
[c] Pseudocode: 
```c
value = atan(value);
```

**`fatan2` -> Float Arctan2 [c]**
Computes the two-argument arctangent (angle in radians).
Operands: `[dest], y, x`
Pseudocode: 
```c
dest = atan2(y, x);
```
[c] Pseudocode: 
```c
y = atan2(y, x);
```

**`frtd` -> Float Radians to Degrees [c]**
Converts radians to degrees. All trigonometric instructions operate in radians.
Operands: `[dest], value`
Pseudocode: 
```c
dest = rad_to_deg(value)
```
[c] Pseudocode: 
```c
value = rad_to_deg(value);
```

**`fdtr` -> Float Degrees to Radians [c]**
Converts degrees to radians. All trigonometric instructions operate in radians.
Operands: `[dest], value`
Pseudocode: 
```c
dest = deg_to_rad(value);
```
[c] Pseudocode: 
```c
value = deg_to_rad(value);
```

