#!/usr/bin/env bash
#
# Power Management Tuning Script
# Configures TLP for optimal battery life and quieter fan operation on MacBooks
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

print_info "Configuring power management for MacBook..."

# Install TLP
print_info "Installing TLP power management..."
apt update
apt install -y tlp tlp-rdw

# Backup existing config if present
TLP_CONF="/etc/tlp.conf"
if [ -f "$TLP_CONF" ]; then
    print_warn "Backing up existing TLP configuration..."
    cp "$TLP_CONF" "$TLP_CONF.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Create optimized TLP configuration
print_info "Applying MacBook-optimized settings..."
cat > "$TLP_CONF" <<'EOF'
# TLP Configuration for MacBook
# Optimized for battery life and reduced heat/noise

# CPU Frequency Scaling
CPU_SCALING_GOVERNOR_ON_AC=ondemand
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# CPU Energy/Performance Policy (HWP)
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# CPU Boost
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0

# Platform Profile
PLATFORM_PROFILE_ON_AC=balanced
PLATFORM_PROFILE_ON_BAT=low-power

# Disk I/O Scheduler
DISK_IOSCHED=mq-deadline

# SATA Aggressive Link Power Management (ALPM)
SATA_LINKPWR_ON_AC=med_power_with_dipm
SATA_LINKPWR_ON_BAT=min_power

# PCI Express Active State Power Management
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave

# Runtime Power Management for PCI(e) devices
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto

# USB Autosuspend
USB_AUTOSUSPEND=1
USB_EXCLUDE_PHONE=1

# WiFi Power Saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Bluetooth
DEVICES_TO_DISABLE_ON_STARTUP=""
DEVICES_TO_ENABLE_ON_STARTUP="wifi bluetooth"

# Battery Care (if supported)
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=80

# Restore defaults on AC
RESTORE_THRESHOLDS_ON_BAT=1
EOF

# Mask conflicting services
print_info "Disabling conflicting power management services..."
systemctl mask power-profiles-daemon 2>/dev/null || true
systemctl mask laptop-mode.service 2>/dev/null || true

# Enable and start TLP
print_info "Enabling TLP service..."
systemctl enable tlp.service
systemctl start tlp.service

# Verify TLP is running
if systemctl is-active --quiet tlp.service; then
    print_info "✓ TLP service is running"
else
    print_warn "TLP service failed to start"
    systemctl status tlp.service
fi

# Apply settings immediately
print_info "Applying settings..."
tlp start

# Print summary
echo ""
print_info "Power management configuration complete!"
echo ""
echo "Applied settings:"
echo "  • CPU scaling: ondemand (AC) / powersave (battery)"
echo "  • SATA power: Aggressive on battery"
echo "  • USB autosuspend: Enabled"
echo "  • WiFi power saving: Enabled on battery"
echo "  • PCI power management: Enabled"
echo ""
echo "Benefits:"
echo "  ✓ Reduced heat and fan noise"
echo "  ✓ Extended battery life"
echo "  ✓ Automatic power optimization"
echo ""
echo "Monitoring:"
echo "  • View status: sudo tlp-stat"
echo "  • View battery: sudo tlp-stat -b"
echo "  • View CPU: sudo tlp-stat -p"
echo ""
echo "Configuration file: $TLP_CONF"
echo ""
