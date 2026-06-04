# ABI Conventions

This page describes the application binary interface (ABI) for MISA. It covers register usage and calling conventions.

Adhering to the MISA conventions is important for writing maintainable and reusable code. The convention establishes the necessary constraints for developing code compatible across codebases, allowing you to create libraries and use libraries made by other developers.

---

## Caller-Saved and Callee-Saved

Functions must be able to preserve their registers when calling other functions, so they can resume work where they left off. This is achieved by pushing register contents to the stack, and restoring them later. The moment when this takes place, the code responsible for the preservation, and which registers are preserved, are all defined by the calling convention.

Registers are divided in two groups, caller-saved and callee-saved. Caller-saved registers, as the name implies, are registers whose responsibility of preservation lies with the calling function. Before making a call, if a function has any caller-saved registers it wishes to preserve, it must push them to the stack, then restore when the called function returns. This ensures that the registers are preserved, as there is no guarantee that the called function won't clobber them.

Callee-saved registers on the other hand, are registers that must be preserved by the called function by pushing them to the stack during the prologue (function start), and restoring them at the epilogue (function end).

---

## Register Usage

**Temporary Registers (`t*`)**
Use for working with short-lived values when performing arithmetic and logic operations. A value should be considered short-lived, or temporary, when it is merely the result of an intermediate step for computing another value, and that does not need to be preserved across function calls. Temporary registers are caller-saved.

**Argument Registers (`a*`)**
Use for passing arguments and returning values from function calls. If you need to pass or return large amounts of data, like arrays or structs, leave them in memory and pass their addresses instead. Argument registers are caller-saved.

**Saved Registers (`s*`)**
Use for holding long-lived values that must be preserved throughout the lifecycle of a function, and across function calls. Saved registers are callee-saved.

---

## Calling Conventions

**Before Calling**
- Caller must push the caller-saved registers it needs to preserve.
- Caller passes arguments to the callee using the argument registers.

**Function Prologue**
- Callee pushes all the saved registers it will use.
- If the callee is a non-leaf function (it calls other functions or invokes syscalls) it must move all arguments to saved registers, starting from `s0`. This makes it possible to reference the function's arguments until the point where it returns, without any additional work when the function itself needs to call other functions.

**Function Epilogue**
- Callee puts the return values on the argument registers.
- Callee restores the saved registers.

**After Returning**
- Caller restores the caller-saved registers.

---

## Note on Stack Usage

Using registers is the preferred workflow in MISA. But if you decide to explicitly use the stack for passing arguments and returning values, or for storing local variables, be careful when modifying the stack pointer `sp` and frame pointer `fp` registers, so as not to leave the virtual machine in an invalid state.
