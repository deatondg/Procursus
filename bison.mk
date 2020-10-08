ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += bison
BISON_VERSION := 3.7.2
DEB_BISON_V   ?= $(BISON_VERSION)

bison-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://ftpmirror.gnu.org/bison/bison-$(BISON_VERSION).tar.xz{,.sig}
	$(call PGP_VERIFY,bison-$(BISON_VERSION).tar.xz)
	$(call EXTRACT_TAR,bison-$(BISON_VERSION).tar.xz,bison-$(BISON_VERSION),bison)

ifneq ($(wildcard $(BUILD_WORK)/bison/.build_complete),)
bison:
	@echo "Using previously built bison."
else
bison: bison-setup m4 gettext readline
	cd $(BUILD_WORK)/bison && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr
	+$(MAKE) -C $(BUILD_WORK)/bison
	+$(MAKE) -C $(BUILD_WORK)/bison install \
		DESTDIR=$(BUILD_STAGE)/bison
	+$(MAKE) -C $(BUILD_WORK)/bison install \
		DESTDIR="$(BUILD_BASE)"
	touch $(BUILD_WORK)/bison/.build_complete
endif

bison-package: bison-stage
	# bison.mk Package Structure
	rm -rf $(BUILD_DIST)/{bison,libbison-dev}
	mkdir -p $(BUILD_DIST)/bison/usr \
		$(BUILD_DIST)/libbison-dev/usr
	
	# bison.mk Prep bison
	cp -a $(BUILD_STAGE)/bison/usr/{bin,share} $(BUILD_DIST)/bison/usr

	# bison.mk Prep libbison-dev
	cp -a $(BUILD_STAGE)/bison/usr/lib $(BUILD_DIST)/libbison-dev/usr
	
	# bison.mk Sign
	$(call SIGN,bison,general.xml)
	
	# bison.mk Make .debs
	$(call PACK,bison,DEB_BISON_V)
	$(call PACK,libbison-dev,DEB_BISON_V)
	
	# bison.mk Build cleanup
	rm -rf $(BUILD_DIST)/{bison,libbison-dev}

.PHONY: bison bison-package
