# Registers

MISA strongly leans toward register-to-register operations, so there is a large set of general-purpose registers to keep pressure low. They are documented below, along with the special-purpose registers.

Note that all registers are 32-bit and can be used for floating-point operations.

---

## General-Purpose Registers

General-purpose registers are registers intended for use as the primary workspace for logical and arithmetic operations. They are grouped in three categories: temporary, argument, and saved.

The difference between categories is only semantical, without any actual changes in functionality. Categories exist as a convention for writing maintainable and reusable code. You can read more about MISA's conventions in the ABI Conventions page.

| Register | Description |
|----------|-------------|
| `t0-t15` | Temporary   |
| `a0-a15` | Argument    |
| `s0-s31` | Saved       |

---

## Special-Purpose Registers

Special-purpose registers are registers associated with special behavior. Most of them are managed by the virtual machine or used by specific instructions, and should not be manually accessed under normal conditions. After the table of registers, you will find a reference describing their behavior.

| Register | Description                    |
|----------|--------------------------------|
| `zr`     | Zero (constant)                |
| `cr`     | Comparison Result              |
| `ea`     | Effective Address              |
| `pa`     | Program Address (read-only)    |
| `ba`     | Back Buffer Address (read-only)|
| `sp`     | Stack Pointer                  |
| `fp`     | Frame Pointer                  |
| `pc`     | Program Counter                |

---

## Basic Special-Purpose Registers

Basic special-purpose registers are safe for access because they are either read-only or are meant to be manually set in advanced use cases.

**`zr` → Zero (constant)**
Retains a constant value of `0`. Writing to this register has no effect.

**`cr` → Comparison Result**
Used by the conditional jump instructions `jfs` and `jtr`. Meant to be indirectly set using the `cmp` instruction, but can be set manually if needed.

**`ea` → Effective Address**
An absolute address used to access memory with `lde` and `ste` instructions. Meant to be indirectly set using the `cea` instruction.

**`pa` → Program Address (read-only)**
A read-only absolute address pointing to the start of the program in memory. Automatically set by the virtual machine on startup.

**`ba` → Back Buffer Address (read-only)**
A read-only absolute address pointing to the start of the back buffer in memory. Automatically set by the virtual machine on startup.

---

## Advanced Special-Purpose Registers

Advanced special-purpose registers are not safe for access as incorrect usage can easily put the virtual machine in an invalid state. They are managed by the virtual machine and should only be manually set by experienced users.

**`sp` → Stack Pointer**
An absolute address pointing to the top item of the active process's stack. Managed by operations that interface with the stack, like calling and returning from subroutines, or pushing and popping values.

**`fp` → Frame Pointer**
An absolute address pointing to the base of the stack frame. Managed by call/return operations, and used for debugging purposes, including step debugging and unwinding the stack trace.

**`pc` → Program Counter**
An absolute address pointing to the executing instruction. Managed by the virtual machine.
