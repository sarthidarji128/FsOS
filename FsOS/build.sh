#!/bin/bash
set -e

# Add Homebrew paths for macOS compatibility
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# =========================================================
# FsOS Builder Script (macOS / Linux compatible)
# =========================================================

# Versions
ALPINE_VERSION="3.19.1"
ALPINE_ISO="alpine-standard-${ALPINE_VERSION}-x86_64.iso"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/${ALPINE_ISO}"

# Work directories
WORKDIR="$(pwd)"
ISO_SRC="${WORKDIR}/iso_src"
OVERLAY_SRC="${WORKDIR}/overlay_src"

echo "========================================================="
echo " Building FsOS ISO Step-by-Step"
echo "========================================================="

# 1. Dependency Check
echo "[1] Checking for required tools..."
if ! command -v xorriso &> /dev/null; then
    echo "❌ ERROR: 'xorriso' is not installed."
    echo "To build the final ISO on macOS, you must install xorriso."
    echo "Please run: brew install xorriso"
    exit 1
fi
echo "✅ xorriso is installed."

# 2. Download Base OS
echo "[2] Downloading Alpine Base OS..."
if [ ! -f "${ALPINE_ISO}" ]; then
    curl -L -o "${ALPINE_ISO}" "${ALPINE_URL}"
else
    echo "✅ Alpine ISO already downloaded."
fi

# 3. Extract Base OS
echo "[3] Extracting ISO contents..."
if [ -d "${ISO_SRC}" ]; then
    chmod -R +w "${ISO_SRC}" 2>/dev/null || true
    rm -rf "${ISO_SRC}"
fi
mkdir -p "${ISO_SRC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS extraction using tar
    echo "Extracting ISO using tar on macOS..."
    tar -xf "${ALPINE_ISO}" -C "${ISO_SRC}"
else
    # Linux extraction (assuming mount or 7z is available)
    # Using 7z for easier unprivileged extraction
    if command -v 7z &> /dev/null; then
        7z x "${ALPINE_ISO}" -o"${ISO_SRC}"
    else
        echo "❌ ERROR: '7z' is required on Linux to extract the ISO without root."
        exit 1
    fi
fi
chmod -R +w "${ISO_SRC}"
echo "✅ ISO extracted to ${ISO_SRC}"

# 4. Create the Overlay (apkovl)
# This overlay contains our custom startup script and MOTD
echo "[4] Building custom configuration overlay (apkovl)..."
rm -rf "${OVERLAY_SRC}"
mkdir -p "${OVERLAY_SRC}/etc/local.d"
mkdir -p "${OVERLAY_SRC}/etc/runlevels/default"

# Inject our startup script
cp src/fsos.start "${OVERLAY_SRC}/etc/local.d/fsos.start"
chmod +x "${OVERLAY_SRC}/etc/local.d/fsos.start"

# Inject custom MOTD
cp src/motd "${OVERLAY_SRC}/etc/motd"

# Enable 'local' service on boot so our script runs
ln -s /etc/init.d/local "${OVERLAY_SRC}/etc/runlevels/default/local"

# Package the overlay
cd "${OVERLAY_SRC}"
tar -czvf "${ISO_SRC}/localhost.apkovl.tar.gz" * > /dev/null
cd "${WORKDIR}"
echo "✅ Overlay packaged into localhost.apkovl.tar.gz"

# 5. Modify Bootloader (Optional)
# Alpine automatically loads localhost.apkovl.tar.gz if it's in the root
# We will just ensure the boot menu timeout is fast
echo "[5] Tweaking bootloader settings..."
if [ -f "${ISO_SRC}/boot/syslinux/syslinux.cfg" ]; then
    sed -i.bak 's/TIMEOUT 20/TIMEOUT 5/g' "${ISO_SRC}/boot/syslinux/syslinux.cfg"
fi
if [ -f "${ISO_SRC}/boot/grub/grub.cfg" ]; then
    sed -i.bak 's/set timeout=2/set timeout=1/g' "${ISO_SRC}/boot/grub/grub.cfg"
fi

# 6. Repackage ISO
echo "[6] Repackaging final FsOS.iso..."
rm -f FsOS.iso

# Note: The boot paths might slightly differ depending on the Alpine version. 
# 3.19 standard ISO uses ISOLINUX/SYSLINUX
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "FSOS" \
    -eltorito-boot boot/syslinux/isolinux.bin \
    -eltorito-catalog boot/syslinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -isohybrid-mbr "${ISO_SRC}/boot/syslinux/isohdpfx.bin" \
    -output FsOS.iso \
    "${ISO_SRC}/"

echo "========================================================="
echo " 🎉 SUCCESS! FsOS.iso has been generated."
echo " You can now test it in VirtualBox, VMware, or QEMU."
echo "========================================================="
