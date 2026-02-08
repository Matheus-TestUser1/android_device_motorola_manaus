#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/motorola/manaus

# ============================================================================
# ARCHITECTURE & BASE
# ============================================================================
# Herda configurações base de 64 bits (Necessário)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Define API Level (Android 13)
PRODUCT_SHIPPING_API_LEVEL := 33

# ============================================================================
# TWRP CONFIGURATION
# ============================================================================
# Herda configurações comuns do TWRP
$(call inherit-product, vendor/twrp/config/common.mk)

# ============================================================================
# A/B OTA / DYNAMIC PARTITIONS
# ============================================================================
AB_OTA_UPDATER := true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# Ferramentas necessárias para A/B e Partições Dinâmicas
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_engine_sideload \
    update_verifier \
    checkpoint_gc \
    fastbootd

# ============================================================================
# BOOT CONTROL HAL
# ============================================================================
# Usamos a implementação HIDL padrão/genérica.
# Se falhar, você precisará dos prebuilts da Motorola (bootctrl.mt6879.so)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-impl \
    android.hardware.boot@1.2-service \
    android.hardware.boot@1.2-impl.recovery \
    bootctrl.mt6879

# ============================================================================
# INIT SCRIPTS & FSTAB
# ============================================================================
# Copia o fstab para a raiz do ramdisk (CRÍTICO para montar partições)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/system/etc/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/recovery.fstab

# Scripts de inicialização específicos do MT6879
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery/root/init.recovery.mt6879.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.mt6879.rc \
    $(LOCAL_PATH)/recovery/root/init.recovery.usb.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.usb.rc

# Se você tiver módulos de kernel (ko), copie-os aqui (Opcional, mas recomendado para Touch/Tela)
# PRODUCT_COPY_FILES += \
#     $(LOCAL_PATH)/recovery/root/vendor/lib/modules/mmi_annotate.ko:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/mmi_annotate.ko

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

# Encryption (Desabilitada conforme seu pedido)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crypto.state=unsupported \
    ro.crypto.type=none

# MediaTek properties
PRODUCT_PROPERTY_OVERRIDES += \
    ro.mediatek.platform=MT6879 \
    ro.mediatek.chip_ver=S01 \
    ro.mediatek.version.release=13 \
    ro.mediatek.version.sdk=4

# USB Controller (Confirmado MT6879)
PRODUCT_PROPERTY_OVERRIDES += \
    sys.usb.controller=11201000.usb0 \
    sys.usb.ffs.aio_compat=true

# Outras propriedades úteis
PRODUCT_PROPERTY_OVERRIDES += \
    ro.debuggable=1 \
    ro.secure=0 \
    ro.adb.secure=0 \
    persist.sys.usb.config=mtp,adb \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    ro.apex.updatable=false
