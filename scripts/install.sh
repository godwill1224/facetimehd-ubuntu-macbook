#!/usr/bin/env bash
#
# FaceTime HD Camera Driver Installer
# Installs the bcwc_pcie/facetimehd driver for Apple FaceTime HD cameras on Linux
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_info "Starting FaceTime HD camera driver installation..."

# Update package list
print_info "Updating package list..."
apt update

# Install required dependencies
print_info "Installing build dependencies..."
apt install -y \
    dkms \
    git \
    curl \
    build-essential \
    linux-headers-$(uname -r) \
    v4l-utils \
    kmod

# Define working directory
WORKDIR="/usr/src/facetimehd-driver"
FIRMWARE_URL="https://github.com/patjak/facetimehd-firmware/raw/master/firmware.bin"
FIRMWARE_DIR="/lib/firmware/facetimehd"

# Clone driver source if not already present
if [ ! -d "$WORKDIR" ]; then
    print_info "Cloning FaceTime HD driver source..."
    git clone https://github.com/patjak/facetimehd.git "$WORKDIR"
else
    print_warn "Driver source already exists at $WORKDIR"
    print_info "Pulling latest changes..."
    cd "$WORKDIR"
    git pull || true
fi

# Build and install driver with DKMS
print_info "Building driver with DKMS..."
cd "$WORKDIR"

# Clean previous builds
make clean || true

# Build and register with DKMS
if ! make dkms; then
    print_error "Driver build failed"
    print_error "Check that kernel headers are installed: linux-headers-$(uname -r)"
    exit 1
fi

# Download and install firmware
print_info "Downloading Apple camera firmware..."
TEMP_FIRMWARE="/tmp/facetimehd-firmware.bin"

if curl -L -f -o "$TEMP_FIRMWARE" "$FIRMWARE_URL"; then
    print_info "Installing firmware..."
    mkdir -p "$FIRMWARE_DIR"
    cp "$TEMP_FIRMWARE" "$FIRMWARE_DIR/firmware.bin"
    chmod 644 "$FIRMWARE_DIR/firmware.bin"
    rm "$TEMP_FIRMWARE"
else
    print_error "Failed to download firmware"
    print_error "Please check your internet connection"
    exit 1
fi

# Verify firmware installation
if [ ! -f "$FIRMWARE_DIR/firmware.bin" ]; then
    print_error "Firmware file not found at $FIRMWARE_DIR/firmware.bin"
    exit 1
fi

# Load the kernel module
print_info "Loading camera driver..."
modprobe -r facetimehd 2>/dev/null || true
if modprobe facetimehd; then
    print_info "Driver loaded successfully"
else
    print_warn "Driver load failed - may require reboot"
fi

# Verify installation
print_info "Verifying installation..."

# Check DKMS status
if dkms status facetimehd | grep -q "installed"; then
    print_info "✓ DKMS module installed"
else
    print_warn "DKMS module may not be properly installed"
fi

# Check if module is loaded
if lsmod | grep -q facetimehd; then
    print_info "✓ Kernel module loaded"
else
    print_warn "Kernel module not loaded (reboot may be required)"
fi

# Check for video device
if [ -e /dev/video0 ]; then
    print_info "✓ Camera device detected: /dev/video0"
else
    print_warn "Camera device not detected yet (reboot recommended)"
fi

# Print completion message
echo ""
print_info "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Reboot your system: sudo reboot"
echo "  2. Test camera with: cheese"
echo "  3. Or check device: v4l2-ctl --list-devices"
echo ""
echo "Optional:"
echo "  - Run power optimization: sudo ./scripts/power-tune.sh"
echo "  - See troubleshooting: docs/TROUBLESHOOTING.md"
echo ""
