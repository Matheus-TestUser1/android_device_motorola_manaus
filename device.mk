#
# Copyright (C) 2024 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/motorola/manaus
DEVICE_PATH := device/motorola/manaus

# ============================================================================
# A/B SUPPORT
# ============================================================================
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# ============================================================================
# ANDROID 12+ SUPPORT
# ============================================================================
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_TARGET_VNDK_VERSION := 31

# ============================================================================
# A/B OTA CONFIGURATION
# ============================================================================
AB_OTA_UPDATER := true

# ⭐ POSTINSTALL COM mtk_plpath_utils (CRÍTICO PRO MEDIATEK!)
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/mtk_plpath_utils \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

# Virtual A/B properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.virtual_ab.enabled=true \
    ro.virtual_ab.compression.enabled=true \
    ro.virtual_ab.userspace.snapshots.enabled=true \
    ro.virtual_ab.retrofit=false

# ============================================================================
# BOOT CONTROL HAL (A/B slot management) - MTK Implementation
# ============================================================================
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-mtkimpl \
    android.hardware.boot@1.2-mtkimpl.recovery \
    android.hardware.boot@1.2-service 

PRODUCT_STATIC_BOOT_CONTROL_HAL := \
    bootctrl.mt6879 \
    libgptutils \
    libz \
    libcutils

PRODUCT_PACKAGES_DEBUG += \
    bootctl

PRODUCT_PACKAGES += \
    bootctrl.mt6879

# ============================================================================
# VIRTUAL A/B — SNAPUSERD
# ============================================================================
PRODUCT_PACKAGES += \
    snapuserd \
    snapuserd.recovery

# ============================================================================
# MTK PATH UTILS - 2 LOCAIS (CRÍTICO!)
# ============================================================================
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/bin/mtk_plpath_utils:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/mtk_plpath_utils \
    $(DEVICE_PATH)/prebuilt/bin/mtk_plpath_utils:$(TARGET_COPY_OUT_SYSTEM)/bin/mtk_plpath_utils

# ============================================================================
# CORE PACKAGES
# ============================================================================
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_engine_sideload \
    update_verifier \
    fastbootd

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl \
    android.hardware.fastboot@1.1-service

PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

PRODUCT_PACKAGES += \
    e2fsck \
    resize2fs \
    fsck.f2fs \
    mkfs.f2fs

# ============================================================================
# PREBUILT BINARIES (MediaTek)
# ============================================================================
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/dtb.img:dtb.img

# ============================================================================
# RECOVERY FILES
# ============================================================================
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/recovery.fstab \
    $(DEVICE_PATH)/recovery/root/system/etc/twrp.flags:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/twrp.flags \
    $(DEVICE_PATH)/recovery/root/init.recovery.mt6879.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6879.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc \
    $(DEVICE_PATH)/recovery/root/ueventd.rc:$(TARGET_COPY_OUT_RECOVERY)/root/ueventd.rc

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
