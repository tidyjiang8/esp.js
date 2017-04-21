JS ?= samples/HelloWorld.js
VARIANT ?= release
DEVICE_NAME ?= "ZJS Device"

# JerryScript options
JERRY_BASE ?= $(ZJS_BASE)/deps/jerryscript
EXT_JERRY_FLAGS ?=	-DENABLE_ALL_IN_ONE=ON \
			-DFEATURE_PROFILE=$(ZJS_BASE)/jerry_feature.profile \
			-DFEATURE_ERROR_MESSAGES=OFF \
			-DJERRY_LIBM=OFF


.PHONY: all
ifeq ($(BOARD), linux)
all: linux
else
all: linux
endif


# Build JerryScript as a library (libjerry-core.a)
$(JERRYLIB):
	@echo "Building" $@
	@rm -rf $(JERRY_BASE)/build/$(BOARD)/
	$(MAKE) -C $(JERRY_BASE) -f targets/zephyr/Makefile.zephyr BOARD=$(BOARD) EXT_JERRY_FLAGS="$(EXT_JERRY_FLAGS)" jerry
	mkdir -p outdir/$(BOARD)/
	cp $(JERRY_BASE)/build/$(BOARD)/obj-$(BOARD)/lib/libjerry-core.a $(JERRYLIB)

# Give an error if we're asked to create the JS file
$(JS):
	$(error The file $(JS) does not exist.)

# Update dependency repos
.PHONY: update
update:
	@git submodule update --init

# Explicit clean
.PHONY: clean
clean: cleanlocal
ifeq ($(BOARD), linux)
	@make -f Makefile.linux clean
else
	@rm -rf $(JERRY_BASE)/build/$(BOARD)/;
	@rm -f outdir/$(BOARD)/libjerry-core*.a;
	@make -f Makefile.zephyr clean BOARD=$(BOARD);
	@cd arc/; make clean;
endif


# Linux target
.PHONY: linux
# Linux command line target, script can be specified on the command line
linux: 
	make -f Makefile.linux JS=$(JS) VARIANT=$(VARIANT) CB_STATS=$(CB_STATS) V=$(V) SNAPSHOT=$(SNAPSHOT)
