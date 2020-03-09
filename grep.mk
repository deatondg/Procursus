ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

grep:
	cd $(BUILD_WORK)/grep && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--disable-dependency-tracking \
		--with-packager="$(DEB_MAINTAINER)"
	$(MAKE) -C $(BUILD_WORK)/grep
	$(FAKEROOT) $(MAKE) -C $(BUILD_WORK)/grep install \
		DESTDIR=$(BUILD_STAGE)/grep

.PHONY: grep