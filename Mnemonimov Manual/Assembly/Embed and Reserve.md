# Embed and Reserve

Data directives make it possible to append data to the program or reserve memory space for use at runtime. They are primarily used to define variables and other data stored in memory, like textures, strings, buffers, etc.

When placed on the same line as a label (global or local), the directive marks the label as a data label, making it possible to **inspect scalar values** in the Code Editor when the VM is paused.

Your program can access the variables you defined with `emb` and `res` through load and store instructions, using their labels as the address operand. You can also pass variables to system calls that take an address as an argument.

---

## Embed

Embed is meant for defining variables with initialized values. It is a directive that tells the assembler to append some specified data to the bytecode alongside the rest of your program.

**Syntax:**
```
# Note that you can precede the directive with a label.
[label:] emb <type> <value>, ...
```

**Usage examples:**
```
position_x: emb i8t 0
position_y: emb i8t 0
float_array: emb f32t 1.0, 2.0, 3.0
message: emb string "Hello, World!"
texture: emb file "sprite.png"
```

---

## Reserve

Reserve is meant for defining variables with uninitialized[^1] values. It is a directive that tells the assembler to leave some specified amount of space in the bytecode alongside the rest of your program.

The reserved space can be optionally prefilled with a specified value.

**Syntax:**
```
# Note that you can precede the directive with a label.
[label:] res <type> <count>, [fill_value]
```

**Usage examples:**
```
byte_array: res u8t 1024
int_array: res i32t 1024
prefilled_array: res u32t 256, 0xdeadbeef
```

See [Types and Files](./Types%20and%20Files.md) for a reference of the types supported. Note that non-scalar types, like `string` and `file`, can only be used in the `emb` directive.

[^1]: Reserved space can optionally be initialized with a fill value. In practice, *reserve* is primarily intended for pre-allocating chunks of memory for use at runtime.

---

## Data Labels and Debug Inspection

When `emb` or `res` is placed **on the same line** as a global or local label, that label becomes a data label. Data labels can be inspected in the Code Editor when the VM is paused.

To inspect a value, click a data label while the VM is paused, and the inspector will display its contents. You can also inspect registers.

Only scalar values can be inspected. A value is non-scalar when:
- `emb` defines multiple values (e.g. `emb u8t 1, 2, 3`).
- `res` reserves more than one element.

Non-scalar values are displayed as `[...]`.

---

## Common Mistakes

Do not forget to dereference data labels using load and store instructions in order to access their actual value in memory. Otherwise, you will be doing computation on an address, which is most likely not what you intended.

Correct use, data label `foobar` is dereferenced:
```
lod u8t, t0, foobar
add t0, 42
str u8t, foobar, t0
```

Incorrect use, arithmetic is performed on the address of `foobar`, not its stored value:
```
mov t0, foobar
add t0, 42
```
