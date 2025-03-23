#include "keyboard.h"

#define UART_BASE  0x09000000  // QEMU PL011 UART base address
#define UART_FR    (UART_BASE + 0x18) // Flag Register
#define UART_DR    (UART_BASE + 0x00) // Data Register

char keyboard_getchar() {
    // Wait until UART has received data
    while (*(volatile unsigned int*)UART_FR & (1 << 4)) {
        // Wait for RXFE (Receive FIFO Empty) to be cleared
    }
    return *(volatile unsigned int*)UART_DR; // Read received character
}

