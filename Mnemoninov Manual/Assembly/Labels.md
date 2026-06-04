# Labels

Label directives enable you to create aliases for **pa-relative¹ addresses** that you can reference in your code. Labels are classified into two use cases: data label, when used to reference a segment of data, and code block label, when used to reference functions and other code locations. MISA implements three types of labels: (global) label, local label, and reusable label.

All labels support forward referencing. This means they can be referenced on lines that come before their definition.

¹ MISA uses relative rather than absolute addressing. See the *Relocatable Code* section on the Memory page for details.

---

## Label

Defines a global label.

**Syntax:**
```
<identifier>:
```

**Usage examples:**
```misa
# 'message' is the pa-relative address of a string.
mov a0, message

# 'my_func' is the pa-relative address of a function.
cal my_func
```

---

## Local Label

Defines a label local to a global label.

**Syntax:**
```
# Note the leading dot.
.<identifier>:
```

**Usage examples:**
```misa
# Implicitly qualified within the scope of a global label 'foo'.
# '.bar' is the same as 'foo.bar'.
mov a0, .bar

# Explicitly qualified within the scope of another global label.
mov a0, foo.bar
```

---

## Reusable Label

Defines labels that can be redefined.

**Syntax:**
```
@<identifier>:
```

**Usage examples:**
```misa
# The backward operator '-' tells the assembler to match the
# first instance of the '@start' label found in the lines above.
jmp @start-

# The forward operator '+' tells the assembler to match the
# first instance of the '@end' label found in the lines below.
jmp @end+
```

---

## Common Mistakes

If you are unable to forward-reference a label, you might be mistaking a constant (defined with the constant directive) for a label. Constants must be defined before use.
