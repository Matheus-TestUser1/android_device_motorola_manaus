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

#  POSTINSTALL WITH mtk_plpath_utils (SPECIFIC FOR MEDIATEK!)
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
# BOOT CONTROL HAL (A/B slot management)
# ============================================================================

#  Generic bootctrl only (fallback)
PRODUCT_PACKAGES += \
   bootctrl.default \
   bootctrl.default.recovery
# compatibility test 
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-mtkimpl \
    android.hardware.boot@1.2-mtkimpl.recovery 

PRODUCT_PACKAGES_DEBUG += \
    bootctl

#  BOOT HAL LIBS (MTK) - PREBUILT FROM STOCK - CRITICAL FOR A/B!
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.boot@1.0.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.1.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.boot@1.1.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.2.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.boot@1.2.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.0-impl-1.2-mtkimpl.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/android.hardware.boot@1.0-impl-1.2-mtkimpl.so

#  BOOT HAL SERVICE (MTK) - PREBUILT FROM STOCK
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/bin/hw/android.hardware.boot@1.2-service:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/android.hardware.boot@1.2-service


PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/bin/modprobe:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/modprobe

# Debug script
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/system/bin/check_touch.sh:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/check_touch.sh

# Copy prebuilt modules to recovery ramdisk
$(foreach module,$(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko),\
  $(eval PRODUCT_COPY_FILES += $(module):$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/$(notdir $(module))))

# modules.load.recovery + modules.dep: load manifest read automatically by
# first-stage init (GetModuleLoadList/LoadKernelModules) before partitions
# are mounted. Must live under root/lib/modules to match the .ko files above.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/modules/modules.load.recovery:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.load.recovery \
    $(DEVICE_PATH)/prebuilt/modules/modules.dep:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.dep


# ============================================================================
# VIRTUAL A/B — SNAPUSERD
# ============================================================================
PRODUCT_PACKAGES += \
    snapuserd \
    snapuserd.recovery

# ============================================================================
# MTK PATH UTILS - 2 LOCATIONS (CRITICAL!)
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
# Drm
PRODUCT_PACKAGES += \
    android.hardware.drm@1.4
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

# Firmware blobs (MediaTek/vendor) — every file under recovery/root/vendor/firmware/
# is copied 1:1 into the recovery ramdisk; no need to list each one by hand.
$(foreach fw,$(wildcard $(DEVICE_PATH)/recovery/root/vendor/firmware/*),\
  $(eval PRODUCT_COPY_FILES += $(fw):$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/$(notdir $(fw))))

# ============================================================================
# SOONG NAMESPACES
# ============================================================================
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)
