# FsOS User Manual & Usage Guide

This guide walks you through setting up, booting, and operating your custom **FsOS** hypervisor ISO.

---

## 1. Setting Up Your Virtual Machine (VM)

To run the `FsOS.iso`, you need a hypervisor software (like **VirtualBox**, **VMware Fusion**, or **UTM**). Configure your VM using the following specifications:

*   **OS Type**: Linux (Choose "Other Linux 64-bit" or "Alpine Linux 64-bit").
*   **RAM**: At least **2 GB (2048 MB)**. Since FsOS downloads target OS ISOs directly into RAM, less than 2 GB will prevent you from downloading Ubuntu or Kali Linux.
*   **CPU**: 2 Cores.
*   **Nested Virtualization (Crucial)**: If your VM software supports it, enable **Nested Virtualization** (e.g., VT-x/AMD-V passthrough). This allows the QEMU emulator inside FsOS to run virtual machines at full speed.
*   **Network**: Set the network adapter to **NAT** or **Bridged** with DHCP active. FsOS must be able to fetch packages and ISOs from the web.
*   **Storage**: Add a virtual hard disk (e.g., 10 GB) if you want FsOS to detect physical drives, and mount `FsOS.iso` in the CD/DVD drive.

---

## 2. Booting FsOS

1. Start your VM with `FsOS.iso` mounted.
2. The bootloader will launch quickly (configured with a 5-second timeout).
3. The system will auto-login as `root` and initialize the FsOS program. 
4. You will see the FsOS dashboard displaying your current system parameters:
   ```text
   ========================================
             Welcome to FsOS               
   ========================================
     RAM: 2048MB | CPU: x86_64
   ========================================
   Please select an option:
     1. Connect to the network (DHCP)
     2. Choose & Download Target OS
     3. Launch Target OS in QEMU
     4. View Hardware Diagnostics
     5. Drop to root shell
     6. Reboot
   ```

---

## 3. Step-by-Step Operations

### Step 1: Connect to the Network
Before you can download any operating system or run QEMU, FsOS must be connected to the internet.
1. Select **Option 1**.
2. FsOS will run `udhcpc -i eth0` to request an IP address from your hypervisor's virtual DHCP server.
3. Once you see `[+] Network setup complete`, press **Enter** to return to the menu.

### Step 2: Choose & Download Target OS
1. Select **Option 2** to open the OS selection submenu.
2. Choose from the available options:
   *   **1. ReactOS**: An open-source clone of Windows. (Requires 512MB RAM minimum).
   *   **2. Ubuntu Linux**: A standard Linux distribution. (Requires 2GB RAM minimum).
   *   **3. Kali Linux**: A penetration testing distribution. (Requires 2GB RAM minimum).
3. **Hardware Assessment**: FsOS will evaluate your system. If your RAM is too low, it will trigger a warning. If you try to run ReactOS on an ARM64 CPU (aarch64), it will warn you that ReactOS is only supported on x86 computers.
4. **Architecture-Aware Download**: If you run FsOS on a standard Intel/AMD computer, it downloads the `x86_64` (64-bit PC) installer. If it detects you are running on an Apple Silicon M-series chip (using UTM on macOS), it will automatically change its query to download the `ARM64` installer.
5. The download progress bar will output. The download is stored at `/tmp/target_os.iso`.

### Step 3: Launch the Virtual Machine in QEMU
1. Select **Option 3**.
2. **QEMU Auto-Installer**: If QEMU is not yet present on your bootable ISO, FsOS will automatically configure Alpine's package repositories, contact the servers, and download/install `qemu-system` in the background.
3. **Console Redirection**: Since FsOS runs as a lightweight terminal-only OS, QEMU is initiated in `-nographic` mode. This redirects the guest system's serial text console directly to your terminal.
4. **How to exit QEMU**: When QEMU takes over the screen, your keyboard is redirected to the virtual machine. To terminate the VM and return to the FsOS menu:
   *   Press **`Ctrl + A`** on your keyboard, release, and then press **`X`**.
   *   This is the standard QEMU terminal escape sequence.

### Step 4: Hardware Diagnostics
1. Select **Option 4**.
2. This displays a detailed audit of the system:
   *   **CPU Architecture**: Shows if your processor is `x86_64` or `aarch64`.
   *   **Virtualization**: Indicates if hardware-accelerated KVM is active. (KVM allows the QEMU guest to run at near-native CPU speeds).
   *   **System RAM**: Displays total RAM in megabytes.
   *   **Storage Disks**: Scans for active physical disks (like `/dev/sda` or `/dev/vda`).

### Step 5: Maintenance Shell
1. Select **Option 5** to drop out of the FsOS program.
2. You will be given a raw Linux shell prompt (`localhost:~#`). You can run standard Linux utilities here.
3. To return to the FsOS control panel, type:
   ```bash
   exit
   ```

---

## 4. Advanced Customization

If you want to edit the menu or add your own target ISO download paths:
1. Boot FsOS.
2. Drop to the shell (**Option 5**).
3. Open the entrypoint script in the text editor:
   ```bash
   vi /etc/local.d/fsos.start
   ```
4. Make your changes, save, and commit the changes to your persistent configuration overlay:
   ```bash
   lbu commit
   ```
