# Storage

## Persistent Memory

MISA provides persistent memory blocks referred to as storages, which programs can use to save data between runs. A storage is a contiguous block of memory accessed through system calls:
- `SYS_STORAGE_READ`: loads a span of data from storage into memory.
- `SYS_STORAGE_WRITE`: writes a span of data from memory to storage.

---

## Per-Project Storage

Each project is associated with a storage identified by its `storage_id`. By default, all projects use the storage named `common`, so they share the same persistent memory.

The `storage_id` can be modified through the terminal so a project can use its own dedicated storage, for example to store a game's save data.
