#!/system/bin/sh
#
# postrecoveryboot.sh
# Post Recovery Boot Script for Motorola Edge 40 Neo
# MediaTek MT6879

set -e

LOG_TAG="PostRecoveryBoot"

log_msg() {
    echo "[${LOG_TAG}] $1"
    echo "[${LOG_TAG}] $1" > /dev/kmsg 2>/dev/null || true
}

main() {
    log_msg "Starting post recovery boot sequence"
    
    # Set USB configuration
    setprop sys.usb.config mtp,adb
    
    # Ensure ADB is enabled
    start adbd
    
    # Set display brightness
    echo 1200 > /sys/class/leds/lcd-backlight/brightness 2>/dev/null || \
    echo 1200 > /sys/class/backlight/panel0-backlight/brightness 2>/dev/null || true
    
    log_msg "Post recovery boot sequence completed"
    return 0
}

main "$@"
exit 0
