# Lifecycle and Communication

## Lifecycle of Built-In Processes

Yielding is not a replacement for `exit` in built-in processes. The kernel automatically schedules each built-in process when appropriate, but it will not schedule duplicate instances. If a built-in process does not exit after completing its work, and remains alive by yielding, it won't be executed at the intended times (at 60 Hz for `_update` and `_draw`, and at input state changes for `_input`).

The only exception to the rule is the `_start` process. Since it is only scheduled once, there are no problems with keeping it alive for other purposes. For example, instead of overloading your `_update` process with an occasional but intensive routine, like map generation, you can delegate this task to the `_start` process. This way, you keep the `_update` process lightweight and without the need for yielding.

---

## Inter-Process Communication

Processes are not aware of each other's existence. From a process's perspective, a `yield` has no observable effect, as its registers and stack remain unchanged. Because each process has its own private CPU state, all inter-process communication is done through shared memory.

Building on the previous example, the `_update` process can write a value to memory indicating that the player has entered a new level. When the `_start` process later runs, it can read the same value and begin generating a new map.

The cooperative execution model makes synchronization simple as you are in full control of when each process can write to and read from shared memory.
