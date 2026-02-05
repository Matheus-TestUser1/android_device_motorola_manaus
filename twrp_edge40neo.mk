# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from manaus device
$(call inherit-product, device/motorola/edge40neo/device.mk)

PRODUCT_DEVICE := edge40neo
PRODUCT_NAME := twrp_edge40neo
PRODUCT_BRAND := motorola
PRODUCT_MODEL := moto edge (2022)
PRODUCT_MANUFACTURER := motorola

PRODUCT_GMS_CLIENTID_BASE := android-motorola

PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,device/motorola/edge40neo/recovery/root,recovery/root)

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="edge40neo_g_vext-user 12 U1TM34.107-34-3 1c7ca3 release-keys"

BUILD_FINGERPRINT := motorola/edge40neo_g_vext/edge40neo:12/U1TM34.107-34-3/1c7ca3:user/release-keys
