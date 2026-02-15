#
# Copyright (C) 2024 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/motorola/manaus
# Device specific overlays
DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/overlay

# ============================================================================
# A/B SUPPORT (CRÍTICO! NÃO REMOVA!)
# ============================================================================
# Habilita compressão de OTA e suporte A/B
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Recovery no vendor_boot com ramdisk separado (ESSENCIAL!)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# ============================================================================
# ANDROID 12+ SUPPORT
# ============================================================================
# Suporte a módulos APEX (Android 12+)
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Armazenamento emulado moderno (FUSE ao invés de SDCardFS)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# ============================================================================
# A/B OTA CONFIGURATION
# ============================================================================
AB_OTA_UPDATER := true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

# ============================================================================
# BOOT CONTROL HAL
# ============================================================================
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.boot@1.2-service \
    bootctrl.mt6879 \
    bootctrl.mt6879.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# ============================================================================
# CORE PACKAGES
# ============================================================================
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_engine_sideload \
    update_verifier \
    checkpoint_gc \
    fastbootd

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock

# Health HAL
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# MTK Specific
PRODUCT_PACKAGES += \
    mtk_plpath_utils \
    mtk_plpath_utils.recovery

# File System Tools
PRODUCT_PACKAGES += \
    e2fsck \
    resize2fs \
    tune2fs \
    fsck.f2fs \
    mkfs.f2fs

# ============================================================================
# RECOVERY FILES - CRITICAL FOR VENDOR_BOOT
# ============================================================================
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/etc/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/recovery.fstab \
    $(LOCAL_PATH)/recovery/root/system/etc/twrp.flags:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/twrp.flags \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt6879.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6879.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc \
    $(LOCAL_PATH)/recovery/root/mtk-plpath-utils.rc:$(TARGET_COPY_OUT_RECOVERY)/root/mtk-plpath-utils.rc \
    $(LOCAL_PATH)/recovery/root/ueventd.rc:$(TARGET_COPY_OUT_RECOVERY)/root/ueventd.rc \
    $(LOCAL_PATH)/recovery/root/sbin/postrecoveryboot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/sbin/postrecoveryboot.sh
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/dtb.img:dtb.img \
   # $(DEVICE_PATH)/prebuilt/dtbo.img:dtbo.img
# Recovery binários MediaTek
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/system/bin/plpath_utils:recovery/root/system/bin/plpath_utils
# ============================================================================
# SYSTEM PROPERTIES
# ============================================================================
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.device=manaus \
    ro.product.name=manaus \
    ro.build.product=manaus \
    ro.hardware=mt6879 \
    ro.board.platform=mt6879 \
    sys.usb.controller=11201000.usb0 \
    sys.usb.ffs.aio_compat=true \
    ro.adb.secure=0 \
    persist.sys.usb.config=mtp,adb \
    ro.boot.dynamic_partitions=true \
    ro.boot.bootdevice=bootdevice

# ============================================================================
# SOONG NAMESPACES
# ============================================================================
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)
