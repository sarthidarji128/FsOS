# FsOS

1. Purpose
FsOS appears to be a learning project aimed at developing a minimal operating system from scratch. It focuses on fundamental OS components like kernel initialization, basic input/output drivers (VGA and keyboard), and building a bootable ISO image. The project likely serves as an educational tool for understanding OS development principles.

2. Key Features
VGA Driver: Provides functionality to initialize the VGA text mode buffer and print messages or individual characters to the screen.
Keyboard Driver: Implements a basic function to read character input from a UART device, presumably connected to a keyboard.
Kernel Entry Point: Defines kernel_main as the primary entry point for the operating system, handling initialization and the main loop.
Bootable ISO Creation: Includes a build script to compile the kernel and drivers, create a GRUB bootloader, and package everything into a bootable ISO image.
QEMU Emulation: The build script also includes a command to run the created ISO in QEMU for testing.
3. Technology Stack
Languages:
C (for kernel and driver implementation)
Assembly (likely for boot.S, though not provided in the context)
Markdown (for README)
Shell (for build script)
Tools:
aarch64-linux-gnu-gcc: Cross-compiler for ARM 64-bit architecture.
aarch64-linux-gnu-ld: Cross-linker for ARM 64-bit architecture.
xorriso, grub-efi-arm64-bin, mtools, qemu-system-aarch64: Tools for creating bootable ISOs and emulation.
grub-mkimage, grub-mkrescue: GRUB tools for building bootloaders and ISO images.
4. Architecture
The repository follows a typical OS structure:

src/ directory: Contains the core source code.
drivers/: Houses hardware-specific drivers (VGA, keyboard).
boot.S (assumed): Likely contains the initial bootloader code.
kernel.c: Implements the main kernel logic.
link.ld: Linker script for defining the memory layout of the kernel.
build.sh: A shell script orchestrates the entire build process, from compilation to ISO creation and emulation.
iso/ directory: Created during the build process, this directory serves as the staging area for the ISO image content, including the bootloader and kernel.
5. Getting Started
To build and run FsOS:

Prerequisites: Ensure you have the necessary build tools installed (e.g., xorriso, grub-efi-arm64-bin, mtools, qemu-system-aarch64, and the aarch64-linux-gnu toolchain). The build.sh script attempts to install some of these.
Execute Build Script: Run the build.sh script from the root of the repository:
[object Object]
Run in QEMU: The script will automatically attempt to run the generated FsOS.iso in QEMU. If not, you can manually run it using:
qemu-system-aarch64 -machine virt -cpu cortex-a57 -smp 2 -m 512M -nographic -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd -cdrom FsOS.iso
