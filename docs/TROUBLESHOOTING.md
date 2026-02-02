# Troubleshooting Guide

This guide covers common issues when installing and using the FaceTime HD camera driver on Linux.

---

## Table of Contents

1. [Camera Not Detected](#camera-not-detected)
2. [Driver Not Loading](#driver-not-loading)
3. [Browser-Specific Issues](#browser-specific-issues)
4. [Kernel Update Issues](#kernel-update-issues)
5. [Permission Issues](#permission-issues)
6. [Firmware Problems](#firmware-problems)
7. [Performance Issues](#performance-issues)

---

## Camera Not Detected

### Symptoms

- No `/dev/video0` device
- Camera not appearing in applications
- `v4l2-ctl --list-devices` shows nothing

### Solutions

#### Check if driver is loaded

```bash
lsmod | grep facetimehd
```

If the output is empty, the driver isn't loaded.

#### Load the driver manually

```bash
sudo modprobe facetimehd
```

#### Check for errors in kernel log

```bash
dmesg | grep facetimehd
dmesg | grep bcwc
```

Look for error messages that might indicate what went wrong.

#### Verify firmware is installed

```bash
ls -la /lib/firmware/facetimehd/
```

You should see `firmware.bin` in this directory.

#### Check DKMS status

```bash
dkms status
```

You should see something like:
```
facetimehd/0.1, 6.x.x-xx-generic, x86_64: installed
```

---

## Driver Not Loading

### Symptoms

- `modprobe facetimehd` fails with errors
- Driver builds but doesn't load
- Kernel module errors in `dmesg`

### Solutions

#### Rebuild the driver

```bash
sudo dkms remove facetimehd/0.1 --all
cd /usr/src/facetimehd-driver
sudo make clean
sudo make dkms
sudo modprobe facetimehd
```

#### Check for conflicting drivers

```bash
lsmod | grep uvcvideo
```

If `uvcvideo` is loaded, it might conflict:

```bash
sudo modprobe -r uvcvideo
sudo modprobe facetimehd
```

#### Verify kernel headers match running kernel

```bash
uname -r
dpkg -l | grep linux-headers
```

If headers don't match, install them:

```bash
sudo apt install linux-headers-$(uname -r)
```

#### Check secure boot status

Secure Boot can prevent unsigned kernel modules from loading:

```bash
mokutil --sb-state
```

If Secure Boot is enabled, you may need to:
- Disable Secure Boot in BIOS/UEFI, OR
- Sign the kernel module (advanced)

---

## Browser-Specific Issues

### Camera Works in Cheese but Not in Web Browsers

This is usually related to video pipeline compatibility.

#### Chromium/Chrome/Edge

Install PipeWire V4L2 compatibility:

```bash
sudo apt install pipewire-v4l2
```

Restart the browser completely (close all windows and background processes):

```bash
killall chrome
killall chromium
# Then reopen browser
```

#### Firefox

Firefox should work without additional packages. If not:

1. Check Firefox permissions:
   ```bash
   # In Firefox, visit: about:preferences#privacy
   # Under "Permissions" → "Camera", ensure it's not blocked
   ```

2. Clear browser cache and restart

3. Test in a new Firefox profile:
   ```bash
   firefox -P
   ```

#### Testing in Browser

Visit: https://webcamtests.com/

This will show if your browser can access the camera.

---

## Kernel Update Issues

### Symptoms

- Camera worked before kernel update
- Driver no longer loads after `apt upgrade`
- DKMS rebuild failed

### Solutions

#### Automatic rebuild

```bash
sudo dkms autoinstall
```

This should rebuild modules for all installed kernels.

#### Manual rebuild

```bash
# Check DKMS status
dkms status

# Remove old build
sudo dkms remove facetimehd/0.1 --all

# Reinstall
cd /usr/src/facetimehd-driver
sudo make dkms

# Verify
dkms status
```

#### If autoinstall fails

Install kernel headers for the new kernel:

```bash
sudo apt install linux-headers-$(uname -r)
```

Then rerun:

```bash
sudo dkms autoinstall
```

#### Reboot after rebuild

```bash
sudo reboot
```

---

## Permission Issues

### Symptoms

- "Permission denied" when accessing camera
- Camera works as root but not as user
- Applications can't open `/dev/video0`

### Solutions

#### Add user to video group

```bash
sudo usermod -aG video $USER
```

**Important**: Log out and log back in for group changes to take effect.

#### Check device permissions

```bash
ls -l /dev/video*
```

Should show:
```
crw-rw----+ 1 root video 81, 0 Jan 1 12:00 /dev/video0
```

#### Manually set permissions (temporary)

```bash
sudo chmod 666 /dev/video0
```

This is temporary and will reset on reboot. The proper solution is adding your user to the `video` group.

---

## Firmware Problems

### Symptoms

- Driver loads but camera doesn't work
- Errors about missing firmware in `dmesg`
- Camera device appears but produces no image

### Solutions

#### Verify firmware presence

```bash
ls -la /lib/firmware/facetimehd/firmware.bin
```

#### Re-download firmware

```bash
cd /tmp
curl -L -o firmware.bin https://github.com/patjak/facetimehd-firmware/raw/master/firmware.bin
sudo mkdir -p /lib/firmware/facetimehd
sudo cp firmware.bin /lib/firmware/facetimehd/firmware.bin
sudo chmod 644 /lib/firmware/facetimehd/firmware.bin
```

#### Reload driver after firmware install

```bash
sudo modprobe -r facetimehd
sudo modprobe facetimehd
```

#### Check firmware loading in logs

```bash
dmesg | grep -i firmware
```

---

## Performance Issues

### Symptoms

- Low frame rate
- Laggy video
- High CPU usage
- Poor image quality

### Solutions

#### Check video format

```bash
v4l2-ctl --list-formats-ext
```

Try setting a specific format:

```bash
v4l2-ctl --set-fmt-video=width=1280,height=720,pixelformat=YUYV
```

#### Reduce resolution

Lower resolutions use less CPU:
- 1280×720 (HD) – Good balance
- 640×480 (VGA) – Better performance

Configure in your video application.

#### Check system resources

```bash
top
# Look for high CPU usage

htop
# More detailed view
```

#### Disable hardware acceleration (paradoxically can help)

In Chrome/Chromium:
1. Go to `chrome://settings`
2. Search for "hardware acceleration"
3. Toggle off
4. Restart browser

---

## Advanced Diagnostics

### Full system check

```bash
# Kernel version
uname -r

# Driver status
lsmod | grep facetimehd

# DKMS status
dkms status

# Device presence
v4l2-ctl --list-devices

# Firmware
ls -la /lib/firmware/facetimehd/

# Kernel messages
dmesg | grep -i "facetimehd\|bcwc"

# Video device permissions
ls -l /dev/video*

# User groups
groups
```

### Enable debug logging

```bash
# Load module with debug output
sudo modprobe -r facetimehd
sudo modprobe facetimehd debug=1

# Check logs
dmesg | grep facetimehd
```

---

## Getting Help

If none of these solutions work:

1. **Gather diagnostic information**:
   ```bash
   # Save to a file
   {
     echo "=== System Info ==="
     uname -a
     lsb_release -a
     echo ""
     echo "=== DKMS Status ==="
     dkms status
     echo ""
     echo "=== Loaded Modules ==="
     lsmod | grep -E "facetimehd|uvcvideo|bcwc"
     echo ""
     echo "=== Video Devices ==="
     v4l2-ctl --list-devices
     ls -la /dev/video*
     echo ""
     echo "=== Firmware ==="
     ls -la /lib/firmware/facetimehd/
     echo ""
     echo "=== Kernel Messages ==="
     dmesg | grep -i "facetimehd\|bcwc"
   } > ~/facetimehd-debug.txt
   ```

2. **Open an issue** on GitHub with:
   - MacBook model (`sudo dmidecode -s system-product-name`)
   - The contents of `~/facetimehd-debug.txt`
   - Description of what you tried

3. **Search existing issues** first – your problem may already have a solution

---

## Known Limitations

- Camera quality may not match macOS performance
- Some video effects/filters may not work
- 60fps capture not supported on all models
- IR sensor not functional
- Some applications may have compatibility issues

---

## Additional Resources

- [facetimehd GitHub](https://github.com/patjak/facetimehd)
- [V4L2 Documentation](https://www.kernel.org/doc/html/latest/userspace-api/media/v4l/v4l2.html)
- [DKMS Documentation](https://github.com/dell/dkms)
- [Ubuntu Community Help](https://help.ubuntu.com/)
