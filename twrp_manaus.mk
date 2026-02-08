# Inherit from those products. Most specific first.

DEVICE_PATH := device/motorola/$(DEVICE_CODENAME)


# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit device configuration
$(call inherit-product, device/motorola/edge40neo/device.mk)


PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,device/motorola/edge40neo/recovery/root,recovery/root)
# Device identifier - USAR CODENAME REAL
PRODUCT_DEVICE := manaus
PRODUCT_NAME := twrp_manaus
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola edge 40 neo
PRODUCT_MANUFACTURER := motorola

TARGET_OTA_ASSERT_DEVICE := manaus,manaus_g,edge40neo
