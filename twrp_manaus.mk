#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
DEVICE_PATH := device/motorola/manaus
DEVICE_CODENAME := manaus

# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit device configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

# Copy recovery files
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,$(DEVICE_PATH)/recovery/root,recovery/root)

# Device identifier - DEVE bater com o nome do arquivo
PRODUCT_DEVICE := manaus
PRODUCT_NAME := twrp_manaus
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola edge 40 neo
PRODUCT_MANUFACTURER := motorola

# OTA assert
TARGET_OTA_ASSERT_DEVICE := manaus,manaus_g,edge40neo

# Product info
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=manaus \
    BUILD_PRODUCT=manaus \
    TARGET_DEVICE=manaus
