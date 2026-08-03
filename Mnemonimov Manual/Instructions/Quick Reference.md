# Quick Reference

## Cheat Sheet
Below you can find a quick reference for all MISA instructions, grouped by category.

---

## Control Flow
| Mnemonic | Name                 | Operands     |
|----------|----------------------|--------------|
| nop      | No Operation         | -            |
| cal      | Call                 | (pc) address |
| ret      | Return               | -            |
| jmp      | Jump                 | (pc) address |
| jtr      | Jump If True         | (pc) address |
| jfs      | Jump If False        | (pc) address |
|----------|----------------------|--------------|
| cala     | Call PA-Rel          | (pa) address |
| jmpa     | Jump PA-Rel          | (pa) address |
| jtra     | Jump If True PA-Rel  | (pa) address |
| jfsa     | Jump If False PA-Rel | (pa) address |

## System
| Mnemonic | Name        | Operands |
|----------|-------------|----------|
| syscall  | System Call | Syscall  |
| break    | Break       | -        |
| yield    | Yield       | -        |
| exit     | Exit        | -        |

## Data Transfer
| Mnemonic | Name                | Operands                        |
|----------|---------------------|---------------------------------|
| lod      | Load                | Type, dest, (pa) address        |
| str      | Store               | Type, (pa) address, value       |
| cea      | Compute E. Address  | (pa) base_address, index, scale |
| lde      | Load Effective      | Type, dest, displacement        |
| ste      | Store Effective     | Type displacement, value        |
| tpr      | To Program Relative | [dest], address                 |
| tpa      | To Program Absolute | [dest], (pa) address            |
| psh      | Push                | value                           |
| pop      | Pop                 | dest                            |
| mov      | Move                | dest, source                    |
| mvc      | Move Conditional    | dest, source                    |
| sel      | Select              | dest, true_value, false_value   |
| swp      | Swap                | a, b                            |

## Arithmetic
| Mnemonic | Name                | Operands                  |
|----------|---------------------|---------------------------|
| add      | Add                 | [dest], a, b              |
| sub      | Subtract            | [dest], a, b              |
| inc      | Increment           | dest                      |
| dec      | Decrement           | dest                      |
| mul      | Multiply            | [dest], a, b              |
| mlh      | Multiply High       | [dest], a, b              |
| fma      | Fused Multiply-Add  | [dest], a, b, c           |
| pow      | Power               | [dest], base, exponent    |
| div      | Divide              | [dest], dividend, divisor |
| rem      | Remainder           | [dest], dividend, divisor |
| mod      | Modulo              | [dest], dividend, divisor |
| neg      | Negate              | [dest], value             |
| abs      | Absolute            | [dest], value             |
| sgn      | Sign                | [dest], value             |
| min      | Minimum             | [dest], a, b              |
| max      | Maximum             | [dest], a, b              |
| clp      | Clamp               | [dest], value, min, max   |
| rnd      | Random              | dest, min, max            |
|----------|---------------------|---------------------------|
| mlhu     | Multiply High (U)   | [dest], a, b              |
| divu     | Divide (U)          | [dest], dividend, divisor |
| remu     | Remainder (U)       | [dest], dividend, divisor |
| minu     | Minimum (U)         | [dest], a, b              |
| maxu     | Maximum (U)         | [dest], a, b              |
| clpu     | Clamp (U)           | [dest], value, min, max   |

## Logic and Bitwise
| Mnemonic | Name                | Operands             |
|----------|---------------------|----------------------|
| cmp      | Compare             | Condition, a, b      |
| not      | Not                 | [dest], value        |
| and      | And                 | [dest], a, b         |
| orr      | Or                  | [dest], a, b         |
| xor      | Xor                 | [dest], a, b         |
| sar      | Shift Arith. Right  | [dest], value, shift |
| sll      | Shift Logical Left  | [dest], value, shift |
| slr      | Shift Logical Right | [dest], value, shift |
| rol      | Rotate Left         | [dest], value, shift |
| ror      | Rotate Right        | [dest], value, shift |

