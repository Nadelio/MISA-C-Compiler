# Kernel and Processes

## The Game Loop

In Mnemonimov, you write games and other programs in assembly, but that does not mean you must implement even basic control flow structures, like a game loop, from scratch.

A game loop is the basic control flow structure used in games. It runs at a fixed time interval or tied to the framerate, and it is where the main logic for a game executes, including things like processing player input, updating states, moving entities, and so on. In most game engines, the game loop is exposed through a callback usually named `update()`, which the engine automatically calls.

Mnemonimov operates at a much lower level than a game engine, but it provides an equivalent control flow structure. Instead of callbacks, the console exposes **built-in processes**, managed by a **kernel**, which define when and how different parts of your program execute.

---

## Kernel and Processes

In Mnemonimov, the kernel has the authority over the control flow. For simplicity, you can think of the kernel as a small operating system that controls the virtual machine's resources. Your assembly code is executed as one or more processes created and managed by the kernel.

A process is an independent flow of control. Each process has its own CPU state, including a private register file and a dedicated stack. The kernel switches between processes by saving and restoring this state. We could also refer to the kernel as a scheduler or dispatcher.
