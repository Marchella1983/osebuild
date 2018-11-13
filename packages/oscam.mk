include config.mk

LOCAL_PATH:= $(DIR)/$(CAM)

include $(CLEAR_VARS)
LOCAL_MODULE := libcrypto_static
LOCAL_SRC_FILES := $(LOCAL_PATH)/../usr/lib/$(TARGET_PLATFORM)/$(TARGET_ARCH_ABI)/libcrypto_static.a
include $(PREBUILT_STATIC_LIBRARY)

ifeq ($(usb),true)
include $(CLEAR_VARS)
LOCAL_MODULE := libusb1.0_static
LOCAL_SRC_FILES := $(LOCAL_PATH)/../usr/lib/$(TARGET_PLATFORM)/$(TARGET_ARCH_ABI)/libusb1.0_static.a
include $(PREBUILT_STATIC_LIBRARY)
endif

ifeq ($(stapi),true)
include $(CLEAR_VARS)
LOCAL_MODULE := wi_static
LOCAL_SRC_FILES := $(LOCAL_PATH)/../../patches/stapi/libwi.a
include $(PREBUILT_STATIC_LIBRARY)
endif

##################################
config := --disable \
	WITH_SSL CLOCKFIX CARDREADER_DB2COM READER_NAGRA_MERLIN
####################################

include $(CLEAR_VARS)

LOCAL_C_INCLUDES := \
		../ \
		$(LOCAL_PATH) \
		$(LOCAL_PATH)/../usr/include

LOCAL_SRC_FILES := \
		cscrypt/aes.c \
		cscrypt/aescbc.c \
		cscrypt/bn_add.c \
		cscrypt/bn_asm.c \
		cscrypt/bn_ctx.c \
		cscrypt/bn_div.c \
		cscrypt/bn_exp.c \
		cscrypt/bn_lib.c \
		cscrypt/bn_mul.c \
		cscrypt/bn_print.c \
		cscrypt/bn_shift.c \
		cscrypt/bn_sqr.c \
		cscrypt/bn_word.c \
		cscrypt/mem.c \
		cscrypt/des.c \
		cscrypt/fast_aes.c \
		cscrypt/i_cbc.c \
		cscrypt/i_ecb.c \
		cscrypt/i_skey.c \
		cscrypt/md5.c \
		cscrypt/rc6.c \
		cscrypt/sha1.c \
		cscrypt/sha256.c \
		csctapi/atr.c \
		csctapi/icc_async.c \
		csctapi/io_serial.c \
		csctapi/protocol_t0.c \
		csctapi/protocol_t1.c \
		csctapi/ifd_azbox.c \
		csctapi/ifd_cool.c \
		csctapi/ifd_db2com.c \
		csctapi/ifd_drecas.c \
		csctapi/ifd_mp35.c \
		csctapi/ifd_pcsc.c \
		csctapi/ifd_phoenix.c \
		csctapi/ifd_sc8in1.c \
		csctapi/ifd_sci.c \
		csctapi/ifd_smargo.c \
		csctapi/ifd_smartreader.c \
		csctapi/ifd_stinger.c \
		csctapi/ifd_stapi.c \
		minilzo/minilzo.c \
		module-anticasc.c \
		module-cacheex.c \
		module-camd33.c \
		module-camd35-cacheex.c \
		module-camd35.c \
		module-cccam-cacheex.c \
		module-cccam.c \
		module-cccshare.c \
		module-constcw.c \
		module-csp.c \
		module-cw-cycle-check.c \
		module-dvbapi-azbox.c \
		module-dvbapi-mca.c \
		module-dvbapi-coolapi.c \
		module-dvbapi-stapi.c \
		module-dvbapi-stapi5.c \
		module-dvbapi-chancache.c \
		module-dvbapi.c \
		module-gbox-helper.c \
		module-gbox-remm.c \
		module-gbox-sms.c \
		module-gbox-cards.c \
		module-gbox.c \
		module-ird-guess.c \
		module-lcd.c \
		module-led.c \
		module-monitor.c \
		module-newcamd.c \
		module-newcamd-des.c \
		module-pandora.c \
		module-ghttp.c \
		module-radegast.c \
		module-scam.c \
		module-serial.c \
		module-stat.c \
		module-webif-lib.c \
		module-webif-tpl.c \
		module-webif.c \
		webif/pages.c \
		reader-common.c \
		reader-bulcrypt.c \
		reader-conax.c \
		reader-cryptoworks.c \
		reader-dgcrypt.c \
		reader-dre-cas.c \
		reader-dre-common.c \
		reader-dre-st20.c \
		reader-dre.c \
		reader-griffin.c \
		reader-irdeto.c \
		reader-nagra.c \
		reader-nagracak7.c \
		reader-seca.c \
		reader-tongfang.c \
		reader-viaccess.c \
		reader-videoguard-common.c \
		reader-videoguard1.c \
		reader-videoguard12.c \
		reader-videoguard2.c \
		oscam-aes.c \
		oscam-array.c \
		oscam-hashtable.c \
		oscam-cache.c \
		oscam-chk.c \
		oscam-client.c \
		oscam-conf.c \
		oscam-conf-chk.c \
		oscam-conf-mk.c \
		oscam-config-account.c \
		oscam-config-global.c \
		oscam-config-reader.c \
		oscam-config.c \
		oscam-ecm.c \
		oscam-emm.c \
		oscam-emm-cache.c \
		oscam-failban.c \
		oscam-files.c \
		oscam-garbage.c \
		oscam-lock.c \
		oscam-log.c \
		oscam-log-reader.c \
		oscam-net.c \
		oscam-llist.c \
		oscam-reader.c \
		oscam-simples.c \
		oscam-string.c \
		oscam-time.c \
		oscam-work.c \
		oscam.c \
		config.c

