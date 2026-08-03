# Control Flow

Control flow instructions manipulate the flow of execution. They allow programs to call functions and execute structured control flows like if-else blocks and loops, implemented through jumps.

Note that labels evaluate to pc-relative addresses when used as the `address` operand in the instructions below.

---

**`nop` -> No Operation**
Performs no operation.
Operands: -
Pseudocode: -

**`cal` -> Call**
Calls a subroutine using a pc-relative address. Note that labels are pc-relative in this context.
Operands: `address`
Pseudocode:
```c
sp -= 4;
M[sp] = pc + sizeof(cal);
sp -= 4;
M[sp] = fp;
fp = sp;
pc += address;
```

**`ret` -> Return**
Returns from a subroutine.
Operands: -
Pseudocode:
```c
fp = M[sp]; sp += 4;
pc = M[sp]; sp += 4;
```

**`jmp` -> Jump**
Jumps to a pc-relative address. Note that labels are pc-relative in this context.
Operands: `address`
Pseudocode:
```c
pc += address;
```

**`jtr` -> Jump If True**
Jumps to a pc-relative address if the comparison register is set. Note that labels are pc-relative in this context.
Used in conjunction with the `cmp` instruction. See [Logic and Bitwise](./Logic%20and%20Bitwise.md).
Operands: `address`
Pseudocode: 
```c
if(cr) pc += address;
```

**`jfs` -> Jump If False**
Jumps to a pc-relative address if the comparison register is not set. Note that labels are pc-relative in this context.
Used in conjunction with the `cmp` instruction. See [Logic and Bitwise](./Logic%20and%20Bitwise.md).
Operands: `address`
Pseudocode: 
```c
if(!cr) pc += address;
```

---

# PA-Relative Variants
Program-address-relative variants of branching instructions use pa-relative instead of pc-relative addresses. They are intended for use cases where code addresses must be stored in memory or passed around, like function pointers and jump tables.

Prefer the base branching instructions when possible, as the pa-relative variants occupy more space in the bytecode.

---

**`cala` -> Call PA-Relative**
Calls a subroutine using a pa-relative address. Note that labels are pa-relative in this context.
Operands: `address`
Pseudocode:
```c
sp -= 4;
M[sp] = pc + sizeof(cala);
sp -= 4
 M[sp] = fp;
fp = sp;
pc = pa + address;
```

**`jmpa` -> Jump PA-Relative**
Jumps to a pa-relative address. Note that labels are pa-relative in this context.
Operands: `address`
Pseudocode:
```c
pc = pa + address;
```

**`jtra` -> Jump If True PA-Relative**
Jumps to a pa-relative address if the comparison register is set. Note that labels are pa-relative in this context.
Used in conjunction with the `cmp` instruction. See [Logic and Bitwise](./Logic%20and%20Bitwise.md).
Operands: `address`
Pseudocode:
```c
if(cr) pc = pa + address;
```

**`jfsa` -> Jump If False PA-Relative**
Jumps to a pa-relative address if the comparison register is not set. Note that labels are pa-relative in this context.
Used in conjunction with the `cmp` instruction. See [Logic and Bitwise](./Logic%20and%20Bitwise.md).
Operands: `address`
Pseudocode:
```c
if(!cr) pc = pa + address;
```