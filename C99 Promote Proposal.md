# C99 Promotion Proposal

I'm thinking about moving the standard up from C89 to C99 so I get a chance to use the `inline` keyword and `<stdbool.h>` header. I already have a weird mix of C89 and C99 standards since I have things like `for(int i = 0; i < 10; i++)` as valid `for` loop header syntax and single line comments. It would also add a bunch of other random things like `long long` ints, which aren't really possible or necessary since MISA doesn't have 128-bit integer support.

`restrict` pointers would be nice, I just don't really know how I would implement them ngl.

Variadic macros would be cool, but I'm not sure that it would be useful with MISA to be honest.

Hexadecimal float literals would be interesting, but I've also never used them xP

Variable-length arrays and flexible array members would be nice, since I know they are used by several libraries that I want to port to MISA.

It would be interesting to implement comptime reflection, like `__func__` or `__var__`.
Only thing is I want it to be more or less vanilla C, like it can be compiled by any C compiler, but at the same time, I also *really* want to add a bunch of MISA-specific features.

Anyways, I'm going to open up an issue on the repo with a link to this proposal, and have people vote on it.

I'll also have people vote on whether or not we want to make the compiler target a superset of C so I can add a bunch of things like comptime reflection and MISA-specific extensions.

I should probably also begin working on making an LSP output flag so I can begin to use the compiler with VSCode and Neovim.