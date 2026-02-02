# FaceTime HD Camera for Linux

**Enable the built-in Apple FaceTime HD camera on 2013–2015 Intel MacBooks running Ubuntu/Linux**

[![Build](https://img.shields.io/badge/build-DKMS%20auto-success)](https://github.com/godwill1224/facetimehd-ubuntu-macbook)
[![License](https://img.shields.io/github/license/godwill1224/facetimehd-ubuntu-macbook)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-orange)](https://ubuntu.com)
[![Kernel](https://img.shields.io/badge/kernel-6.x-blue)](https://kernel.org)

---

## Overview

This project provides an automated installer that makes the Apple FaceTime HD camera work reliably on older Intel MacBooks running Linux. It eliminates the need for manual driver compilation, firmware extraction, and patching by wrapping everything into a single, reproducible installation script.

### What This Does

- Automatically builds and installs the `facetimehd` (bcwc_pcie) driver using DKMS
- Downloads and extracts the required Apple firmware
- Configures automatic driver rebuilds after kernel updates
- Optionally tunes power management for better battery life and quieter fans

---

## Compatibility

### Tested MacBook Models

- MacBookPro11,1
- MacBookPro11,2
- MacBookPro11,3
- Other 2013–2015 Intel MacBooks with FaceTime HD (BCM1570)

### Supported Operating Systems

- Ubuntu 22.04 LTS and newer
- Ubuntu 24.04 LTS
- Other Debian-based distributions (may require adaptation)

### Kernel Support

- Linux kernel 6.x series
- Automatic rebuild support via DKMS

---

## Installation

### Prerequisites

Ensure your system is up to date:

```bash
sudo apt update && sudo apt upgrade -y
```

### Install

Clone the repository and run the installer:

```bash
git clone https://github.com/godwill1224/facetimehd-ubuntu-macbook.git
cd facetimehd-ubuntu-macbook
chmod +x scripts/*.sh
sudo ./scripts/install.sh
```

Reboot your system to load the driver:

```bash
sudo reboot
```

### Verify Installation

After rebooting, test the camera:

```bash
# Check if the driver loaded
lsmod | grep facetimehd

# List video devices
v4l2-ctl --list-devices

# Test with Cheese
cheese
```

You should see the "Apple FaceTime HD" camera listed as `/dev/video0`.

---

## Usage

The camera should now work automatically with:

- **Cheese** (GNOME Camera)
- **Google Meet**
- **Zoom**
- **Microsoft Teams**
- Any application using V4L2 (Video4Linux2)

---

## Optional: Power Management

Reduce heat and fan noise while improving battery life:

```bash
sudo ./scripts/power-tune.sh
```

This script installs and configures TLP with optimized settings for MacBooks.

---

## Troubleshooting

If the camera doesn't work after installation, see the [troubleshooting guide](docs/TROUBLESHOOTING.md).

### Common Issues

**Camera not detected:**
```bash
# Reload the driver
sudo modprobe -r facetimehd
sudo modprobe facetimehd
```

**No /dev/video0:**
```bash
# Check DKMS status
dkms status

# Check kernel logs
dmesg | grep facetimehd
```

**Permission denied:**
```bash
# Add your user to the video group
sudo usermod -aG video $USER
# Log out and back in
```

For detailed troubleshooting, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

---

## Uninstallation

To completely remove the driver and firmware:

```bash
sudo ./scripts/uninstall.sh
```

This will:
- Remove the DKMS module
- Delete firmware files
- Clean up configuration changes

---

## How It Works

The installer automates these steps:

1. **Install dependencies**: Ensures build tools and kernel headers are available
2. **Clone driver source**: Downloads the `facetimehd` driver repository
3. **Register with DKMS**: Enables automatic rebuilds on kernel updates
4. **Build kernel module**: Compiles the driver for your current kernel
5. **Extract firmware**: Downloads and installs Apple's proprietary camera firmware to `/lib/firmware/facetimehd/`
6. **Load driver**: Inserts the `bcwc_pcie` kernel module

DKMS (Dynamic Kernel Module Support) ensures the driver rebuilds automatically whenever you update your kernel, eliminating manual maintenance.

---

## Project Structure

```
facetimehd-ubuntu-macbook/
├── scripts/
│   ├── install.sh          # Main installation script
│   ├── uninstall.sh        # Removal script
│   └── power-tune.sh       # Optional power optimization
├── docs/
│   ├── TROUBLESHOOTING.md  # Detailed troubleshooting guide
│   └── POWER.md            # Power management documentation
├── dkms.conf               # DKMS configuration
├── README.md               # This file
├── CONTRIBUTING.md         # Contribution guidelines
├── CHANGELOG.md            # Version history
└── LICENSE                 # MIT License
```

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Ways to help:
- Report bugs or compatibility issues
- Test on different MacBook models
- Improve documentation
- Submit patches or enhancements

---

## Credits

This project builds upon excellent work from the open-source community:

- **Driver**: [patjak/facetimehd](https://github.com/patjak/facetimehd) – Reverse-engineered FaceTime HD driver
- **Power management**: [TLP](https://linrunner.de/tlp/) – Advanced power management for Linux
- **Linux camera stack**: V4L2, PipeWire, GStreamer, GNOME

This installer simply automates and packages their work into an easy-to-use tool.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Support

If you encounter issues:

1. Check the [troubleshooting guide](docs/TROUBLESHOOTING.md)
2. Search [existing issues](https://github.com/godwill1224/facetimehd-ubuntu-macbook/issues)
3. Open a [new issue](https://github.com/godwill1224/facetimehd-ubuntu-macbook/issues/new) with:
   - MacBook model (`sudo dmidecode -s system-product-name`)
   - Ubuntu version (`lsb_release -a`)
   - Kernel version (`uname -r`)
   - Output of `dkms status` and `lsmod | grep facetimehd`

---

**Made with ❤️ for the Linux + MacBook community**
