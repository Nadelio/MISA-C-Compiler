# Types and Files

## Types

Types for data directives and load/store instructions:

| Type | Description | Notes |
|------|-------------|-------|
| `i8t` | Signed 8-bit integer | |
| `u8t` | Unsigned 8-bit integer | |
| `i16t` | Signed 16-bit integer | |
| `u16t` | Unsigned 16-bit integer | |
| `i32t` | Signed 32-bit integer | |
| `u32t` | Unsigned 32-bit integer | |
| `f32t` | 32-bit float | |
| `string` | Null-terminated ASCII string | Embed-only |
| `file` | `.png` or `.bin` file | Embed-only |

Note that non-scalar[^1] types, like `string` and `file`, can only be used in the `emb` directive.

[^1]: Scalar types represent a single value, like an integer or a float. Non-scalar types represent multiple values, like a string or a file, which are collections of bytes.

---

## Relative and Absolute Paths

When embedding a file or using the `include` directive, you must provide a path. Always use **relative paths** when possible, as they will not break when projects are opened on other computers; for example, when you want to move your creations from your Windows desktop to your Linux laptop, or share them with others.

A relative path assumes the project directory as its root, so it provides the remaining path to the file (for example, `assets/spritesheet.png`). An absolute path, however, specifies the full path from the file system root (for example, `C:\Users\Username\AppData\Roaming\...` or `/home/username/.local/share/...`), which is verbose and fragile. Keep in mind that relative paths can also be used to reference files outside the project directory.

---

## Virtual Folders and Paths

In addition to relative and absolute paths, MISA supports virtual paths for referencing files from other projects. A virtual path is rooted in a virtual folder, which is automatically resolved to an actual directory managed by the console.

Available virtual folders:

- `@u/` → the user projects directory.
- `@s/` → the sample projects directory.

Usage examples:

```asm
# Including code from a user project.
include "@u/some_library/main.asm"

# Embedding a texture from a sample project.
emb file "@s/lander/assets/lander_spritesheet.png"
```

---

## Embedding Files

When working with the `file` type, you must provide a path to a `.png` or `.bin` file. The embedded `.png` files are converted into luma textures, while `.bin` files are loaded as is. When authoring binary files, remember that MISA uses **big-endian** byte order.
