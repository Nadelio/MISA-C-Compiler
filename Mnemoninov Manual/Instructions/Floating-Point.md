# Floating-Point

Floating point instructions perform mathematical operations on floats. They include both fundamental and utility operations, like trigonometric functions.

---

**`fcti` → Float Convert Float to Int [c]**
Converts a floating-point value to an integer.
Operands: `[dest], value`
Pseudocode: `dest = (int)value`
[c] Pseudocode: `value = (int)value`

**`fctf` → Float Convert Int to Float [c]**
Converts an integer value to floating-point.
Operands: `[dest], value`
Pseudocode: `dest = (float)value`
[c] Pseudocode: `value = (float)value`

**`fadd` → Float Add [c]**
Adds two float values.
Operands: `[dest], a, b`
Pseudocode: `dest = a + b`
[c] Pseudocode: `a += b`

**`fsub` → Float Subtract [c]**
Subtracts one float value from another.
Operands: `[dest], a, b`
Pseudocode: `dest = a - b`
[c] Pseudocode: `a -= b`

**`fmul` → Float Multiply [c]**
Multiplies two float values.
Operands: `[dest], a, b`
Pseudocode: `dest = a * b`
[c] Pseudocode: `a *= b`

**`ffma` → Float Fused Multiply-Add [c]**
Performs a fused multiply-add operation.
Operands: `[dest], a, b, c`
Pseudocode: `dest = a * b + c`
[c] Pseudocode: `a = a * b + c`

**`fpow` → Float Power [c]**
Raises one float value to the power of another.
Operands: `[dest], base, exponent`
Pseudocode: `dest = base ** exponent`
[c] Pseudocode: `base **= exponent`

**`fdiv` → Float Divide [c]**
Divides one float value by another.
Operands: `[dest], dividend, divisor`
Pseudocode: `dest = dividend / divisor`
[c] Pseudocode: `dividend /= divisor`

**`frem` → Float Remainder [c]**
Computes the remainder of a division, preserving the dividend's sign.
Operands: `[dest], dividend, divisor`
Pseudocode: `dest = dividend % divisor`
[c] Pseudocode: `dividend %= divisor`

**`fmod` → Float Modulo [c]**
Computes the modulo of a division, preserving the divisor's sign.
Operands: `[dest], dividend, divisor`
Pseudocode: `dest = dividend %% divisor`
[c] Pseudocode: `dividend %%= divisor`

**`fwrp` → Float Wrap [c]**
Wraps a float value within a specified range.
Operands: `[dest], value, min, max`
Pseudocode: `dest = wrap(value, min, max)`
[c] Pseudocode: `value = wrap(value, min, max)`

**`fneg` → Float Negate [c]**
Negates a float value.
Operands: `[dest], value`
Pseudocode: `dest = -value`
[c] Pseudocode: `value = -value`

**`fabs` → Float Absolute [c]**
Computes the absolute float value.
Operands: `[dest], value`
Pseudocode: `dest = abs(value)`
[c] Pseudocode: `value = abs(value)`

**`fsgn` → Float Sign [c]**
Computes the sign of a float value.
Operands: `[dest], value`
Pseudocode: `dest = sign(value)`
[c] Pseudocode: `value = sign(value)`

**`fmin` → Float Minimum [c]**
Selects the smaller of two float values.
Operands: `[dest], a, b`
Pseudocode: `dest = min(a, b)`
[c] Pseudocode: `a = min(a, b)`

**`fmax` → Float Maximum [c]**
Selects the larger of two float values.
Operands: `[dest], a, b`
Pseudocode: `dest = max(a, b)`
[c] Pseudocode: `a = max(a, b)`

**`fclp` → Float Clamp [c]**
Clamps a float value to the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `[dest], value, min, max`
Pseudocode: `dest = clamp(value, min, max)`
[c] Pseudocode: `value = clamp(value, min, max)`

**`frnd` → Float Random**
Generates a pseudo-random float value in the range `[min, max]`. If `max < min`, the operands are swapped.
Operands: `dest, min, max`
Pseudocode: `dest = rand_range(min, max)`

