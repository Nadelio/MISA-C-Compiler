# Quick Review

**Kernel**
The kernel controls the console's execution, scheduling processes and managing context switches.

**Process**
A process is an independent flow of execution created and managed by the kernel. Each process has its own CPU state, which includes a register file and a dedicated stack.

**Built-In Process**
Special processes automatically scheduled by the kernel:
```
_start:   runs once when the VM starts.
_update:  runs at a fixed rate of 60 Hz.
_draw:    runs at a fixed rate of 60 Hz and updates the front buffer.
_input:   runs whenever the player input state changes.
```

**Entry Point**
A label in your program that marks where a process should begin execution. Entry points for built-in processes have the same name as the processes themselves.

**Exit Point**
An `exit` or `yield` instruction in your program that marks where a process should stop execution. Exit points return control to the kernel.

**Cooperative Execution**
An execution model where the kernel cannot interrupt a running process. Processes must explicitly give up control at exit points.

**Yield**
An exit point that temporarily suspends a process and puts it at the end of the process queue. Used to give up CPU time to other processes during long-running tasks.

**Exit**
An exit point that terminates a process. Required for built-in processes once their work is complete.

**Context Switch**
The operation where the kernel saves the current process state and restores another, allowing a different process to run.

**Watchdog**
A safety mechanism implemented by the kernel to prevent a process from monopolizing the CPU.
