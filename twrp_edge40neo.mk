# Inherit from those products. Most specific first.

DEVICE_PATH := device/motorola/$(DEVICE_CODENAME)


# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit device configuration
$(call inherit-product, device/motorola/edge40neo/device.mk)


PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,device/motorola/edge40neo/recovery/root,recovery/root)

# Device identifier
PRODUCT_DEVICE := edge40neo
PRODUCT_NAME := twrp_edge40neo
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola Edge (2022)
PRODUCT_MANUFACTURER := motorola
# Assert that the device is edge40neo
TARGET_OTA_ASSERT_DEVICE := edge40neo,manaus
