# Changelog - TWRP for Motorola Edge 40 Neo

All notable changes in this project will be documented in this file.

## [1.0.0] - 2024-02-09

### Added
- Full vendor_boot support for TWRP booting
- Kernel module configuration for vendor ramdisk
- Optimized boot files for vendor_boot
- Dynamic partition (super) support
- EROFS support
- Working USB/ADB configuration
- MTP support
- Post-recovery-boot scripts

### Fixed
- **Critical Issue**: TWRP was not booting into traditional recovery mode
- Correct configuration of `BOARD_USES_VENDOR_BOOTIMAGE`
- Configuration of `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT`
- fstab with support for first_stage_mount
- init.rc with correct module loading
- Dynamic partitions configuration

### Modified
- `BoardConfig.mk` - Complete configuration for vendor_boot
- `device.mk` - Optimized packages and properties
- `init.recovery.mt6879.rc` - Initialization for vendor_boot
- `init.recovery.usb.rc` - Improved USB configuration
- `recovery.fstab` - Corrected partition table
- `twrp.flags` - Optimized flags for TWRP GUI
- `system.prop` - Updated system properties
- `vendor.prop` - Updated vendor properties

### Technical Notes
- TWRP now boots correctly via vendor_boot
- No longer stuck in traditional recovery mode
- A/B partition support working
- Dynamic partitions mapped correctly
## [0.9.0] - 2024-02-08

### Added
- Initial device tree structure
- Basic configuration files
- Prebuilt kernel
- Initial support for MT6879


### Known Issues
- TWRP remained in traditional recovery mode
- vendor_boot did not function correctly
- Dynamic partitions did not mount

### Legend
- **Added** for new features.
- **Modified** for changes to existing features.
- **Fixed** for bug fixes.
- **Removed** for removed features.
- **Security** for security vulnerabilities.