## Bit Manipulation
| Mnemonic | Name                  | Operands                    |
|----------|-----------------------|-----------------------------|
| rvb      | Reverse Bits          | [dest], value               |
| ppc      | Population Count      | [dest], value               |
| clz      | Count Leading Zeros   | [dest], value               |
| ctz      | Count Trailing Zeros  | [dest], value               |
| sbx      | Bit Field Extract (S) | dest, value, offset, width  |
| ubx      | Bit Field Extract (U) | dest, value, offset, width  |
| bfi      | Bit Field Insert      | dest, source, offset, width |
| pbx      | Parallel Bit Extract  | dest, value, mask           |
| pbd      | Parallel Bit Deposit  | dest, value, mask           |

## Floating-Point
| Mnemonic | Name                   | Operands                  |
|----------|------------------------|---------------------------|
| fcti     | Flt Convert Flt to Int | [dest], value             |
| fctf     | Flt Convert Int to Flt | [dest], value             |
|----------|------------------------|---------------------------|
| fadd     | Flt Add                | [dest], a, b              |
| fsub     | Flt Sub                | [dest], a, b              |
| fmul     | Flt Multiply           | [dest], a, b              |
| ffma     | Flt Fused Multiply-Add | [dest], a, b, c           |
| fdiv     | Flt Divide             | [dest], dividend, divisor |
| frem     | Flt Remainder          | [dest], dividend, divisor |
| fmod     | Flt Modulo             | [dest], dividend, divisor |
| fpow     | Flt Power              | [dest], base, exponent    |
| fsqrt    | Flt Square Root        | [dest], value             |
| frsqrt   | Flt Reciprocal Sqrt    | [dest], value             |
| fexp     | Flt Exp Function       | [dest], value             |
| flog     | Flt Natural Log        | [dest], value             |
|----------|------------------------|---------------------------|
| fneg     | Flt Negate             | [dest], value             |
| fabs     | Flt Absolute           | [dest], value             |
| fsgn     | Flt Sign               | [dest], value             |
| fmin     | Flt Minimum            | [dest], a, b              |
| fmax     | Flt Maximum            | [dest], a, b              |
| fclp     | Flt Clamp              | [dest], value, min, max   |
| fwrp     | Flt Wrap               | [dest], value, min, max   |
| flrp     | Flt Linear Interp.     | dest, a, b, t             |
| frnd     | Flt Random             | dest, min, max            |
|----------|------------------------|---------------------------|
| fflo     | Flt Floor              | [dest], value             |
| fcei     | Flt Ceiling            | [dest], value             |
| frou     | Flt Round              | [dest], value             |
| ftru     | Flt Truncate           | [dest], value             |
| ffra     | Flt Fractional         | [dest], value             |
|----------|------------------------|---------------------------|
| fsin     | Flt Sin                | [dest], value             |
| fcos     | Flt Cosine             | [dest], value             |
| ftan     | Flt Tangent            | [dest], value             |
| fasin    | Flt Arcsin             | [dest], value             |
| facos    | Flt Arccos             | [dest], value             |
| fatan    | Flt Arctan             | [dest], value             |
| fatan2   | Flt Arctan2            | [dest], y, x              |
| frtd     | Flt Rad to Deg         | [dest], value             |
| fdtr     | Flt Deg to Rad         | [dest], value             |

## Drawing
| Mnemonic | Name                  | Operands                |
|----------|-----------------------|-------------------------|
| gbpx     | Get Back Buffer Pixel | dest, x, y              |
| sbpx     | Set Back Buffer Pixel | x, y, luma              |
| gtpx     | Get Texture Pixel     | dest, (pa)address, x, y |
| stpx     | Set Texture Pixel     | (pa)address, x, y, luma |
| norm     | Normalize             | [dest], value           |
| dnrm     | Denormalize           | [dest], value           |

## Vector
| Mnemonic | Name                  | Operands                          |
|----------|-----------------------|-----------------------------------|
| vpsh     | Vec Push              | register_range                    |
| vpop     | Vec Pop               | register_range                    |
| vmov     | Vec Move              | dest_range, source_start          |
| vfadd    | Vec Flt Add           | [dest], a_start, b_start          |
| vfsub    | Vec Flt Sub           | [dest], a_start, b_start          |
| vfmul    | Vec Flt Multiply      | [dest], a_start, b_start          |
| vffma    | Vec Flt Fused Mul-Add | [dest], a_start, b_start, c_start |
| vfdiv    | Vec Flt Divide        | [dest], a_start, b_start          |