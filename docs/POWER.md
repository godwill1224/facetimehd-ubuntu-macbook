# Power Management Guide

MacBooks running Linux often experience increased heat and fan noise compared to macOS due to differences in power management. This guide helps optimize your system for better battery life and quieter operation.

---

## Overview

The power management script (`power-tune.sh`) configures TLP (Advanced Power Management for Linux) with settings optimized for MacBooks.

### Benefits

- **Reduced heat generation** – Lower CPU and component temperatures
- **Quieter fan operation** – Less aggressive cooling needed
- **Extended battery life** – Power-saving modes for battery operation
- **Automatic optimization** – Settings applied on boot

---

## Quick Setup

Run the power tuning script:

```bash
sudo ./scripts/power-tune.sh
```

The script will:
1. Install TLP power management tool
2. Apply MacBook-optimized configuration
3. Enable TLP service to run on boot
4. Activate settings immediately

---

## What Gets Configured

### CPU Scaling

- **On AC power**: `ondemand` governor (balanced performance)
- **On battery**: `powersave` governor (maximize battery life)
- **Energy policy**: Power-saving mode when on battery

### Storage

- **SATA link power**: Aggressive power saving on battery (`min_power`)
- Reduces SSD/HDD power consumption when idle

### USB Devices

- **USB autosuspend**: Enabled
- USB devices automatically enter low-power mode when idle

### Wireless

- **WiFi power saving**: Enabled on battery
- Reduces wireless adapter power draw

---

## Manual Configuration

If you prefer to configure TLP manually, edit the configuration file:

```bash
sudo nano /etc/tlp.conf
```

### Recommended Settings for MacBooks

```bash
# CPU Performance
CPU_SCALING_GOVERNOR_ON_AC=ondemand
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# Storage
SATA_LINKPWR_ON_BAT=min_power

# USB
USB_AUTOSUSPEND=1

# Wireless
WIFI_PWR_ON_BAT=on
```

After editing, restart TLP:

```bash
sudo systemctl restart tlp
```

---

## Monitoring

### Check TLP Status

```bash
sudo tlp-stat
```

### View Current Power Draw

```bash
sudo tlp-stat -b  # Battery information
sudo tlp-stat -p  # Processor information
sudo tlp-stat -d  # Disk information
```

### Monitor CPU Temperature

```bash
# Install sensors
sudo apt install lm-sensors
sudo sensors-detect

# View temperatures
sensors
```

### Fan Speed

```bash
# Install macfanctld (optional, for manual fan control)
sudo apt install macfanctld

# View fan status
cat /sys/devices/platform/applesmc.768/fan1_input
```

---

## Troubleshooting

### TLP Not Starting

```bash
# Check service status
sudo systemctl status tlp

# Enable if disabled
sudo systemctl enable tlp
sudo systemctl start tlp
```

### Still Running Hot

1. **Check for high CPU usage**:
   ```bash
   top
   ```

2. **Disable CPU turbo boost** (reduces performance but lowers heat):
   ```bash
   echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
   ```

3. **Clean fans and vents** – Dust buildup significantly impacts cooling

4. **Repaste thermal compound** – Older MacBooks benefit from fresh thermal paste

### Battery Draining Quickly

```bash
# Check what's consuming power
sudo powertop

# Auto-tune all settings
sudo powertop --auto-tune
```

---

## Reverting Changes

To disable TLP and revert to default power settings:

```bash
sudo systemctl stop tlp
sudo systemctl disable tlp
sudo apt remove tlp
```

---

## Additional Resources

- [TLP Official Documentation](https://linrunner.de/tlp/)
- [ArchWiki: Power Management](https://wiki.archlinux.org/title/Power_management)
- [Ubuntu Wiki: Power Management](https://help.ubuntu.com/community/PowerManagement)

---

## Notes

- Power management settings are a balance between performance and efficiency
- Aggressive power saving may impact system responsiveness
- Settings can be adjusted per your usage patterns
- Some MacBook models may require model-specific tweaks
