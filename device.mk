#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/motorola/manaus

# ============================================================================
# A/B OTA CONFIG
# ============================================================================
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# ============================================================================
# BOOT CONTROL HAL (CORRIGIDO: mt6879, não mt6895!)
# ============================================================================
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-service \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-impl.recovery \
    bootctrl.mt6879 \
    bootctrl.mt6879.recovery \
    bootctrl

PRODUCT_SHIPPING_API_LEVEL := 33  # Android 13

PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier

# ============================================================================
# KERNEL & RECOVERY_RAMDISK (VENDOR_BOOT V4)
# ============================================================================

# Kernel (from boot.img stock)
TARGET_PREBUILT_KERNEL := $(LOCAL_PATH)/prebuilt/Image

# DTB (from vendor_boot stock)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/dtb:$(TARGET_COPY_OUT_RECOVERY)/root/prebuilt/dtb

# DTBO (from stock)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/dtbo.img:$(TARGET_COPY_OUT_RECOVERY)/root/prebuilt/dtbo.img

# ✅ RECOVERY_RAMDISK (from vendor_boot stock - TWRP will inject binaries here)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/ramdisk.cpio:$(TARGET_COPY_OUT_RECOVERY)/root/prebuilt/ramdisk.cpio

# ============================================================================
# RECOVERY INIT SCRIPTS
# ============================================================================
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt6879.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6879.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc

# ============================================================================
# RECOVERY BINARIES & RESOURCES (TWRP INJECTION)
# ============================================================================

# TWRP resources (serão injetados no ramdisk.cpio durante o build)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/sbin/postrecoveryboot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/sbin/postrecoveryboot.sh

# TWRP theme and graphics
# PRODUCT_COPY_FILES += \
#     $(LOCAL_PATH)/recovery/root/res/images:$(TARGET_COPY_OUT_RECOVERY)/root/res/images

# ============================================================================
# SYSTEM PROPERTIES
# ============================================================================
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.device=manaus \
    ro.product.name=manaus \
    ro.build.product=manaus \
    ro.twrp.device=manaus \
    ro.hardware=mt6879 \
    ro.hardware.platform=mt6879 \
    ro.board.platform=mt6879

# TWRP properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.twrp.boot=true \
    ro.twrp.version=3.7.0_12 \
    twrp.version=3.7.0_12

# Disable encryption in recovery
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.state=unsupported \
    ro.crypto.type=none

# MediaTek properties (CORRIGIDO: Android 13)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.mediatek.platform=MT6879 \
    ro.mediatek.chip_ver=S01 \
    ro.mediatek.version.release=13 \
    ro.mediatek.version.sdk=4

# Debug properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.debuggable=1 \
    ro.secure=0 \
    ro.adb.secure=0 \
    persist.sys.usb.config=mtp,adb \
    persist.service.adb.enable=1 \
    persist.service.debuggable=1

# USB properties (CORRIGIDO: controller do MT6879)
PRODUCT_PROPERTY_OVERRIDES += \
    sys.usb.controller=11201000.usb0 \
    sys.usb.ffs.aio_compat=true

# Disable APEX in recovery (causes issues)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.apex.updatable=false

# Heap limits
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m
