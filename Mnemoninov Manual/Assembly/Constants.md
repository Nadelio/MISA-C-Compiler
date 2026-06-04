# Constants

Constant directives allow you to define and undefine assemble-time integer and float constants.

---

## Define

Defines a constant.

**Syntax:**
```
def <identifier> <expression>
```

**Usage examples:**
```misa
def MY_NUMBER 42
mov a0, MY_NUMBER
```

---

## Local Define

Defines a constant local to a global label.

**Syntax:**
```
# Note the leading dot.
def .<identifier> <expression>
```

**Usage examples:**
```misa
# Implicitly qualified within the scope of a global label 'GAME_CONSTS'.
# '.JUMP_HEIGHT' is the same as 'GAME_CONSTS.JUMP_HEIGHT'.
def DEFAULT_HEIGHT .JUMP_HEIGHT

# Explicitly qualified within the scope of another global label.
mov a0, GAME_CONSTS.JUMP_HEIGHT
```

---

## Undefine

Undefines a constant.

**Syntax:**
```
undef <identifier>
```

**Usage examples:**
```misa
undef MY_NUMBER
```
