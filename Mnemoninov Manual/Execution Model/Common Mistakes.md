# Common Mistakes

**Symptom:** a process executes code from another process, or an exception about an invalid opcode is being triggered.
**Cause:** the process never reaches an exit point and continues executing whatever comes next in memory.
**Solution:** add an `exit` instruction so the process knows where execution must stop.

**Symptom:** `_update`, `_draw`, or `_input` stops running at the expected rate.
**Cause:** a built-in process is being indefinitely yielded instead of terminated.
**Solution:** always `exit` built-in processes once their work is complete, allowing the kernel to schedule them again at the correct time.

**Symptom:** input lag, missed frames, or watchdog exceptions.
**Cause:** performing long-running work without yielding.
**Solution:** `yield` periodically during long computations to allow other processes to run.

**Symptom:** values previously stored in registers are no longer present.
**Cause:** registers were used to preserve data across execution of a built-in process, or to pass data between processes.
**Solution:** use memory to persist data across process executions and for inter-process communication. Each process has its own private register file, which is discarded when the process terminates.
