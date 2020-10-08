ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += less
LESS_VERSION := 551
DEB_LESS_V   ?= $(LESS_VERSION)

less-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://www.greenwoodsoftware.com/less/less-$(LESS_VERSION).tar.gz
	$(call EXTRACT_TAR,less-$(LESS_VERSION).tar.gz,less-$(LESS_VERSION),less)

ifneq ($(wildcard $(BUILD_WORK)/less/.build_complete),)
less:
	@echo "Using previously built less."
else
less: less-setup ncurses pcre2
	cd $(BUILD_WORK)/less && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--with-regex=pcre2 \
		CFLAGS="$(CFLAGS) -Wno-implicit-function-declaration" \
		LDFLAGS="$(CFLAGS) $(LDFLAGS)"
	+$(MAKE) -C $(BUILD_WORK)/less
	+$(MAKE) -C $(BUILD_WORK)/less install \
		DESTDIR="$(BUILD_STAGE)/less"
	touch $(BUILD_WORK)/less/.build_complete
endif

less-package: less-stage
	# less.mk Package Structure
	rm -rf $(BUILD_DIST)/less
	mkdir -p $(BUILD_DIST)/less/{bin,etc/profile.d}
	
	# less.mk Prep less
	cp -a $(BUILD_STAGE)/less/usr $(BUILD_DIST)/less
	ln -s /usr/bin/less $(BUILD_DIST)/less/bin/more
	ln -s /usr/bin/less $(BUILD_DIST)/less/usr/bin/more
	
	# less.mk Sign
	$(call SIGN,less,general.xml)
	
	# less.mk Make .debs
	$(call PACK,less,DEB_LESS_V)
	
	# less.mk Build cleanup
	rm -rf $(BUILD_DIST)/less

.PHONY: less less-package
