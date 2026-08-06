#include <mfs/mfs.h>
#include <stdio.h>

char read_buf[128];

void main(void) {
    int result;

    // Load existing filesystem, or format fresh if storage is uninitialised
    result = MFS.load();
    if (result != 0) {
        printf("No filesystem found, formatting...\n");
        MFS.format();
    }

    // Create a file and write a string to it
    MFS.create("hello.txt");
    MFS.write("hello.txt", "Hello from MFS!", 16);

    // Read it back and print
    result = MFS.read("hello.txt", read_buf, 128);
    printf("Read %d bytes: %s\n", result, read_buf);

    // Overwrite with different content
    MFS.write("hello.txt", "Updated content.", 17);
    result = MFS.read("hello.txt", read_buf, 128);
    printf("After write: %s\n", read_buf);

    // Delete and confirm it's gone
    MFS.delete("hello.txt");
    result = MFS.read("hello.txt", read_buf, 128);
    if (result == -1) {
        printf("File deleted successfully.\n");
    }

    return;
}