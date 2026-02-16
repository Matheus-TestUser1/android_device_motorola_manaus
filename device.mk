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
# A/B OTA CONFIGURATION - MEDIATEK MT6879 ESPECÍFICO
# ============================================================================
AB_OTA_UPDATER := true

# ⚠️ CORREÇÃO 1: EROFS é apenas leitura - usar EXT4 para postinstall
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
# BOOT CONTROL HAL (A/B SUPPORT) - MEDIATEK ESPECÍFICO
# ============================================================================
# ⚠️ CORREÇÃO 2: Usar bootctrl.mt6879 (não generic)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-impl.recovery \
    android.hardware.boot@1.2-service \
    bootctrl.mt6879 \
    bootctrl.mt6879.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# ============================================================================
# CORE PACKAGES - REMOVER DESNECESSÁRIOS
# ============================================================================
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_engine_sideload \
    update_verifier

# ⚠️ CORREÇÃO 3: checkpoint_gc é para Qualcomm, não MediaTek
# REMOVER checkpoint_gc

# fastbootd - OK
PRODUCT_PACKAGES += \
    fastbootd

PRODUCT_PACKAGES_DEBUG += \
    update_engine_client

# Fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock

# Health HAL (Required)
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# ⚠️ CORREÇÃO 4: MediaTek usa f2fs/ext4, não precisa de tune2fs em recovery
PRODUCT_PACKAGES += \
    e2fsck \
    resize2fs \
    fsck.f2fs \
    mkfs.f2fs

# ============================================================================
# MTK-SPECIFIC PACKAGES
# ============================================================================
PRODUCT_PACKAGES += \
    plpath_utils

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
    $(LOCAL_PATH)/recovery/root/sbin/init-ab-slots.sh:$(TARGET_COPY_OUT_RECOVERY)/root/sbin/init-ab-slots.sh \
    $(LOCAL_PATH)/recovery/root/sbin/setup-dynamic-partitions.sh:$(TARGET_COPY_OUT_RECOVERY)/root/sbin/setup-dynamic-partitions.sh \
    $(LOCAL_PATH)/recovery/root/sbin/check-dtb.sh:$(TARGET_COPY_OUT_RECOVERY)/root/sbin/check-dtb.sh \
    $(LOCAL_PATH)/recovery/root/sbin/postrecoveryboot.sh:$(TARGET_COPY_OUT_RECOVERY)/root/sbin/postrecoveryboot.sh

# Kernel Modules (prebuilt)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/modules.load:$(TARGET_COPY_OUT_RECOVERY)/root/modules.load \
    $(LOCAL_PATH)/prebuilt/modules/modules.dep:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.dep \
    $(LOCAL_PATH)/prebuilt/modules/modules.alias:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.alias \
    $(LOCAL_PATH)/prebuilt/modules/modules.softdep:$(TARGET_COPY_OUT_RECOVERY)/root/lib/modules/modules.softdep

# plpath_utils binary
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/bin/plpath_utils:$(TARGET_COPY_OUT_RECOVERY)/root/prebuilt/bin/plpath_utils

# ============================================================================
# SYSTEM PROPERTIES - MEDIATEK MT6879 ESPECÍFICO
# ============================================================================
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.device=manaus \
    ro.product.name=manaus \
    ro.build.product=manaus \
    ro.hardware=mt6879 \
    ro.board.platform=mt6879 \
    ro.mediatek.platform=MT6879 \
    ro.mediatek.version=2023 \
    sys.usb.controller=11201000.usb0 \
    sys.usb.ffs.aio_compat=true \
    ro.adb.secure=0 \
    persist.sys.usb.config=mtp,adb \
    ro.boot.dynamic_partitions=true \
    ro.boot.bootdevice=bootdevice \
    ro.boot.verifiedbootstate=orange

# A/B OTA Properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.virtual_ab.enabled=true \
    ro.virtual_ab.compression.enabled=true \
    ro.virtual_ab.retrofit=false

# ============================================================================
# SOONG NAMESPACES
# ============================================================================
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# ============================================================================
# PARTITIONS & DYNAMIC PARTITIONS
# ============================================================================
PRODUCT_BUILD_SUPER_PARTITION := true
PRODUCT_BUILD_VENDOR_BOOT_IMAGE := true

# ============================================================================
# MTK-SPECIFIC CONFIGURATIONS
# ============================================================================
# Usar módulos do kernel do vendor_boot
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/Image:kernel \
    $(LOCAL_PATH)/prebuilt/dtb.img:dtb.img \
    $(LOCAL_PATH)/prebuilt/dtbo.img:dtbo.img

# ============================================================================
# INCLUDE VENDOR CONFIGURATION (SE EXISTIR)
# ============================================================================
-include $(LOCAL_PATH)/vendor.mk
