# System

System instructions interface with the kernel. They can invoke syscalls, pause the VM for debugging, or give up execution.

---

**`syscall` → System Call**
Invokes a system call identified by the syscall operand.
Operands: `Syscall`
Pseudocode: `invoke_system_call(Syscall)`

**`break` → Break**
Transfers control to the debugger.
Operands: -
Pseudocode: `debug_break()`

**`yield` → Yield**
Suspends execution and puts the active process at the end of the process queue, returning control to the kernel. Used to share CPU time with other processes during long-running tasks.
Operands: -
Pseudocode: `yield_process()`

**`exit` → Exit**
Stops execution and terminates the active process, returning control to the kernel. Required for built-in processes once their work is complete.
Operands: -
Pseudocode: `exit_process()`
