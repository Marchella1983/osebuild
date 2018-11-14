include config.mk

LOCAL_PATH:= $(DIR)/libusb-1.0.22

include $(CLEAR_VARS)

LOCAL_C_INCLUDES += \
		$(LOCAL_PATH) \
		$(LOCAL_PATH)/android \
		$(LOCAL_PATH)/libusb \
		$(LOCAL_PATH)/libusb/os

LOCAL_EXPORT_C_INCLUDES := \
		$(LOCAL_PATH)/libusb

LOCAL_SRC_FILES := \
		libusb/core.c \
		libusb/descriptor.c \
		libusb/hotplug.c \
		libusb/io.c \
		libusb/sync.c \
		libusb/strerror.c \
		libusb/os/linux_usbfs.c \
		libusb/os/poll_posix.c \
		libusb/os/threads_posix.c \
		libusb/os/linux_netlink.c

LOCAL_MODULE := libusb1.0_static

include $(BUILD_STATIC_LIBRARY)
