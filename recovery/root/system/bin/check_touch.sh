#!/system/bin/sh

LOG="/tmp/touch_debug.log"
echo "=== Edge 40 Neo Touch Debug ===" > $LOG
echo "$(date)" >> $LOG
echo "" >> $LOG

# 1. Módulos carregados
echo "=== Loaded Modules ===" >> $LOG
lsmod >> $LOG 2>&1
echo "" >> $LOG

# 2. Verificar se os módulos do touch estão carregados
echo "=== Touch Modules ===" >> $LOG
lsmod | grep -E "touchscreen|goodix|brl|mmi" >> $LOG 2>&1
echo "" >> $LOG

# 3. GPIOs
echo "=== GPIO Status ===" >> $LOG
for gpio in 159 22 167; do
    if [ -d "/sys/class/gpio/gpio$gpio" ]; then
        echo "GPIO $gpio: value=$(cat /sys/class/gpio/gpio$gpio/value), dir=$(cat /sys/class/gpio/gpio$gpio/direction)" >> $LOG
    else
        echo "GPIO $gpio: NOT EXPORTED" >> $LOG
    fi
done
echo "" >> $LOG

# 4. Input devices
echo "=== Input Devices ===" >> $LOG
ls -la /dev/input/ >> $LOG 2>&1
echo "" >> $LOG
cat /proc/bus/input/devices >> $LOG 2>&1
echo "" >> $LOG

# 5. Kernel messages
echo "=== dmesg (goodix/touch) ===" >> $LOG
dmesg | grep -iE "goodix|touchscreen|brl|mmi|spi" | tail -50 >> $LOG 2>&1
echo "" >> $LOG

# 6. SPI devices
echo "=== SPI Bus ===" >> $LOG
ls -la /sys/bus/spi/devices/ >> $LOG 2>&1
echo "" >> $LOG

# 7. Verificar se o driver criou o dispositivo
echo "=== Goodix Device Check ===" >> $LOG
find /sys/bus/spi/devices/ -name "*goodix*" >> $LOG 2>&1
find /sys/bus/i2c/devices/ -name "*goodix*" >> $LOG 2>&1
echo "" >> $LOG

# 8. Firmware files
echo "=== Firmware Files ===" >> $LOG
ls -la /vendor/firmware/*goodix* >> $LOG 2>&1
echo "" >> $LOG

# 9. Se não detectou, tentar resetar
if ! grep -q "goodix" /proc/bus/input/devices 2>/dev/null; then
    echo "WARNING: Goodix not detected! Attempting reset..." >> $LOG
    echo 0 > /sys/class/gpio/gpio159/value
    sleep 0.05
    echo 1 > /sys/class/gpio/gpio159/value
    sleep 0.3
    echo "Reset done" >> $LOG
fi

echo "=== End ===" >> $LOG
