# Data Transfer

Data transfer instructions handle the flow of data. They can move values between registers and/or memory.

---

**`lod` → Load**
Loads a value from memory using a pa-relative `address`, which is normally a label.
Operands: `Type, dest, address`
Pseudocode: `dest = M[pa + address][N:0]`

**`str` → Store**
Stores a value to memory using a pa-relative `address`, which is normally a label.
Operands: `Type, address, value`
Pseudocode: `M[pa + address][N:0] = value[N:0]`

**`cea` → Compute Effective Address**
Computes an absolute effective address `ea` anchored to a pa-relative `base_address`.
Used in conjunction with `lde` and `ste` instructions.
Operands: `base_address, index, scale`
Pseudocode: `ea = (pa + base_address) + (index * scale)`

**`lde` → Load Effective**
Loads a value from memory using the absolute effective address `ea` offset by `displacement`.
Operands: `Type, dest, displacement`
Pseudocode: `dest = M[ea + displacement][N:0]`

**`ste` → Store Effective**
Stores a value to memory using the absolute effective address `ea` offset by `displacement`.
Operands: `Type, displacement, value`
Pseudocode: `M[ea + displacement][N:0] = value[N:0]`

**`tpr` → To Program Relative [c]**
Converts an absolute address to a pa-relative address.
Operands: `[dest], address`
Pseudocode: `dest = address - pa`
[c] Pseudocode: `address -= pa`

**`tpa` → To Program Absolute [c]**
Converts a pa-relative address to an absolute address.
Operands: `[dest], address`
Pseudocode: `dest = address + pa`
[c] Pseudocode: `address += pa`

**`psh` → Push**
Pushes a value onto the stack.
Operands: `value`
Pseudocode: `sp -= 4; M[sp] = value`

**`pop` → Pop**
Pops a value from the stack.
Operands: `dest`
Pseudocode: `dest = M[sp]; sp += 4`

**`mov` → Move**
Copies a value from one register to another.
Operands: `dest, source`
Pseudocode: `dest = source`

**`mvc` → Move Conditional**
Copies a value if the comparison register is set.
Used in conjunction with the `cmp` instruction. See Logic and Bitwise.
Operands: `dest, source`
Pseudocode: `if (cr): dest = source`

**`sel` → Select**
Selects between two values based on the comparison register's state.
Used in conjunction with the `cmp` instruction. See Logic and Bitwise.
Operands: `dest, true_value, false_value`
Pseudocode: `dest = (cr) ? true_value : false_value`

**`swp` → Swap**
Swaps the contents of two registers.
Operands: `a, b`
Pseudocode: `swap(a, b)`
