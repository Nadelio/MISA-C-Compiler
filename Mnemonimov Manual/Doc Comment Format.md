# Auto-Generated Documentation Format

## General Standards
Documentation comments (or doc comments for short) should always be denoted by a double hashtag (`##`) instead of a single one (`#`). This helps separate standardized documentation that users should pay attention to from personal development notes that may be left behind in source code.

*This standard assumes you are following the [ABI Conventions](Platform%20Interface/ABI%20Conventions.md) guide.*

## The Header
The header of your documentation comment should be a sub-bookmark (`sbmk`) followed by a Rust-like function header that represents your function at a glance. The name of the function in the sub-bookmark ''should'' match the name of your label, but it isn't required as long as you document that there is a difference between the label name and the sub-bookmark function name.

Ex: `sbmk "malloc(size: u32t): void*"`

## The Description
Every function should have a short, concise description of what it does, this should immediately follow the header

Ex: `## Allocates a block memory equivalent to the given size in bytes and returns a pointer to the beginning of that block`

## The Parameter List
Following the description of the function should be the parameter list, starting with the line `## Parameters:`. A single parameter line should follow this format: `> <register> - <name or description of parameter>`. You can have any number of parameters in a function, just make sure that every parameter has an individual parameter line. If you do not have any parameters write `## Parameters: NONE` instead.

Ex:
```asm
## Parameters:
## > a0 - Size of block of memory in bytes, is a u32t
```

## The Return Value List
Similarly to the parameter list, every function should have a list of values that are "returned" by it. They follow a similar format to the parameter list as well, except instead of a `>` at the beginning of each line, it is a `<` at the beginning, and you write `## Returns:` instead of `## Parameters:`.

Ex:
```asm
## Returns:
## < a0 - A pointer to the beginning of the allocated block of memory, is a u32t
```

## Additional Implementation Notes
Finally, the last section of the documentation is reserved for any additional notes or behaviors that are not covered by the above sections. These could be things like saved registers, the state of the stack, any changes to persistent storage, heap memory, or frame buffer(s).

Ex:
```
## Additional Implementation Notes:
## s0 - saved a0
## s1 - block candidate header
```
----
## Full Example
```asm
sbmk "malloc(size: u32t): void*"
## Allocates a block memory equivalent to the given size in bytes and returns a pointer to the beginning of that block
## Parameters:
## > a0 - Size of block of memory in bytes, is a u32t
## Returns:
## < a0 - A pointer to the beginning of the allocated block of memory, is a u32t
## Additional Implementation Notes:
## s0 - saved a0
## s1 - block candidate header
malloc:
  ...
```
