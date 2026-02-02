# Contributing to FaceTime HD Camera for Linux

Thank you for your interest in contributing! ❤️

This project aims to make the Apple FaceTime HD camera work reliably on Linux while keeping the installation process:

- **Simple** – Easy for beginners to use
- **Reproducible** – Works consistently across systems
- **Safe** – Non-destructive and reversible
- **Maintainable** – Clean code that's easy to update

---

## Table of Contents

1. [Ways to Contribute](#ways-to-contribute)
2. [Reporting Issues](#reporting-issues)
3. [Development Setup](#development-setup)
4. [Code Guidelines](#code-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Testing](#testing)
7. [Documentation](#documentation)

---

## Ways to Contribute

There are many ways to help improve this project:

### Code Contributions
- Fix bugs in installation scripts
- Add support for new MacBook models
- Improve error handling
- Optimize performance
- Add new features

### Testing
- Test on different MacBook models
- Verify compatibility with new Ubuntu releases
- Test with different Linux kernels
- Validate on other Debian-based distributions

### Documentation
- Improve installation instructions
- Add troubleshooting tips
- Write tutorials or guides
- Translate documentation
- Fix typos and grammar

### Community Support
- Answer questions in issues
- Help troubleshoot problems
- Share your experience
- Write blog posts or tutorials

---

## Reporting Issues

Good bug reports help us fix problems quickly. When opening an issue, please include:

### Required Information

```bash
# MacBook model
sudo dmidecode -s system-product-name

# Ubuntu version
lsb_release -a

# Kernel version
uname -r

# DKMS status
dkms status

# Module status
lsmod | grep facetimehd

# Video devices
v4l2-ctl --list-devices
ls -la /dev/video*

# Firmware status
ls -la /lib/firmware/facetimehd/

# Recent kernel messages
dmesg | grep -i "facetimehd\|bcwc" | tail -20
```

### Issue Template

```markdown
## Description
[Clear description of the problem]

## Expected Behavior
[What you expected to happen]

## Actual Behavior
[What actually happened]

## System Information
- MacBook Model: 
- Ubuntu Version: 
- Kernel Version: 
- Installation Method: [fresh install / upgrade]

## Steps to Reproduce
1. 
2. 
3. 

## Diagnostic Output
[Paste output from diagnostic commands above]

## Additional Context
[Any other relevant information]
```

---

## Development Setup

### Prerequisites

- Ubuntu 22.04 or 24.04 (or compatible Debian-based distro)
- Git installed
- Supported MacBook hardware (or VM for script testing)

### Clone and Setup

```bash
# Fork the repository on GitHub first

# Clone your fork
git clone https://github.com/YOUR_USERNAME/facetimehd-ubuntu-macbook.git
cd facetimehd-ubuntu-macbook

# Add upstream remote
git remote add upstream https://github.com/godwill1224/facetimehd-ubuntu-macbook.git

# Create a branch for your work
git checkout -b feature/your-feature-name
```

### Testing Changes

Always test your changes before submitting:

```bash
# Test installation script (dry run if possible)
sudo bash -x scripts/install.sh

# Test uninstallation
sudo bash -x scripts/uninstall.sh

# Verify no system changes
dkms status
ls /lib/firmware/facetimehd/
```

---

## Code Guidelines

### Shell Script Standards

All scripts should follow these conventions:

#### Script Header

```bash
#!/usr/bin/env bash
#
# Brief description of what the script does
#

set -e  # Exit on error
```

#### Best Practices

1. **Error Handling**
   ```bash
   # Always check command success
   if ! command; then
       print_error "Command failed"
       exit 1
   fi
   ```

2. **User Feedback**
   ```bash
   # Use colored output for clarity
   print_info "Informational message"
   print_warn "Warning message"
   print_error "Error message"
   ```

3. **Idempotency**
   ```bash
   # Scripts should be safe to run multiple times
   if [ -d "$DIR" ]; then
       print_warn "Already exists, skipping..."
   else
       mkdir -p "$DIR"
   fi
   ```

4. **Root Check**
   ```bash
   # Always verify root privileges when needed
   if [ "$EUID" -ne 0 ]; then
       print_error "Please run as root"
       exit 1
   fi
   ```

5. **Variable Naming**
   ```bash
   # Use descriptive, uppercase names for constants
   FIRMWARE_URL="https://example.com/firmware.bin"
   INSTALL_DIR="/usr/src/driver"
   
   # Use descriptive lowercase for local variables
   local temp_file="/tmp/download.bin"
   ```

6. **Comments**
   ```bash
   # Explain non-obvious operations
   # Remove old module before installing new one
   modprobe -r facetimehd 2>/dev/null || true
   ```

### Avoiding Destructive Operations

Never include operations that:
- ❌ Delete system files outside project scope
- ❌ Modify core kernel configurations
- ❌ Break stock Ubuntu installations
- ❌ Require manual recovery if failed
- ❌ Leave system in broken state on error

Always include operations that:
- ✅ Can be safely reversed
- ✅ Backup before modifying
- ✅ Verify before deleting
- ✅ Provide clear error messages
- ✅ Leave system bootable if interrupted

---

## Pull Request Process

### Before Submitting

1. **Test thoroughly** on actual hardware
2. **Update documentation** if behavior changes
3. **Follow code style** guidelines
4. **Write clear commit messages**
5. **Rebase on latest main** branch

### Commit Message Format

Use clear, descriptive commit messages:

```
type: brief description

Longer explanation if needed.

Fixes #123
```

**Types:**
- `fix:` Bug fixes
- `feat:` New features
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `test:` Testing improvements
- `chore:` Maintenance tasks

**Examples:**
```
fix: handle missing firmware path gracefully

feat: add support for MacBookPro12,1

docs: improve troubleshooting section for Chromium

refactor: simplify module loading logic
```

### PR Description Template

```markdown
## Description
[Clear description of changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Other (please describe)

## Testing
- [ ] Tested on hardware: [MacBook model]
- [ ] Tested on Ubuntu: [version]
- [ ] Tested installation script
- [ ] Tested uninstallation script
- [ ] Verified no system breakage

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No destructive operations added
- [ ] Tested on actual hardware
- [ ] Commit messages are clear

## Related Issues
Fixes #[issue number]
```

### Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, PR will be merged
4. Your contribution will be credited in CHANGELOG

---

## Testing

### Manual Testing Checklist

Before submitting code:

- [ ] Fresh install works
- [ ] Upgrade from previous version works
- [ ] Uninstall completely removes everything
- [ ] Camera functional after reboot
- [ ] Works with Cheese
- [ ] Works with web browsers (Chrome, Firefox)
- [ ] Survives kernel update
- [ ] DKMS auto-rebuild works
- [ ] No errors in `dmesg`
- [ ] No broken dependencies

### Test Environments

Priority testing platforms:
1. Ubuntu 24.04 LTS with kernel 6.x
2. Ubuntu 22.04 LTS with kernel 6.x
3. MacBookPro11,x models (2013-2015)

---

## Documentation

### Documentation Standards

When updating documentation:

- Use clear, simple language
- Include code examples
- Provide step-by-step instructions
- Test all commands before documenting
- Keep formatting consistent
- Update table of contents if needed

### Files to Update

When making changes, consider updating:

- **README.md** – Main project overview
- **TROUBLESHOOTING.md** – Known issues and solutions
- **POWER.md** – Power management specifics
- **CHANGELOG.md** – Version history
- **CONTRIBUTING.md** (this file) – Contribution process

---

## Credits and Attribution

This project builds upon the excellent work of:

- **patjak** – [facetimehd driver](https://github.com/patjak/facetimehd)
- **TLP developers** – [Power management](https://linrunner.de/tlp/)
- **Linux kernel team** – V4L2 subsystem

When contributing, respect these projects and their licenses.

---

## Questions?

- **General questions**: Open a [GitHub Discussion](https://github.com/godwill1224/facetimehd-ubuntu-macbook/discussions)
- **Bug reports**: Open an [Issue](https://github.com/godwill1224/facetimehd-ubuntu-macbook/issues)
- **Feature requests**: Open an [Issue](https://github.com/godwill1224/facetimehd-ubuntu-macbook/issues) with `[Feature Request]` tag

---

## Code of Conduct

### Our Standards

- Be respectful and welcoming
- Be patient with beginners
- Focus on what's best for the community
- Show empathy towards others
- Accept constructive criticism gracefully

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information
- Other unprofessional conduct

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to make Linux better for MacBook users! 🎉
