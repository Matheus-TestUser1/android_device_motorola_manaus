# Device Tree for Motorola Edge 40 Neo

TWRP Device Tree for the Motorola Edge 40 Neo (manaus)

Basic          | Spec Sheet
--------------:|:-------------------------
CPU            | Octa-core (2x2.5 GHz Cortex-A78 & 6x2.0 GHz Cortex-A55)
Chipset        | MediaTek Dimensity 7030 (MT6879), 6nm
GPU            | Mali-G610 MC3
Memory         | 8GB / 12GB LPDDR4X
Shipped Android version | 13
Storage        | 128GB / 256GB UFS (uMCP)
Battery        | 5000 mAh, non-removable, 68W wired charging
Display        | 6.55" P-OLED, 1080x2400, 144Hz, HDR10+
Rear Camera    | 50MP (OV50A, f/1.8, OIS) + 13MP ultrawide/macro
Front Camera   | 32MP
Release Date   | September 14, 2023

---

## Status

**Stable (v1.0)**

| Feature | Status |
|---|---|
| Boot / Display | Working |
| Touchscreen (Goodix gt9916S, SPI) | Working |
| ADB | Working |
| MTP | Working |
| Fastboot | Working |
| Sideload | Working |
| Backup / Restore | Working |
| Data decryption (recovery only) | Not yet implemented for compatibility |
| Fingerprint driver (Goodix FOD) | Loads, untested for full function |
| Battery percentage | Not yet displayed |
| CPU temperature | Not yet displayed |
| Vibration feedback | Not implemented |

---

## Device Specific Notes

### Boot layout
This device uses boot header v4 with a **dual ramdisk** `vendor_boot` image
(PLATFORM ramdisk + RECOVERY ramdisk combined). There is no separate
`/recovery` partition. Flashing TWRP means flashing `vendor_boot`, not `boot`.

```
fastboot flash vendor_boot vendor_boot.img
```

### Touchscreen
- Interface: **SPI** (confirmed via dtbo and kernel probe log — not I2C)
- Driver: `goodix_brl_mmi` (primary, gt9916S) with `focaltech_v3` as
  documented hardware alternate
- Module load order: `mmi_relay -> sensors_class -> mmi_info ->
  touchscreen_mmi -> goodix_brl_mmi`
- The kernel driver handles firmware version check and touchscreen class
  (`/sys/class/touchscreen/primary`) registration automatically on probe.
  No manual reset sequence or userspace firmware service is required.

### Partitions
`super` (dynamic partitions, Virtual A/B), A/B slots for `boot`,
`vendor_boot`, `vbmeta*`. MediaTek-specific raw partitions
(`protect_f`, `protect_s`, `nvdata`, `nvcfg`, `rescue`) are intentionally
excluded from `recovery.fstab` — not used by any TWRP function and removing
them avoids failed-mount noise and accidental exposure in the wipe menu.

### Encryption
Recovery-side `/data` decryption works by removing the `fileencryption`/
`encryptable` flag from the **recovery** fstab only. This does not affect
the stock ROM's own `/vendor/etc/fstab.mt6879`, which is untouched — the
running system will still apply its own encryption policy independently
of the recovery.

### Kernel
5.10 (GKI)

---

## Building

```bash
source build/envsetup.sh
lunch twrp_manaus-eng
mka vendorbootimage
```

Device tree depends on a matching kernel source and vendor blobs extracted
from stock firmware. See `BoardConfig.mk` for module and partition layout.

---

## Installing

1. Unlock bootloader (`fastboot flashing unlock`), if not already unlocked
2. `fastboot flash vendor_boot vendor_boot.img`
3. `fastboot reboot recovery`

---

## Contributing / Reporting Issues

Please include `dmesg` and `lsmod` output (via `adb shell` from within
TWRP) with any touchscreen, sensor, or module-loading related report.

---

## Credits

- TWRP / TeamWin
- MediaTek
- Motorola
- AOSP
- **Astral_Novah** — for contributing to this project
- **Xaga device tree** — used as reference for MediaTek Dimensity boot
  HAL service (`boot-hal-1-2`) and A/B compatibility handling

---

## Disclaimer

Flashing custom recovery may affect device warranty. Back up your data
before flashing. Provided as-is, no warranty of any kind.