ifeq ($(emu), true)
LOCAL_SRC_FILES += \
		ffdecsa/ffdecsa.c \
		module-emulator.c \
		module-emulator-osemu.c \
		module-emulator-streamserver.c \
		module-emulator-biss.c \
		module-emulator-cryptoworks.c \
		module-emulator-director.c \
		module-emulator-drecrypt.c \
		module-emulator-irdeto.c \
		module-emulator-nagravision.c \
		module-emulator-powervu.c \
		module-emulator-viaccess.c \
		module-emulator-videoguard.c
endif

LOCAL_SRC_FILES += $(info $(shell ($(LOCAL_PATH)/config.sh $(config) --make-config.mak)))
LOCAL_SRC_FILES += $(info $(shell ($(LOCAL_PATH)/config.sh -s)))
LOCAL_SRC_FILES += $(info $(shell (make -C $(LOCAL_PATH)/webif --no-print-directory --quiet)))
LOCAL_MODULE := oscam
LOCAL_LDLIBS := -lm -ldl
LOCAL_LDFLAGS := -llog -Wl,-s
LOCAL_STATIC_LIBRARIES := libcrypto_static
LOCAL_CFLAGS := \
		-DWITH_LIBCRYPTO=1 \
		-D'CS_CONFDIR="$(CONFDIR)"' \
		-D'CS_SVN_VERSION="$(REV)"' \
		-D'CS_TARGET="$(TOOLCHAIN_NAME) ($(PLATFORM))"'

ifeq ($(usb),true)
LOCAL_CFLAGS += -DWITH_LIBUSB=1 -DHAVE_PTHREAD_H
LOCAL_STATIC_LIBRARIES += libusb1.0_static
endif

ifeq ($(stapi),true)
LOCAL_CFLAGS += -DWITH_STAPI=1 -Dsupremo=1
LOCAL_STATIC_LIBRARIES += wi_static
endif

include $(BUILD_EXECUTABLE)
