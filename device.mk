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
# BOOT CONTROL HAL (A/B slot management)
# ============================================================================

# ⭐ SÓ bootctrl genérico (fallback)
PRODUCT_PACKAGES += \
   bootctrl.default \
   bootctrl.default.recovery
# compatibility test 
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-mtkimpl \
    android.hardware.boot@1.2-mtkimpl.recovery 

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# ⭐ BOOT HAL LIBS (MTK) - PREBUILT DO STOCK - CRÍTICAS PRO A/B!
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.0.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.boot@1.0.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.1.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.boot@1.1.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.2.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/android.hardware.boot@1.2.so \
    $(DEVICE_PATH)/recovery/root/vendor/lib64/android.hardware.boot@1.0-impl-1.2-mtkimpl.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/hw/android.hardware.boot@1.0-impl-1.2-mtkimpl.so

# ⭐ BOOT HAL SERVICE (MTK) - PREBUILT DO STOCK
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/bin/hw/android.hardware.boot@1.2-service:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/bin/hw/android.hardware.boot@1.2-service

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

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/BT_FW.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/BT_FW.cfg \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/NFG1000A_battery_parameter_SB18D87942.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/NFG1000A_battery_parameter_SB18D87942.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/NFG1000A_battery_parameter_SB18D87943.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/NFG1000A_battery_parameter_SB18D87943.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/NFG1000A_firmware.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/NFG1000A_firmware.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/WIFI_RAM_CODE_soc7_0_1a_1.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/WIFI_RAM_CODE_soc7_0_1a_1.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/aw882xx_acf.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/aw882xx_acf.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/aw963xx_reg_0.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/aw963xx_reg_0.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/aw963xx_reg_evt_0.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/aw963xx_reg_evt_0.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/boe_goodix_cfg_group.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/boe_goodix_cfg_group.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/boe_goodix_firmware.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/boe_goodix_firmware.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/boe_goodix_test_limits_255.csv:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/boe_goodix_test_limits_255.csv \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/conninfra.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/conninfra.cfg \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/fm_cust.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/fm_cust.cfg \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_ts_fw_csot.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/focaltech_ts_fw_csot.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/lib3a.ccu:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/lib3a.ccu \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/lib3a.ccu_dummy:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/lib3a.ccu_dummy \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mali_csffw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mali_csffw.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mali_csffw_reload.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mali_csffw_reload.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mot_dw9781.prog:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mot_dw9781.prog \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6627_fm_v1_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6627_fm_v1_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6627_fm_v1_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6627_fm_v1_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6630_fm_v1_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6630_fm_v1_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6630_fm_v1_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6630_fm_v1_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6630_fm_v2_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6630_fm_v2_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6630_fm_v2_coeff_tx.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6630_fm_v2_coeff_tx.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6630_fm_v2_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6630_fm_v2_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6630_fm_v2_patch_tx.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6630_fm_v2_patch_tx.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6631_fm_v1_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6631_fm_v1_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6631_fm_v1_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6631_fm_v1_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6632_fm_v1_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6632_fm_v1_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6632_fm_v1_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6632_fm_v1_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6635_fm_v1_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6635_fm_v1_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/mt6635_fm_v1_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/mt6635_fm_v1_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/remoteproc_scp:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/remoteproc_scp \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_bt_1_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_bt_1_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_bt_1a_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_bt_1a_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_bt_1b_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_bt_1b_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_mcu_1_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_mcu_1_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_mcu_1a_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_mcu_1a_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_mcu_1b_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_mcu_1b_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc7_0_ram_wmmcu_1a_1_hdr.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc7_0_ram_wmmcu_1a_1_hdr.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc_fm_v1_coeff.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc_fm_v1_coeff.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/soc_fm_v1_patch.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/soc_fm_v1_patch.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/tm_goodix_cfg_group.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/tm_goodix_cfg_group.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/tm_goodix_firmware.bin:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/tm_goodix_firmware.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/tm_goodix_test_limits_255.csv:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/tm_goodix_test_limits_255.csv \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/txpowerctrl.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/txpowerctrl.cfg \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/txpowerctrl_na.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/txpowerctrl_na.cfg \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/valhall-1691526.wa:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/valhall-1691526.wa \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/wifi.cfg:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/firmware/wifi.cfg

# ============================================================================
# SOONG NAMESPACES
# ============================================================================
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)
