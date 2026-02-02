# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Support for additional MacBook models (2016-2017)
- GUI installer option
- Automatic driver updates check
- Integration with system package managers

---

## [1.0.0] - 2026-02-02

### Added
- Initial stable release
- Automated installation script (`install.sh`)
- Automated uninstallation script (`uninstall.sh`)
- Power management optimization script (`power-tune.sh`)
- DKMS integration for automatic kernel update handling
- Firmware automatic download and installation
- Comprehensive troubleshooting documentation
- Power management guide
- Contributing guidelines
- MIT License
- README with full documentation
- Support for Ubuntu 22.04 LTS
- Support for Ubuntu 24.04 LTS
- Support for Linux kernel 6.x series
- Support for MacBookPro11,1 (13-inch, Late 2013)
- Support for MacBookPro11,2 (15-inch, Late 2013)
- Support for MacBookPro11,3 (15-inch, Late 2013)
- Support for MacBookPro 2014-2015 models with FaceTime HD camera
- Colored terminal output for better user experience
- Comprehensive error handling in all scripts
- Pre-installation dependency checks
- Post-installation verification
- TLP power management integration
- MacBook-optimized power profiles

### Changed
- Migrated from manual compilation to DKMS-based installation
- Improved script reliability with proper error handling
- Enhanced user feedback with colored output
- Streamlined firmware installation process

### Fixed
- Race conditions during module loading
- Firmware download failures on slow connections
- Permission issues with camera device access
- Module not loading after kernel updates
- Conflicts with default power management services

### Security
- Firmware verification before installation
- Secure download over HTTPS
- Proper file permissions for firmware files
- No root password storage or caching

---

## [0.2.0] - 2025-12-15 (Pre-release)

### Added
- Basic DKMS support
- Firmware extraction script
- Ubuntu 22.04 compatibility testing

### Changed
- Refactored installation process
- Improved error messages

### Fixed
- Build failures on newer kernels
- Missing dependencies detection

---

## [0.1.0] - 2025-11-01 (Initial Development)

### Added
- Basic manual installation instructions
- Driver source integration
- Proof of concept on Ubuntu 20.04
- Initial documentation

### Known Issues
- Manual compilation required
- No automatic kernel update handling
- Limited error handling
- Firmware extraction requires manual steps

---

## Version History Summary

- **1.0.0** - First stable release with full automation
- **0.2.0** - Pre-release with DKMS support
- **0.1.0** - Initial development version

---

## Links

- [Repository](https://github.com/godwill1224/facetimehd-ubuntu-macbook)
- [Issue Tracker](https://github.com/godwill1224/facetimehd-ubuntu-macbook/issues)
- [Upstream Driver](https://github.com/patjak/facetimehd)

---

## Migration Guides

### From 0.x to 1.0.0

If you installed a pre-release version manually:

1. Remove old installation:
   ```bash
   sudo modprobe -r facetimehd
   sudo rm -rf /usr/src/facetimehd*
   sudo rm -rf /lib/firmware/facetimehd
   ```

2. Install 1.0.0:
   ```bash
   git clone https://github.com/godwill1224/facetimehd-ubuntu-macbook.git
   cd facetimehd-ubuntu-macbook
   sudo ./scripts/install.sh
   ```

3. Reboot your system

---

## Deprecations

None in current version.

---

## Contributors

Thank you to everyone who has contributed to this project:

- Initial packaging and automation
- Testing on various MacBook models
- Documentation improvements
- Bug reports and fixes

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute.
