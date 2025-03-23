#!/bin/bash
set -e

# Check if required files exist
if [ ! -f "src/boot.S" ]; then
    echo "Error: src/boot.S not found!"
    exit 1
fi

# Install dependencies
sudo apt-get install -y xorriso grub-efi-arm64-bin mtools qemu-system-aarch64

# Create build directories
mkdir -p iso/boot iso/EFI/BOOT iso/grub obj

# Compile Kernel and Drivers
aarch64-linux-gnu-gcc -ffreestanding -c src/boot.S -o obj/boot.o
aarch64-linux-gnu-gcc -ffreestanding -c src/kernel.c -o obj/kernel.o
aarch64-linux-gnu-gcc -ffreestanding -c src/drivers/vga.c -o obj/vga.o
aarch64-linux-gnu-gcc -ffreestanding -c src/drivers/keyboard.c -o obj/keyboard.o

# Link the Kernel with Drivers
aarch64-linux-gnu-ld -T src/link.ld -o kernel.elf obj/boot.o obj/kernel.o obj/vga.o obj/keyboard.o

# Copy kernel to ISO
cp kernel.elf iso/boot/kernel.elf

# Build the GRUB bootloader
grub-mkimage -O arm64-efi -o iso/EFI/BOOT/BOOTAA64.EFI \
    --prefix="/grub" normal linux echo configfile search efi_gop

# Copy GRUB configuration
cp iso/boot/grub/grub.cfg iso/grub/grub.cfg

# Create the ISO
grub-mkrescue -o FsOS.iso iso || { echo "Error: Failed to create ISO!"; exit 1; }

echo "ISO created: FsOS.iso"

# Run in QEMU
qemu-system-aarch64 -machine virt -cpu cortex-a57 -smp 2 -m 512M -nographic \
    -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd -cdrom FsOS.iso

