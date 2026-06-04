# Round-Robin Scheduling

## Single-Core Multitasking with Cooperative Round-Robin Scheduling

While thinking about cooperative execution, you may start wondering how you can make responsive games when the `_input` process may be executed with a delay or the `_draw` process misses a frame, both due to other processes still running. We can reformulate this question to address the root of the issue: how can the console run multiple processes without starvation on its single-core CPU? The answer is **time-slicing**. With the cooperative execution model, your code voluntarily **yields** to share CPU time with other processes.

Both `yield` and `exit` trigger a context switch, where the kernel replaces the current CPU state with the state of the next process in the queue. While `exit` terminates the current process, `yield` places it at the end of the queue so it can resume execution later. This mechanism is a cooperative implementation of **round-robin scheduling**.

This mechanism allows you to perform large pieces of work without skipping frames or delaying input handling, simply by yielding periodically. And since the context switch is handled by the kernel, it does not require any extra work.

---

## The Watchdog

Yielding is mandatory for long-running tasks. A process is not allowed to monopolize the CPU and starve others in the queue. To enforce this, the kernel has a routine known as **Watchdog**. The Watchdog is a safety mechanism that monitors how long a process runs without yielding or exiting. If a process exceeds a defined threshold, the Watchdog raises an exception, halting execution and printing an error to the terminal.

This behavior is analogous to a real-life operating system prompting you to terminate a program when it stops responding.
