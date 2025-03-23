#include "drivers/vga.h"  // Adjust the path if needed
#include "drivers/keyboard.h"

void kernel_main() {
    vga_init();
    vga_print("Hello, FsOS!\n");

    while (1) {
        char input = keyboard_getchar(); // Read keyboard input
        vga_putchar(input); // Display it
    }
}

