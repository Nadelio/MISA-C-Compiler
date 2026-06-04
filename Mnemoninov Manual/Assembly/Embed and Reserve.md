# Embed and Reserve

Data directives make it possible to append data to the program or reserve memory space for use at runtime. They are primarily used to define variables and other data stored in memory, like textures, strings, buffers, etc.

When placed on the same line as a label (global or local), the directive marks the label as a data label, making it possible to **inspect scalar values** in the Code Editor when the VM is paused.

---

## Embed

Appends data to the program.

**Syntax:**
```
# Note that you can precede the directive with a label.
[label:] emb <type> <value>, ...
```

**Usage examples:**
```misa
index:       emb u8t 0
float_array: emb f32t 1.0, 2.0, 3.0
```

---

## Reserve

Reserves space in the program.

**Syntax:**
```
# Note that you can precede the directive with a label.
[label:] res <type> <count>, [fill_value]
```

**Usage examples:**
```misa
buffer: res u8t 1024
foobar: res u32t 256, 0xdeadbeef
```

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
```misa
lod u8t, t0, foobar
add t0, 42
str u8t, foobar, t0
```

Incorrect use, arithmetic is performed on the address of `foobar`, not its stored value:
```misa
mov t0, foobar
add t0, 42
```
