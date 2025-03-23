.global _start
.section .text
.align 4
_start:
    // Set up stack
    mov sp, #0x80000

    // Call kernel main function
    bl kernel_main

loop:
    wfi
    b loop

