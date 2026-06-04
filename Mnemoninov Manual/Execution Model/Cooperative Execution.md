# Cooperative Execution

## Built-In Processes and Entry Points

The built-in processes in Mnemonimov are equivalent to the built-in callbacks found in game engines. They are automatically executed by the kernel when specific events occur:

```
_start:   runs once when the VM starts.
_update:  runs at a fixed rate of 60 Hz.
_draw:    runs at a fixed rate of 60 Hz and updates the front buffer.
_input:   runs whenever the player input state changes.
```

As you can see, Mnemonimov already implements the fundamental structure to build games. You initialize the game at `_start`, run the game loop at `_update`, render your graphics to the screen at `_draw`, and handle player input at `_input`. To define the code that runs for each built-in process, you must create a label with the same name as the process. These labels act as entry points, telling the kernel where execution for each process begins.

---

## Cooperative Execution and Exit Points

Unlike modern operating systems, which use a preemptive execution model, Mnemonimov implements a **cooperative execution model**. In a preemptive system, the kernel can interrupt a running process at any time to execute another. In Mnemonimov, the kernel cannot forcibly take control while a process is executing. Instead, each process must explicitly return control to the kernel. This is done using the `exit` instruction, which marks the exit point of a process and triggers a **context switch**.

Cooperative execution simplifies reasoning about control flow, as context switches only occur at explicit locations in your code. This model resembles structured programming in high-level languages.

On the next page you will learn how the console is able to run multiple processes on its single-core CPU.
