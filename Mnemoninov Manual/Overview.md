# Overview

## Design Philosophy

MISA is a machine architecture and assembly language designed to provide a fun environment for exploring low-level programming.

While real-world architectures are constrained by hardware and compiler requirements, MISA is free to focus on the programming experience, allowing it to remain simple and expressive.

---

## General Aspects

MISA is a 32-bit, register-based architecture with big-endian byte order. Programs are written in MISA assembly, assembled into bytecode, and executed by a virtual machine.

The architecture follows a load-store (register-register) design, where nearly all operations are performed on registers, with memory access exposed through explicit load and store instructions.

MISA allows you to write expressive code by providing more than one hundred instructions and a large set of general-purpose registers.
