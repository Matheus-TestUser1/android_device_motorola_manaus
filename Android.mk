#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

ifneq ($(filter manaus, $(TARGET_DEVICE)),)

LOCAL_PATH := $(call my-dir)

include $(call all-makefiles-under,$(LOCAL_PATH))

# Copy kernel modules to vendor ramdisk
ifeq ($(BOARD_VENDOR_RAMDISK_KERNEL_MODULES),)
$(shell mkdir -p $(LOCAL_PATH)/prebuilt/modules 2>/dev/null)
endif

endif
