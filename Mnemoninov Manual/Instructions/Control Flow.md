# Control Flow

Control flow instructions manipulate the flow of execution. They allow programs to call functions and execute structured control flows like if-else blocks and loops, implemented through jumps.

---

**`nop` → No Operation**
Performs no operation.
Operands: -
Pseudocode: -

**`cal` → Call**
Calls a subroutine using a pc-relative address.
Operands: `address`
Pseudocode:
```
sp -= 4; M[sp] = pc + sizeof(cal); pc += address;
sp -= 4; M[sp] = fp; fp = sp
```

**`ret` → Return**
Returns from a subroutine.
Operands: -
Pseudocode:
```
fp = M[sp]; sp += 4;
pc = M[sp]; sp += 4
```

**`jmp` → Jump**
Jumps to a pc-relative address.
Operands: `address`
Pseudocode: `pc += address`

**`jtr` → Jump If True**
Jumps to a pc-relative address if the comparison register is set.
Used in conjunction with the `cmp` instruction. See Logic and Bitwise.
Operands: `address`
Pseudocode: `if (cr): pc += address`

**`jfs` → Jump If False**
Jumps to a pc-relative address if the comparison register is not set.
Used in conjunction with the `cmp` instruction. See Logic and Bitwise.
Operands: `address`
Pseudocode: `if (!cr): pc += address`
