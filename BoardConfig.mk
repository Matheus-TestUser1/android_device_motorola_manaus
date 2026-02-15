#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/motorola/manaus

# ============================================================================
# BASIC
# ============================================================================
ALLOW_MISSING_DEPENDENCIES := true

TARGET_BOOTLOADER_BOARD_NAME := manaus
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true

BOARD_VENDOR := motorola
TARGET_SOC := mt6879
TARGET_BOARD_PLATFORM := mt6879
TARGET_BOARD_PLATFORM_GPU := mali-g57mc2

BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

# ============================================================================
# VENDOR_BOOT / BOOT HEADER (V4) - CRITICAL FOR EDGE 40 NEO
# ============================================================================
BOARD_BOOT_HEADER_VERSION := 4
BOARD_USES_VENDOR_BOOTIMAGE := true
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

# ============================================================================
# ARCH
# ============================================================================
# Architecture (64-bit)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55
# 64-bit support
TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_IS_64_BIT := true
# ============================================================================
# KERNEL / MKBOOTIMG - VENDOR_BOOT CONFIGURATION
# ============================================================================
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x11088000
BOARD_KERNEL_TAGS_OFFSET := 0x07c08000
BOARD_DTB_OFFSET := 0x07c08000

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_KERNEL_CMDLINE += androidboot.serialconsole=0
BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive

BOARD_KERNEL_IMAGE_NAME := Image
#BOARD_KERNEL_SEPARATED_DTBO := true

BOARD_RAMDISK_USE_LZ4 := true
#LZMA_RAMDISK_TARGETS := recovery

# Prebuilts - Kernel e DTB para vendor_boot
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img

# mkbootimg args - CRITICAL FOR VENDOR_BOOT
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
#BOARD_INCLUDE_RECOVERY_DTBO := true

# ============================================================================
# KERNEL MODULES - REQUIRED FOR VENDOR_BOOT
# ============================================================================
# Carregar módulos do kernel no primeiro estágio
TW_LOAD_VENDOR_BOOT_MODULES := true
# Lista de módulos para carregar (do vendor_ramdisk)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilt/modules.load 2>/dev/null))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko)

# Módulos para recovery (mesmos do vendor_ramdisk)
BOARD_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/prebuilt/modules.load.recovery 2>/dev/null))
RECOVERY_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES)

# ============================================================================
# PARTITIONS / DYNAMIC
# ============================================================================
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864

BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := motorola_dynamic_partitions
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor vendor_dlkm
BOARD_MOTOROLA_DYNAMIC_PARTITIONS_SIZE := 9122611200

# ============================================================================
# FS TYPES (EROFS CONFIG)
# ============================================================================
BOARD_HAS_LARGE_FILESYSTEM := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EROFS := true

BOARD_SYSTEMIMAGE_PARTITION_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# ============================================================================
# AVB
# ============================================================================
BOARD_AVB_ENABLE := true

# VBMETA principal - desativa verificação estrita para TWRP funcionar
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
# Flags: 3 = HASHTREE_DISABLED (1) + VERIFICATION_DISABLED (2)
# Isso permite boot sem assinatura perfeita, mas mantém estrutura AVB

# VBMETA SYSTEM - mesmo tratamento
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
# Rollback index: usar 0 ou valor compatível com seu firmware atual
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2  # ❗ Diferente da recovery
BOARD_AVB_VBMETA_SYSTEM_ARGS += --flags 3

# RECOVERY - Configuração crítica para TWRP bootar
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
# ESSENCIAL: rollback index deve ser 0 para TWRP não-assinado bootar
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 0
# ESSENCIAL: location diferente de todos os outros (1 é comum para recovery)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

# ADICIONAL: Desativar rollback protection para evitar brick
BOARD_AVB_ROLLBACK_PROTECTION := false

# ============================================================================
# RECOVERY
# ============================================================================
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_HAS_NO_REAL_SDCARD := true
RECOVERY_SDCARD_ON_DATA := true
MTK_PLPATH_UTILS := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBA_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

TW_PREPARE_DATA_MEDIA_EARLY := true
BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# ============================================================================
# A/B OTA
# ============================================================================
AB_OTA_UPDATER := true
TW_INCLUDE_REPACKTOOLS := true

AB_OTA_PARTITIONS := \
    boot \
    vendor_boot \
    system \
    system_ext \
    product \
    vendor \
    vendor_dlkm \
    dtbo \
    vbmeta_system \
    vbmeta

# ============================================================================
# USB
# ============================================================================
TARGET_USB_CONTROLLER := 11201000.usb0

TW_USB_VENDOR_ID := 0x22b8
TW_USB_PRODUCT_ID := 0x2e81
TW_USB_PRODUCT_ID_FASTBOOT := 0x2e80

TW_EXCLUDE_DEFAULT_USB_INIT := true
TARGET_USE_CUSTOM_LUN_FILE_PATH := /config/usb_gadget/g1/functions/mass_storage.0/lun.%d/file

# ============================================================================
# TWRP
# ============================================================================
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_INPUT_BLACKLIST := "hbtp_vm"

TW_NO_SCREEN_TIMEOUT := true
TW_DEVICE_VERSION := manaus_MT6879_vendor_boot

TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 2047
TW_DEFAULT_BRIGHTNESS := 1200

TW_HAS_MTP := true
TW_MTP_DEVICE := /dev/mtp_usb

TW_INTERNAL_STORAGE_PATH := "/data/media/0"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"

TW_EXTERNAL_STORAGE_PATH := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"
TW_DEFAULT_EXTERNAL_STORAGE := true

TW_USE_NEW_MINADBD := true
TW_USE_TOOLBOX := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true

TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_APEX := true

TW_NO_FASTBOOT_BOOT := true
TW_USE_FSCRYPT_POLICY := 1

TW_CUSTOM_CPU_TEMP_PATH := /sys/class/thermal/thermal_zone3/temp
BOARD_UFS_SUPPORT := true

TW_OVERRIDE_SYSTEM_PROPS := \
  "ro.build.fingerprint=ro.system.build.fingerprint;ro.build.version.incremental"

# ============================================================================
# SECURITY (no crypto)
# ============================================================================
TW_INCLUDE_CRYPTO := false
TW_INCLUDE_CRYPTO_FBE := false
TW_INCLUDE_FBE_METADATA_DECRYPT := false
BOARD_USES_QCOM_FBE_DECRYPTION := false
BOARD_SURFACE_FLINGER_USE_PHASE_OFFSETS := false
TARGET_SURFACE_FLINGER_MAX_FRAME_BUFFERS := 4
# ============================================================================
# ASSERT
# ============================================================================
TARGET_OTA_ASSERT_DEVICE := manaus,manaus_g,edge40neo

# ============================================================================
# VERSIONS
# ============================================================================
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31

# ============================================================================
# PROPS
# ============================================================================
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# ============================================================================
# DEBUG
# ============================================================================
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TARGET_USES_MKE2FS := true
