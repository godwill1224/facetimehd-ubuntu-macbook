#!/usr/bin/env bash
#
# FaceTime HD Camera Driver Uninstaller
# Removes the driver, firmware, and DKMS configuration
#

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

print_warn "This will remove the FaceTime HD camera driver from your system."
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstall cancelled."
    exit 0
fi

print_info "Starting FaceTime HD camera driver removal..."

# Unload kernel module
print_info "Unloading kernel module..."
if lsmod | grep -q facetimehd; then
    modprobe -r facetimehd || print_warn "Could not unload module (may be in use)"
else
    print_info "Module not loaded"
fi

# Remove DKMS module
print_info "Removing DKMS module..."
if dkms status facetimehd | grep -q facetimehd; then
    dkms remove facetimehd/0.1 --all || print_warn "DKMS removal had warnings"
    print_info "✓ DKMS module removed"
else
    print_info "DKMS module not found"
fi

# Remove driver source
WORKDIR="/usr/src/facetimehd-driver"
if [ -d "$WORKDIR" ]; then
    print_info "Removing driver source..."
    rm -rf "$WORKDIR"
    print_info "✓ Driver source removed"
else
    print_info "Driver source not found"
fi

# Remove firmware
FIRMWARE_DIR="/lib/firmware/facetimehd"
if [ -d "$FIRMWARE_DIR" ]; then
    print_info "Removing camera firmware..."
    rm -rf "$FIRMWARE_DIR"
    print_info "✓ Firmware removed"
else
    print_info "Firmware not found"
fi

# Remove any lingering module files
print_info "Cleaning up module files..."
find /lib/modules -name "facetimehd.ko*" -delete 2>/dev/null || true
find /lib/modules -name "bcwc_pcie.ko*" -delete 2>/dev/null || true

# Update module dependencies
print_info "Updating module dependencies..."
depmod -a

# Verify removal
print_info "Verifying removal..."

CLEANUP_SUCCESS=true

if dkms status facetimehd 2>/dev/null | grep -q facetimehd; then
    print_warn "DKMS module still present"
    CLEANUP_SUCCESS=false
fi

if [ -d "$WORKDIR" ]; then
    print_warn "Driver source still present at $WORKDIR"
    CLEANUP_SUCCESS=false
fi

if [ -d "$FIRMWARE_DIR" ]; then
    print_warn "Firmware still present at $FIRMWARE_DIR"
    CLEANUP_SUCCESS=false
fi

if lsmod | grep -q facetimehd; then
    print_warn "Kernel module still loaded"
    CLEANUP_SUCCESS=false
fi

# Print completion message
echo ""
if [ "$CLEANUP_SUCCESS" = true ]; then
    print_info "Uninstall complete! ✓"
    echo ""
    echo "The FaceTime HD camera driver has been removed."
    echo "Your system should now be back to its original state."
else
    print_warn "Uninstall completed with warnings"
    echo ""
    echo "Some components may still be present."
    echo "You may need to manually remove remaining files or reboot."
fi
echo ""
