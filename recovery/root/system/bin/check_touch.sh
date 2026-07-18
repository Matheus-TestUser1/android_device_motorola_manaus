#!/system/bin/sh

LOG="/tmp/touch_debug.log"

exec >"$LOG" 2>&1

echo "========================================"
echo " Motorola Edge 40 Neo (manaus)"
echo " TWRP Touch Debug"
echo "========================================"
date
echo

echo "===== Kernel ====="
uname -a
echo

echo "===== Android Properties ====="
getprop | grep -Ei "boot|slot|hardware|board|product|recovery"
echo

echo "===== Mounted Partitions ====="
mount
echo

echo "===== Loaded Modules ====="
cat /proc/modules
echo

echo "===== Touch Modules ====="
cat /proc/modules | grep -Ei "goodix|touch|brl|mmi|spi|pinctrl"
echo

echo "===== SPI Bus ====="
ls -lR /sys/bus/spi 2>/dev/null
echo

echo "===== SPI Devices ====="
ls -l /sys/bus/spi/devices 2>/dev/null
echo

echo "===== SPI Drivers ====="
ls -l /sys/bus/spi/drivers 2>/dev/null
echo

echo "===== I2C Bus ====="
ls -lR /sys/bus/i2c 2>/dev/null
echo

echo "===== Regulators ====="
find /sys/class/regulator -maxdepth 2 2>/dev/null
echo

echo "===== Search vtouch ====="
find /sys -iname "*vtouch*" 2>/dev/null
echo

echo "===== Device Tree ====="
find /proc/device-tree -iname "*goodix*" 2>/dev/null
find /proc/device-tree -iname "*touch*" 2>/dev/null
find /proc/device-tree -iname "*gt9916*" 2>/dev/null
find /proc/device-tree -iname "*spi*" 2>/dev/null
find /proc/device-tree -iname "*vtouch*" 2>/dev/null
echo

echo "===== GPIO ====="

if [ -d /sys/class/gpio ]; then
    for gpio in 159 22 167; do
        if [ -d "/sys/class/gpio/gpio$gpio" ]; then
            echo "GPIO $gpio"
            cat /sys/class/gpio/gpio$gpio/direction 2>/dev/null
            cat /sys/class/gpio/gpio$gpio/value 2>/dev/null
        else
            echo "GPIO $gpio : not exported"
        fi
    done
else
    echo "GPIO sysfs not present (gpiod kernel)"
fi

echo

echo "===== Input Devices ====="
ls -la /dev/input 2>/dev/null
echo
cat /proc/bus/input/devices 2>/dev/null
echo

echo "===== Goodix Device Nodes ====="
find /dev -iname "*goodix*" 2>/dev/null
echo

echo "===== Goodix SysFS ====="
find /sys -iname "*goodix*" 2>/dev/null
echo

echo "===== Firmware ====="
find /vendor/firmware -iname "*goodix*" 2>/dev/null
find /vendor/firmware -iname "*gt9*" 2>/dev/null
echo

echo "===== Interrupts ====="
grep -i goodix /proc/interrupts 2>/dev/null
grep -i spi /proc/interrupts 2>/dev/null
echo

echo "===== Kernel Log (Filtered) ====="
dmesg | grep -Ei \
"goodix|gt9916|touch|touchscreen|spi|gpio|gpiod|pinctrl|regulator|vtouch|probe|firmware|irq|failed|error"
echo

echo "===== Last 300 Kernel Messages ====="
dmesg | tail -300
echo

echo "========================================"
echo " End of Report"
echo " Log saved to $LOG"
echo "========================================"
