ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += zziplib
ZZIPLIB_VERSION  := 0.13.71
DEB_ZZIPLIB_V    ?= $(ZZIPLIB_VERSION)

zziplib-setup: setup
	# The zziplib download has an annoying name, so we must use -O, so we can't use -nc, so do this instead.
	[ -f "$(BUILD_SOURCE)/zziplib-$(ZZIPLIB_VERSION).tar.gz" ] || \
		wget -q https://github.com/gdraheim/zziplib/archive/v$(ZZIPLIB_VERSION).tar.gz -O $(BUILD_SOURCE)/zziplib-$(ZZIPLIB_VERSION).tar.gz
	$(call EXTRACT_TAR,zziplib-$(ZZIPLIB_VERSION).tar.gz,zziplib-$(ZZIPLIB_VERSION),zziplib)

ifneq ($(wildcard $(BUILD_WORK)/zziplib/.build_complete),)
zziplib:
	@echo "Using previously built zziplib"
else
zziplib: zziplib-setup
	cd $(BUILD_WORK)/zziplib && cmake . \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Darwin \
		-DCMAKE_OSX_SYSROOT="$(TARGET_SYSROOT)" \
		-DCMAKE_C_FLAGS="$(CFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(CXXFLAGS)" \
		-DCMAKE_OSX_ARCHITECTURES="$(MEMO_ARCH)" \
		-DCMAKE_LIBRARY_PATH="$(BUILD_BASE)/usr/lib" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_CROSSCOMPILING=true \
		-DZZIPTEST=false
	+$(MAKE) -C $(BUILD_WORK)/zziplib
	+$(MAKE) -C $(BUILD_WORK)/zziplib manpages
	+$(MAKE) -C $(BUILD_WORK)/zziplib install \
		DESTDIR=$(BUILD_STAGE)/zziplib
	+$(MAKE) -C $(BUILD_WORK)/zziplib install \
		DESTDIR=$(BUILD_BASE)

	touch $(BUILD_WORK)/zziplib/.build_complete
endif

zziplib-package: zziplib-stage
	rm -rf $(BUILD_DIST)/zziplib
	
	cp -a $(BUILD_STAGE)/zziplib $(BUILD_DIST)

	$(call SIGN,zziplib,general.xml)
	
	$(call PACK,zziplib,DEB_ZZIPLIB_V)
	
	rm -rf $(BUILD_DIST)/zziplib

.PHONY: zziplib zziplib-package
