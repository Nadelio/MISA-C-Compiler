# Data Transfer

Data transfer instructions handle the flow of data. They can move values between registers and/or memory.

---

**`lod` -> Load**
Loads a value from memory using a pa-relative `address`, which is normally a label.
Accepts only scalar `Type` operands. See [Types and Files](../Assembly/Types%20and%20Files.md).
Operands: `Type, dest, address`
Pseudocode: 
```c
dest = M[pa + address][N:0];
```

**`str` -> Store**
Stores a value to memory using a pa-relative `address`, which is normally a label.
Accepts only scalar `Type` operands. See [Types and Files](../Assembly/Types%20and%20Files.md).
Operands: `Type, address, value`
Pseudocode: 
```c
M[pa + address][N:0] = value[N:0];
```

**`cea` -> Compute Effective Address**
Computes an absolute effective address `ea` anchored to a pa-relative `base_address`.
Used in conjunction with `lde` and `ste` instructions.
Operands: `base_address, index, scale`
Pseudocode: 
```c
ea = (pa + base_address) + (index * scale);
```

**`lde` -> Load Effective**
Loads a value from memory using the absolute effective address `ea` offset by `displacement`.
Accepts only scalar `Type` operands. See [Types and Files](../Assembly/Types%20and%20Files.md).
Operands: `Type, dest, displacement`
Pseudocode: 
```c
dest = M[ea + displacement][N:0];
```

**`ste` -> Store Effective**
Stores a value to memory using the absolute effective address `ea` offset by `displacement`.
Accepts only scalar `Type` operands. See [Types and Files](../Assembly/Types%20and%20Files.md).
Operands: `Type, displacement, value`
Pseudocode: 
```c
M[ea + displacement][N:0] = value[N:0];
```

**`tpr` -> To Program Relative [c]**
Converts an absolute address to a pa-relative address.
Operands: `[dest], address`
Pseudocode: `dest = address - pa`
[c] Pseudocode: 
```c
address -= pa;
```

**`tpa` -> To Program Absolute [c]**
Converts a pa-relative address to an absolute address.
Operands: `[dest], address`
Pseudocode: `dest = address + pa`
[c] Pseudocode: 
```c
address += pa;
```

**`psh` -> Push**
Pushes a value onto the stack. Use the vector instruction `vpsh` for pushing multiple registers at once. See [Vector](./Vector.md).
Operands: `value`
Pseudocode: 
```c
sp -= 4;
M[sp] = value;
```

**`pop` -> Pop**
Pops a value from the stack. Use the vector instruction `vpop` for popping multiple registers at once. See [Vector](./Vector.md).
Operands: `dest`
Pseudocode: 
```c
dest = M[sp];
sp += 4;
```

**`mov` -> Move**
Copies a value from one register to another. Use the vector instruction `vmov` for copying multiple registers at once. See [Vector](./Vector.md).
Operands: `dest, source`
Pseudocode: 
```c
dest = source;
```

**`mvc` -> Move Conditional**
Copies a value if the comparison register is set.
Used in conjunction with the `cmp` instruction. See [Logic and Bitwise](./Logic%20and%20Bitwise.md).
Operands: `dest, source`
Pseudocode:
```c
if(cr) dest = source;
```

**`sel` -> Select**
Selects between two values based on the comparison register's state.
Used in conjunction with the `cmp` instruction. See [Logic and Bitwise](./Logic%20and%20Bitwise.md).
Operands: `dest, true_value, false_value`
Pseudocode: 
```c
dest = (cr) ? true_value : false_value;
```

**`swp` -> Swap**
Swaps the contents of two registers.
Operands: `a, b`
Pseudocode: 
```c
swap(a, b);
```
