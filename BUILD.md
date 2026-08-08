# Build Instructions - TWRP for Motorola Edge 40 Neo

## Quick Summary

```bash
# 1. Prepare environment
sudo apt-get update
sudo apt-get install -y git-core gnupg flex bison build-essential zip curl \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
    xsltproc unzip fontconfig

# 2. Set up repo
mkdir -p ~/.bin
export PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo

# 3. Download TWRP source code
mkdir -p ~/twrp && cd ~/twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all)

# 4. Add device tree
mkdir -p device/motorola
cp -r /path/to/this/device/tree device/motorola/manaus

# 5. Build
source build/envsetup.sh
lunch twrp_manaus-eng
mka vendorbootimage -j$(nproc --all)

# 6. Output files
# out/target/product/manaus/vendor_boot.img
# out/target/product/manaus/recovery.img
```

## Kernel Preparation (Important!)

Before building, you need the kernel files:

### 1. Extract from original firmware

```bash
# Extract kernel from original boot.img
magiskboot unpack boot.img
# Copy: kernel -> device/motorola/manaus/prebuilt/Image
# Copy: dtb -> device/motorola/manaus/prebuilt/dtb.img

# Extract dtbo from original dtbo.img
# Copy: dtbo -> device/motorola/manaus/prebuilt/dtbo.img
```

### 2. Or use a prebuilt kernel

Download a kernel compatible with the Edge 40 Neo and place it in:
- `prebuilt/Image` - Kernel Image
- `prebuilt/dtb.img` - Device Tree Blob
- `prebuilt/dtbo.img` - Device Tree Blob Overlay

## Build Commands

### Full build
```bash
source build/envsetup.sh
lunch twrp_manaus-eng
mka vendorbootimage -j8
```

### Recovery-only build
```bash
mka recoveryimage -j8
```

### Clean build
```bash
make clean
mka vendorbootimage -j8
```

### Build with detailed logs
```bash
mka vendorbootimage -j8 2>&1 | tee build.log
```

## Build Error Troubleshooting

### Error: "No rule to make target 'vendorbootimage'"
```bash
# Use recoveryimage instead of vendorbootimage
mka recoveryimage -j8
```

### Error: "Cannot find kernel config"
```bash
# Check that TARGET_PREBUILT_KERNEL points to an existing file
ls -la device/motorola/manaus/prebuilt/Image
```

### Error: "DTB not found"
```bash
# Check that the DTB exists
ls -la device/motorola/manaus/prebuilt/dtb.img
```

### Error: "Out of memory"
```bash
# Reduce the number of threads
mka vendorbootimage -j4

# Or increase swap
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Build Verification

After building, check the files:

```bash
# Check vendor_boot.img
ls -lh out/target/product/manaus/vendor_boot.img
file out/target/product/manaus/vendor_boot.img

# Extract and check contents
cd out/target/product/manaus
magiskboot unpack vendor_boot.img
ls -la

# Check ramdisk
cd ramdisk.cpio
cpio -ivt < ../ramdisk.cpio 2>/dev/null | head -20
```

## Installing the Build

### Via Fastboot
```bash
# Reboot into fastboot
adb reboot bootloader

# Flash vendor_boot
fastboot flash vendor_boot out/target/product/manaus/vendor_boot.img

# Reboot into recovery
fastboot reboot recovery
```

## Tips

1. **Always back up** the original vendor_boot before flashing
2. **Test with temporary boot** first before flashing permanently
3. **Keep the kernel updated** with security patches
4. **Check the logs** if something goes wrong: `adb logcat` or `fastboot oem get_logs`

## Important Files

- `BoardConfig.mk` - Main device configuration
- `device.mk` - Product configuration
- `init.recovery.mt6879.rc` - Recovery init script
- `recovery.fstab` - Partition table
- `prebuilt/` - Kernel, DTB and DTBO
