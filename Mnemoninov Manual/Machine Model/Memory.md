# Memory

## Memory Map

Memory in MISA is laid out as follows:

```
[High memory address]
————————————————————
- Program
- Stacks (protected)
    Process Stack 0 ↓
    Process Stack 1 ↓
    Process Stack N ↓
- Back Buffer
- Reserved (protected)
————————————————————
[Low memory address]
```

---

## Protected Memory

Protected memory regions cannot be accessed by the program. If the program tries to access protected memory, the virtual machine will raise an exception and pause execution.

---

## Memory Regions

From lowest to highest memory regions:

**Reserved (Protected)**
This region is reserved for the kernel and cannot be accessed.

**Back Buffer**
The back buffer spans `SCREEN_WIDTH * SCREEN_HEIGHT` bytes. Its base address is available through the `ba` register.

**Stacks (Protected)**
MISA works with multiple stacks to support full context switch of processes. Their number and size can be configured per project. Stacks grow downward and can only be accessed by their respective processes; for other processes, a stack is protected memory.

**Program**
The bytecode emitted by the assembler. Its base address is available through the `pa` register.

---

## Relocatable Code

MISA emits relocatable code. All addresses used by programs are relative to a stable reference, such as where the program is located in memory (pa-relative), the location of the executing instruction (pc-relative), or the start of the back buffer (ba-relative). This makes programs position-independent, that is, they will run normally regardless of where they are placed in memory when the VM starts.

All memory access should be anchored to a stable reference. You must **never** rely on arbitrary hardcoded absolute addresses (for example, storing a variable at `0xffff`). This is very susceptible to breaking.

**Program Address as Anchor**
These are the recommended methods for accessing memory:
- Using labels with `lod` and `str`, as they are already pa-relative.
- Using an absolute effective address computed through `cea` (which incorporates a pa-relative base address) for use with `lde` and `ste`.

**Alternative Anchors**
Alternatively, you can also manually compute an absolute effective address `ea` for use with `lde` and `ste` with an anchor other than `pa`:
- With `ba` for accessing the back buffer relative to where it starts in memory.
- With `sp` or `fp` in advanced use cases for accessing the stack relative to the top item or the start of the current stack frame.
