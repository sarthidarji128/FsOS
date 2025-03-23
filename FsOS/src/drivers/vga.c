#include "vga.h"

#define VGA_BUFFER ((volatile unsigned short*) 0xB8000) // VGA Memory
#define VGA_WIDTH 80

void vga_init() {
    for (int i = 0; i < VGA_WIDTH * 25; i++) {
        VGA_BUFFER[i] = 0x0720; // Space with color
    }
}

void vga_print(const char *message) {
    int i = 0;
    while (message[i] != '\0') {
        VGA_BUFFER[i] = 0x0700 | message[i];
        i++;
    }
}

void vga_putchar(char c) {
    VGA_BUFFER[0] = 0x0700 | c; // Print character at position 0
}

