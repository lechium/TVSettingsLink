ARCHS = arm64
TARGET = appletv
export GO_EASY_ON_ME=1
export SDKVERSION=12.1
THEOS_DEVICE_IP=guest-room.local
DEBUG=0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TVPrefs
TVPrefs_FILES = TVPrefs.xm
TVPrefs_LIBRARIES = substrate
TVPrefs_FRAMEWORKS = Foundation UIKit CoreGraphics MobileCoreServices
TVPrefs_LDFLAGS = -undefined dynamic_lookup
TVPrefs_CFLAGS = -I.

include $(THEOS_MAKE_PATH)/tweak.mk


internal-stage::
	#cp $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).* ../layout/Library/MobileSubstrate/DynamicLibraries/
	
after-install::
	install.exec "killall -9 TVSettings"