**`fsqrt` → Float Square Root [c]**
Computes the square root of a float value.
Operands: `[dest], value`
Pseudocode: `dest = sqrt(value)`
[c] Pseudocode: `value = sqrt(value)`

**`frsqrt` → Float Reciprocal Square Root [c]**
Computes the reciprocal of the square root.
Operands: `[dest], value`
Pseudocode: `dest = 1.0 / sqrt(value)`
[c] Pseudocode: `value = 1.0 / sqrt(value)`

**`fflo` → Float Floor [c]**
Floors a float value (the result remains a float).
Operands: `[dest], value`
Pseudocode: `dest = floor(value)`
[c] Pseudocode: `value = floor(value)`

**`fcei` → Float Ceiling [c]**
Ceils a float value (the result remains a float).
Operands: `[dest], value`
Pseudocode: `dest = ceil(value)`
[c] Pseudocode: `value = ceil(value)`

**`frou` → Float Round [c]**
Rounds a float value using round-half-to-even (the result remains a float).
Operands: `[dest], value`
Pseudocode: `dest = round(value)`
[c] Pseudocode: `value = round(value)`

**`ftru` → Float Truncate [c]**
Truncates the fractional part of a float value, rounding it toward zero (the result remains a float).
Operands: `[dest], value`
Pseudocode: `dest = trunc(value)`
[c] Pseudocode: `value = trunc(value)`

**`ffra` → Float Fractional [c]**
Extracts the fractional part of a float value.
Operands: `[dest], value`
Pseudocode: `dest = fract(value)`
[c] Pseudocode: `value = fract(value)`

**`fsin` → Float Sine [c]**
Computes the sine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: `dest = sin(value)`
[c] Pseudocode: `value = sin(value)`

**`fcos` → Float Cosine [c]**
Computes the cosine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: `dest = cos(value)`
[c] Pseudocode: `value = cos(value)`

**`ftan` → Float Tangent [c]**
Computes the tangent of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: `dest = tan(value)`
[c] Pseudocode: `value = tan(value)`

**`fasin` → Float Arcsin [c]**
Computes the arcsine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: `dest = asin(value)`
[c] Pseudocode: `value = asin(value)`

**`facos` → Float Arccos [c]**
Computes the arccosine of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: `dest = acos(value)`
[c] Pseudocode: `value = acos(value)`

**`fatan` → Float Arctan [c]**
Computes the arctangent of a float value (angle in radians).
Operands: `[dest], value`
Pseudocode: `dest = atan(value)`
[c] Pseudocode: `value = atan(value)`

**`fatan2` → Float Arctan2 [c]**
Computes the two-argument arctangent (angle in radians).
Operands: `[dest], y, x`
Pseudocode: `dest = atan2(y, x)`
[c] Pseudocode: `y = atan2(y, x)`

**`frtd` → Float Radians to Degrees [c]**
Converts radians to degrees. All trigonometric instructions operate in radians.
Operands: `[dest], value`
Pseudocode: `dest = rad_to_deg(value)`
[c] Pseudocode: `value = rad_to_deg(value)`

**`fdtr` → Float Degrees to Radians [c]**
Converts degrees to radians. All trigonometric instructions operate in radians.
Operands: `[dest], value`
Pseudocode: `dest = deg_to_rad(value)`
[c] Pseudocode: `value = deg_to_rad(value)`

**`flog` → Float Natural Log [c]**
Computes the natural logarithm.
Operands: `[dest], value`
Pseudocode: `dest = log(value)`
[c] Pseudocode: `value = log(value)`

**`fexp` → Float Exponential Function [c]**
Computes the exponential function.
Operands: `[dest], value`
Pseudocode: `dest = exp(value)`
[c] Pseudocode: `value = exp(value)`

**`flrp` → Float Linear Interpolation**
Performs linear interpolation between two float values.
Operands: `dest, a, b, t`
Pseudocode: `dest = lerp(a, b, t)`
