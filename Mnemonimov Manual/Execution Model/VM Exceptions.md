# VM Exceptions

## Runtime Error Detection
MISA's virtual machine includes an error detection system that reports when your program attempts to perform an invalid operation, for example, a division by zero.

When the VM detects an invalid operation, execution is immediately paused, and an error message describing the issue is shown in the Terminal.

# 

## Common Exceptions and Their Causes
These are some of the most common exceptions you may find, and their usual causes:
- Watchdog Violation: not yielding during long-running computations.
- Invalid Memory Access: reading or writing outside memory bounds.
- Stack Overflow: filling the call stack with infinite recursion.
- Invalid Return Address: returning with an unbalanced stack.

These examples are not exhaustive. The same exception may have other causes. Always read an exception message and inspect your code to determine the actual cause.

# 

## Unhandled VM Exceptions
The virtual machine can detect several types of invalid operations and throw appropriate exceptions. However, when execution unexpectedly reaches an invalid state, it throws an Unhandled VM Exception instead.

Unhandled VM Exceptions are uncommon and indicate that execution reached an unrecoverable state without the VM being able to report a more specific error. In these cases, execution is stopped instead of paused.

This type of exception is most often causes by data being executed as code.