#
# Copyright (C) 2024 The Android Open Source Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/motorola/manaus
DEVICE_PATH := device/motorola/manaus

# ============================================================================
# A/B SUPPORT
# Fonte: AOSP product/virtual_ab_ota/
# compression.mk: VAB com compressão (ro.virtual_ab.compression.enabled=true)
# REMOVIDO: launch_with_vendor_ramdisk.mk — mutuamente exclusivo com compression.mk
# Os dois não podem coexistir: compression.mk já inclui tudo necessário
# ============================================================================
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# ============================================================================
# ANDROID 12+ SUPPORT
# ============================================================================
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# first_api_level=31 confirmado pelo vendor.prop original
PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# ro.vndk.version=31 confirmado pelo vendor.prop original
PRODUCT_TARGET_VNDK_VERSION := 31

# ============================================================================
# A/B OTA CONFIGURATION
# ============================================================================
AB_OTA_UPDATER := true

# CORRIGIDO: era ext4 — dispositivo usa EROFS em todas as partições de sistema
# Confirmado: BOARD_SYSTEMIMAGE_PARTITION_TYPE := erofs no BoardConfig.mk
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=erofs \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=erofs \
    POSTINSTALL_OPTIONAL_vendor=true

# Virtual A/B properties — confirmado pelo vendor.prop original do dispositivo
PRODUCT_PROPERTY_OVERRIDES += \
    ro.virtual_ab.enabled=true \
    ro.virtual_ab.compression.enabled=true \
    ro.virtual_ab.userspace.snapshots.enabled=true \
    ro.virtual_ab.retrofit=false

# ============================================================================
# BOOT CONTROL HAL (A/B slot management)
# Fonte: guia MTK/TWRP lopestom — boot control HAL necessário para A/B MTK
# Arquivo: ramdisk\system\lib64\hw\android.hardware.boot@N.n-impl-N.n-mtkimpl.so
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
# VIRTUAL A/B — SNAPUSERD
# Confirmado: ro.virtual_ab.userspace.snapshots.enabled=true no vendor.prop original
# ATENÇÃO: dm-user.ko deve estar em prebuilt/modules/ — obrigatório para snapuserd
# ============================================================================
PRODUCT_PACKAGES += \
    snapuserd \
    snapuserd.recovery

# ============================================================================
# MTK PATH UTILS
# Fonte: guia MTK/TWRP lopestom — "ramdisk\system\bin\mtk_plpath_utils"
# deve ser incluído como PRODUCT_PACKAGES para garantir presença no ramdisk
# ============================================================================
PRODUCT_PACKAGES += \
    mtk_plpath_utils 
 

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/bin/plpath_utils:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/system/bin/plpath_utils \
    $(DEVICE_PATH)/prebuilt/bin/plpath_utils:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/system/bin/mtk_plpath_utils \
    $(DEVICE_PATH)/prebuilt/bin/plpath_utils:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/system/bin/mtk_plpath_utils_ota

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

# CORRIGIDO: impl-mock substituído pela implementação real
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
# CORRIGIDO: vírgula solta após dtb.img removida (causava erro de sintaxe no build)
# ============================================================================

    $(DEVICE_PATH)/prebuilt/dtb.img:dtb.img

# ============================================================================
# RECOVERY FILES
# ============================================================================
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/recovery.fstab \
    $(DEVICE_PATH)/recovery/root/system/etc/twrp.flags:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/twrp.flags \
    $(DEVICE_PATH)/recovery/root/init.recovery.mt6879.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6879.rc \
    $(DEVICE_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc \
    $(DEVICE_PATH)/recovery/root/mtk-plpath-utils.rc:$(TARGET_COPY_OUT_RECOVERY)/root/mtk-plpath-utils.rc \
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
