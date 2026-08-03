# Bit Manipulation

Bit manipulation instructions cover advanced bit operations. They can reverse bits, count bits, extract bits, and more.

---

**`rvb` -> Reverse Bits [c]**
Reverses the bit order of a value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = reverse_bits(value)
```
[c] Pseudocode: 
```c
value = reverse_bits(value)
```

**`ppc` -> Population Count [c]**
Counts the number of set bits in a value.
Operands: `[dest], value`
Pseudocode: 
```c
dest = count_set_bits(value)
```
[c] Pseudocode: 
```c
value = count_set_bits(value)
```

**`clz` -> Count Leading Zeros [c]**
Counts the number of leading zero bits.
Operands: `[dest], value`
Pseudocode: 
```c
dest = count_leading_zeros(value)
```
[c] Pseudocode: 
```c
value = count_leading_zeros(value)
```

**`ctz` -> Count Trailing Zeros [c]**
Counts the number of trailing zero bits.
Operands: `[dest], value`
Pseudocode: 
```c
dest = count_trailing_zeros(value)
```
[c] Pseudocode: 
```c
value = count_trailing_zeros(value)
```

**`sbx` -> Bit Field Extract (Signed)**
Extracts a bit field and sign-extends the result.
Operands: `dest, value, offset, width`
Pseudocode: 
```c
dest = s_bit_field_extract(value, offset, width)
```

**`ubx` -> Bit Field Extract (Unsigned)**
Extracts a bit field without sign extension.
Operands: `dest, value, offset, width`
Pseudocode: 
```c
dest = u_bit_field_extract(value, offset, width)
```

**`bfi` -> Bit Field Insert**
Inserts a bit field into a destination register.
Operands: `dest, source, offset, width`
Pseudocode: 
```c
dest = bit_field_insert(dest, source, offset, width)
```

**`pbx` -> Parallel Bit Extract**
Extracts bits from a value according to a mask and packs them.
Operands: `dest, value, mask`
Pseudocode: 
```c
dest = parallel_bit_extract(value, mask)
```

**`pbd` -> Parallel Bit Deposit**
Deposits bits into a register according to a mask.
Operands: `dest, value, mask`
Pseudocode: 
```c
dest = parallel_bit_deposit(value, mask)
```
