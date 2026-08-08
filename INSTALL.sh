#!/bin/bash
#
# Automatic TWRP installation script for Motorola Edge 40 Neo
# Use: ./INSTALL.sh [path/vendor_boot.img]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
DEVICE_CODENAME="manaus"
DEVICE_NAME="Motorola Edge 40 Neo"
VENDOR_BOOT_IMG="${1:-vendor_boot.img}"

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "  TWRP Installer for $DEVICE_NAME"
    echo "  Codename: $DEVICE_CODENAME"
    echo "=========================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_dependencies() {
    print_info "Checking Dependencies..."
    
    if ! command -v adb &> /dev/null; then
        print_error "ADB not found. Install Android SDK."
        exit 1
    fi
    
    if ! command -v fastboot &> /dev/null; then
        print_error "Fastboot not found. Install Android SDK."
        exit 1
    fi
    
    print_success "Dependencies OK"
}

check_device() {
    print_info "Checking Device..."
    
    # Verify if device is connected
    DEVICE=$(adb devices | grep -v "List" | grep "device" | awk '{print $1}')
    if [ -z "$DEVICE" ]; then
        print_error "No device found. Please connect your device via ADB."
        exit 1
    fi;
    
    print_success "Device is Found: $DEVICE"
    
    # Verify codename
    CODENAME=$(adb shell getprop ro.product.device 2>/dev/null || echo "unknown")
    if [ "$CODENAME" != "$DEVICE_CODENAME" ]; then
        print_warning "Codename Device: $CODENAME"
        print_warning "Wait: $DEVICE_CODENAME"
        read -p "Continue Anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "Device Checked: $CODENAME"
}

check_image() {
    print_info "Checking image..."
    
    if [ ! -f "$VENDOR_BOOT_IMG" ]; then
        print_error "Image not Found: $VENDOR_BOOT_IMG"
        print_info "Use: $0 [path/vendor_boot.img]"
        exit 1
    fi
    
    print_success "Image found: $VENDOR_BOOT_IMG"
}

backup_original() {
    print_info "Attempting to back up original vendor_boot..."
    
    BACKUP_DIR="twrp_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    adb reboot bootloader
    sleep 5
    
    fastboot getvar current-slot 2>&1 | tee "$BACKUP_DIR/slot_info.txt"
    fastboot oem get_logs 2>&1 | tee "$BACKUP_DIR/logs.txt" || true
    
    # Best-effort real image dump. Most locked retail bootloaders don't
    # implement "fetch", even though the host fastboot binary supports
    # issuing it — so this can legitimately fail. If it does, be honest
    # about it instead of pretending a real backup exists.
    if fastboot fetch:vendor_boot "$BACKUP_DIR/vendor_boot_original.img" 2>"$BACKUP_DIR/fetch_error.txt"; then
        print_success "Original vendor_boot.img saved to: $BACKUP_DIR/vendor_boot_original.img"
        print_info "To restore later: fastboot flash vendor_boot $BACKUP_DIR/vendor_boot_original.img"
    else
        rm -f "$BACKUP_DIR/vendor_boot_original.img" 2>/dev/null
        print_warning "This bootloader doesn't support pulling the partition image (fastboot fetch)."
        print_warning "No flashable backup was created — only slot info and logs were saved in: $BACKUP_DIR"
        print_warning "If something goes wrong, you'll need the stock vendor_boot from Motorola's official firmware for this device."
    fi
}

flash_image() {
    print_info "Flashing vendor_boot..."
    
    fastboot flash vendor_boot "$VENDOR_BOOT_IMG"
    
    print_success "vendor_boot flash Successful!"
}

reboot_recovery() {
    print_info "Restarting on recovery..."
    
    fastboot reboot recovery
    
    print_success "Restarting..."
}

boot_temp() {
    print_info "Temporary boot (for testing)..."
    
    adb reboot bootloader
    sleep 5
    
    fastboot boot "$VENDOR_BOOT_IMG"
    
    print_success "Temporary boot started!"
}

# Main menu
main() {
    print_header
    
    check_dependencies
    check_image
    
echo ""
echo "Choose an option:"
echo "1) Install TWRP (permanent flash)"
echo "2) Temporary boot (for testing only)"
echo "3) Exit"
echo ""
read -p "Option: " -n 1 -r

echo
    
    case $REPLY in
        1)
            check_device
            backup_original
            flash_image
            reboot_recovery
            ;;
        2)
            check_device
            boot_temp
            ;;
        3)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
    
echo ""
print_success "Installation complete!"
print_info "TWRP should start soon."
print_info "If you get stuck on the boot screen, force a restart."
}

# Execute
main "$@"
