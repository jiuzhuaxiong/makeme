#
#   me-macosx-default.mk -- Makefile to build Embedthis MakeMe for macosx
#

NAME                  := me
VERSION               := 0.8.3
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_EJS            ?= 1
ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_EJS),1)
    ME_COM_ZLIB := 1
endif

ME_COM_COMPILER_PATH  ?= clang
ME_COM_LIB_PATH       ?= ar
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl

CFLAGS                += -g -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-Ibuild/$(CONFIG)/inc"
LDFLAGS               += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS              += -Lbuild/$(CONFIG)/bin
LIBS                  += -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)-default
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += build/$(CONFIG)/bin/.updated
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/ejs.mod
endif
TARGETS               += build/$(CONFIG)/bin/ejs.testme.es
TARGETS               += build/$(CONFIG)/bin/ejs.testme.mod
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/ejs
endif
TARGETS               += build/$(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += build/$(CONFIG)/bin/http
endif
ifeq ($(ME_COM_EST),1)
    TARGETS           += build/$(CONFIG)/bin/libest.dylib
endif
TARGETS               += build/$(CONFIG)/bin/libmprssl.dylib
TARGETS               += build/$(CONFIG)/bin/libtestme.dylib
TARGETS               += build/$(CONFIG)/bin/me
TARGETS               += build/$(CONFIG)/bin/testme
TARGETS               += build/$(CONFIG)/bin/testme.es

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/me-macosx-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/me-macosx-default-me.h >/dev/null ; then\
		cp projects/me-macosx-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(BUILD)/.makeflags

clean:
	rm -f "build/$(CONFIG)/obj/ejs.o"
	rm -f "build/$(CONFIG)/obj/ejsLib.o"
	rm -f "build/$(CONFIG)/obj/ejsc.o"
	rm -f "build/$(CONFIG)/obj/estLib.o"
	rm -f "build/$(CONFIG)/obj/http.o"
	rm -f "build/$(CONFIG)/obj/httpLib.o"
	rm -f "build/$(CONFIG)/obj/libtestme.o"
	rm -f "build/$(CONFIG)/obj/me.o"
	rm -f "build/$(CONFIG)/obj/mprLib.o"
	rm -f "build/$(CONFIG)/obj/mprSsl.o"
	rm -f "build/$(CONFIG)/obj/pcre.o"
	rm -f "build/$(CONFIG)/obj/testme.o"
	rm -f "build/$(CONFIG)/obj/zlib.o"
	rm -f "build/$(CONFIG)/bin/ejs.testme.es"
	rm -f "build/$(CONFIG)/bin/ejsc"
	rm -f "build/$(CONFIG)/bin/ejs"
	rm -f "build/$(CONFIG)/bin/ca.crt"
	rm -f "build/$(CONFIG)/bin/http"
	rm -f "build/$(CONFIG)/bin/libejs.dylib"
	rm -f "build/$(CONFIG)/bin/libest.dylib"
	rm -f "build/$(CONFIG)/bin/libhttp.dylib"
	rm -f "build/$(CONFIG)/bin/libmpr.dylib"
	rm -f "build/$(CONFIG)/bin/libmprssl.dylib"
	rm -f "build/$(CONFIG)/bin/libpcre.dylib"
	rm -f "build/$(CONFIG)/bin/libtestme.dylib"
	rm -f "build/$(CONFIG)/bin/libzlib.dylib"
	rm -f "build/$(CONFIG)/bin/testme"
	rm -f "build/$(CONFIG)/bin/testme.es"

clobber: clean
	rm -fr ./$(BUILD)


#
#   core
#
DEPS_1 += src/configure.es
DEPS_1 += src/configure/appweb.me
DEPS_1 += src/configure/compiler.me
DEPS_1 += src/configure/lib.me
DEPS_1 += src/configure/link.me
DEPS_1 += src/configure/rc.me
DEPS_1 += src/configure/testme.me
DEPS_1 += src/configure/vxworks.me
DEPS_1 += src/configure/winsdk.me
DEPS_1 += src/generate.es
DEPS_1 += src/master-main.me
DEPS_1 += src/master-start.me
DEPS_1 += src/me.es
DEPS_1 += src/os/freebsd.me
DEPS_1 += src/os/gcc.me
DEPS_1 += src/os/linux.me
DEPS_1 += src/os/macosx.me
DEPS_1 += src/os/solaris.me
DEPS_1 += src/os/unix.me
DEPS_1 += src/os/vxworks.me
DEPS_1 += src/os/windows.me
DEPS_1 += src/simple.me
DEPS_1 += src/standard.me
DEPS_1 += src/vstudio.es
DEPS_1 += src/xcode.es

build/$(CONFIG)/bin/.updated: $(DEPS_1)
	@echo '      [Copy] build/$(CONFIG)/bin'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/configure.es build/$(CONFIG)/bin/configure.es
	mkdir -p "build/$(CONFIG)/bin/configure"
	cp src/configure/appweb.me build/$(CONFIG)/bin/configure/appweb.me
	cp src/configure/compiler.me build/$(CONFIG)/bin/configure/compiler.me
	cp src/configure/lib.me build/$(CONFIG)/bin/configure/lib.me
	cp src/configure/link.me build/$(CONFIG)/bin/configure/link.me
	cp src/configure/rc.me build/$(CONFIG)/bin/configure/rc.me
	cp src/configure/testme.me build/$(CONFIG)/bin/configure/testme.me
	cp src/configure/vxworks.me build/$(CONFIG)/bin/configure/vxworks.me
	cp src/configure/winsdk.me build/$(CONFIG)/bin/configure/winsdk.me
	cp src/generate.es build/$(CONFIG)/bin/generate.es
	cp src/master-main.me build/$(CONFIG)/bin/master-main.me
	cp src/master-start.me build/$(CONFIG)/bin/master-start.me
	cp src/me.es build/$(CONFIG)/bin/me.es
	mkdir -p "build/$(CONFIG)/bin/os"
	cp src/os/freebsd.me build/$(CONFIG)/bin/os/freebsd.me
	cp src/os/gcc.me build/$(CONFIG)/bin/os/gcc.me
	cp src/os/linux.me build/$(CONFIG)/bin/os/linux.me
	cp src/os/macosx.me build/$(CONFIG)/bin/os/macosx.me
	cp src/os/solaris.me build/$(CONFIG)/bin/os/solaris.me
	cp src/os/unix.me build/$(CONFIG)/bin/os/unix.me
	cp src/os/vxworks.me build/$(CONFIG)/bin/os/vxworks.me
	cp src/os/windows.me build/$(CONFIG)/bin/os/windows.me
	cp src/simple.me build/$(CONFIG)/bin/simple.me
	cp src/standard.me build/$(CONFIG)/bin/standard.me
	cp src/vstudio.es build/$(CONFIG)/bin/vstudio.es
	cp src/xcode.es build/$(CONFIG)/bin/xcode.es
	rm -fr "build/$(CONFIG)/bin/.updated"
	mkdir -p "build/$(CONFIG)/bin/.updated"

#
#   mpr.h
#
DEPS_2 += src/paks/mpr/mpr.h

build/$(CONFIG)/inc/mpr.h: $(DEPS_2)
	@echo '      [Copy] build/$(CONFIG)/inc/mpr.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h build/$(CONFIG)/inc/mpr.h

#
#   me.h
#
build/$(CONFIG)/inc/me.h: $(DEPS_3)
	@echo '      [Copy] build/$(CONFIG)/inc/me.h'

#
#   osdep.h
#
DEPS_4 += src/paks/osdep/osdep.h
DEPS_4 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/inc/osdep.h: $(DEPS_4)
	@echo '      [Copy] build/$(CONFIG)/inc/osdep.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h build/$(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_5 += build/$(CONFIG)/inc/me.h
DEPS_5 += build/$(CONFIG)/inc/mpr.h
DEPS_5 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_5)
	@echo '   [Compile] build/$(CONFIG)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += build/$(CONFIG)/inc/mpr.h
DEPS_6 += build/$(CONFIG)/inc/me.h
DEPS_6 += build/$(CONFIG)/inc/osdep.h
DEPS_6 += build/$(CONFIG)/obj/mprLib.o

build/$(CONFIG)/bin/libmpr.dylib: $(DEPS_6)
	@echo '      [Link] build/$(CONFIG)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmpr.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
DEPS_7 += src/paks/pcre/pcre.h

build/$(CONFIG)/inc/pcre.h: $(DEPS_7)
	@echo '      [Copy] build/$(CONFIG)/inc/pcre.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h build/$(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_8 += build/$(CONFIG)/inc/me.h
DEPS_8 += build/$(CONFIG)/inc/pcre.h

build/$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_8)
	@echo '   [Compile] build/$(CONFIG)/obj/pcre.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_9 += build/$(CONFIG)/inc/pcre.h
DEPS_9 += build/$(CONFIG)/inc/me.h
DEPS_9 += build/$(CONFIG)/obj/pcre.o

build/$(CONFIG)/bin/libpcre.dylib: $(DEPS_9)
	@echo '      [Link] build/$(CONFIG)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 0.8 -current_version 0.8 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
DEPS_10 += src/paks/http/http.h

build/$(CONFIG)/inc/http.h: $(DEPS_10)
	@echo '      [Copy] build/$(CONFIG)/inc/http.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/http/http.h build/$(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_11 += build/$(CONFIG)/inc/me.h
DEPS_11 += build/$(CONFIG)/inc/http.h
DEPS_11 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_11)
	@echo '   [Compile] build/$(CONFIG)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_12 += build/$(CONFIG)/inc/mpr.h
DEPS_12 += build/$(CONFIG)/inc/me.h
DEPS_12 += build/$(CONFIG)/inc/osdep.h
DEPS_12 += build/$(CONFIG)/obj/mprLib.o
DEPS_12 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_12 += build/$(CONFIG)/inc/pcre.h
DEPS_12 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_12 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_12 += build/$(CONFIG)/inc/http.h
DEPS_12 += build/$(CONFIG)/obj/httpLib.o

LIBS_12 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_12 += -lpcre
endif

build/$(CONFIG)/bin/libhttp.dylib: $(DEPS_12)
	@echo '      [Link] build/$(CONFIG)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libhttp.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/httpLib.o" $(LIBPATHS_12) $(LIBS_12) $(LIBS_12) $(LIBS) 
endif

#
#   zlib.h
#
DEPS_13 += src/paks/zlib/zlib.h

build/$(CONFIG)/inc/zlib.h: $(DEPS_13)
	@echo '      [Copy] build/$(CONFIG)/inc/zlib.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h build/$(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_14 += build/$(CONFIG)/inc/me.h
DEPS_14 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_14)
	@echo '   [Compile] build/$(CONFIG)/obj/zlib.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/zlib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_15 += build/$(CONFIG)/inc/zlib.h
DEPS_15 += build/$(CONFIG)/inc/me.h
DEPS_15 += build/$(CONFIG)/obj/zlib.o

build/$(CONFIG)/bin/libzlib.dylib: $(DEPS_15)
	@echo '      [Link] build/$(CONFIG)/bin/libzlib.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libzlib.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libzlib.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   ejs.h
#
DEPS_16 += src/paks/ejs/ejs.h

build/$(CONFIG)/inc/ejs.h: $(DEPS_16)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h build/$(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_17 += src/paks/ejs/ejs.slots.h

build/$(CONFIG)/inc/ejs.slots.h: $(DEPS_17)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.slots.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h build/$(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_18 += src/paks/ejs/ejsByteGoto.h

build/$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_18)
	@echo '      [Copy] build/$(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h build/$(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_19 += build/$(CONFIG)/inc/me.h
DEPS_19 += build/$(CONFIG)/inc/ejs.h
DEPS_19 += build/$(CONFIG)/inc/mpr.h
DEPS_19 += build/$(CONFIG)/inc/pcre.h
DEPS_19 += build/$(CONFIG)/inc/osdep.h
DEPS_19 += build/$(CONFIG)/inc/http.h
DEPS_19 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_19 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_19)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsLib.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/ejsLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
DEPS_20 += build/$(CONFIG)/inc/mpr.h
DEPS_20 += build/$(CONFIG)/inc/me.h
DEPS_20 += build/$(CONFIG)/inc/osdep.h
DEPS_20 += build/$(CONFIG)/obj/mprLib.o
DEPS_20 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_20 += build/$(CONFIG)/inc/pcre.h
DEPS_20 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_20 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_20 += build/$(CONFIG)/inc/http.h
DEPS_20 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_20 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_20 += build/$(CONFIG)/inc/zlib.h
DEPS_20 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_20 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_20 += build/$(CONFIG)/inc/ejs.h
DEPS_20 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_20 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_20 += build/$(CONFIG)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_20 += -lhttp
endif
LIBS_20 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_20 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_20 += -lzlib
endif

build/$(CONFIG)/bin/libejs.dylib: $(DEPS_20)
	@echo '      [Link] build/$(CONFIG)/bin/libejs.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libejs.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libejs.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/ejsLib.o" $(LIBPATHS_20) $(LIBS_20) $(LIBS_20) $(LIBS) 
endif

#
#   ejsc.o
#
DEPS_21 += build/$(CONFIG)/inc/me.h
DEPS_21 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_21)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsc.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/ejsc.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_22 += build/$(CONFIG)/inc/mpr.h
DEPS_22 += build/$(CONFIG)/inc/me.h
DEPS_22 += build/$(CONFIG)/inc/osdep.h
DEPS_22 += build/$(CONFIG)/obj/mprLib.o
DEPS_22 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_22 += build/$(CONFIG)/inc/pcre.h
DEPS_22 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_22 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_22 += build/$(CONFIG)/inc/http.h
DEPS_22 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_22 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_22 += build/$(CONFIG)/inc/zlib.h
DEPS_22 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_22 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_22 += build/$(CONFIG)/inc/ejs.h
DEPS_22 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_22 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_22 += build/$(CONFIG)/obj/ejsLib.o
DEPS_22 += build/$(CONFIG)/bin/libejs.dylib
DEPS_22 += build/$(CONFIG)/obj/ejsc.o

LIBS_22 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_22 += -lhttp
endif
LIBS_22 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_22 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_22 += -lzlib
endif

build/$(CONFIG)/bin/ejsc: $(DEPS_22)
	@echo '      [Link] build/$(CONFIG)/bin/ejsc'
	$(CC) -o build/$(CONFIG)/bin/ejsc -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsc.o" $(LIBPATHS_22) $(LIBS_22) $(LIBS_22) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_23 += src/paks/ejs/ejs.es
DEPS_23 += build/$(CONFIG)/inc/mpr.h
DEPS_23 += build/$(CONFIG)/inc/me.h
DEPS_23 += build/$(CONFIG)/inc/osdep.h
DEPS_23 += build/$(CONFIG)/obj/mprLib.o
DEPS_23 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_23 += build/$(CONFIG)/inc/pcre.h
DEPS_23 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_23 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_23 += build/$(CONFIG)/inc/http.h
DEPS_23 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_23 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_23 += build/$(CONFIG)/inc/zlib.h
DEPS_23 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_23 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_23 += build/$(CONFIG)/inc/ejs.h
DEPS_23 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_23 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_23 += build/$(CONFIG)/obj/ejsLib.o
DEPS_23 += build/$(CONFIG)/bin/libejs.dylib
DEPS_23 += build/$(CONFIG)/obj/ejsc.o
DEPS_23 += build/$(CONFIG)/bin/ejsc

build/$(CONFIG)/bin/ejs.mod: $(DEPS_23)
	( \
	cd src/paks/ejs; \
	echo '   [Compile] ejs.mod' ; \
	../../../build/$(CONFIG)/bin/ejsc --out ../../../build/$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.testme.es
#
DEPS_24 += src/tm/ejs.testme.es

build/$(CONFIG)/bin/ejs.testme.es: $(DEPS_24)
	@echo '      [Copy] build/$(CONFIG)/bin/ejs.testme.es'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/tm/ejs.testme.es build/$(CONFIG)/bin/ejs.testme.es

#
#   ejs.testme.mod
#
DEPS_25 += src/tm/ejs.testme.es
DEPS_25 += build/$(CONFIG)/inc/mpr.h
DEPS_25 += build/$(CONFIG)/inc/me.h
DEPS_25 += build/$(CONFIG)/inc/osdep.h
DEPS_25 += build/$(CONFIG)/obj/mprLib.o
DEPS_25 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_25 += build/$(CONFIG)/inc/pcre.h
DEPS_25 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_25 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_25 += build/$(CONFIG)/inc/http.h
DEPS_25 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_25 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_25 += build/$(CONFIG)/inc/zlib.h
DEPS_25 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_25 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_25 += build/$(CONFIG)/inc/ejs.h
DEPS_25 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_25 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_25 += build/$(CONFIG)/obj/ejsLib.o
ifeq ($(ME_COM_EJS),1)
    DEPS_25 += build/$(CONFIG)/bin/libejs.dylib
endif
DEPS_25 += build/$(CONFIG)/obj/ejsc.o
ifeq ($(ME_COM_EJS),1)
    DEPS_25 += build/$(CONFIG)/bin/ejsc
endif

build/$(CONFIG)/bin/ejs.testme.mod: $(DEPS_25)
	( \
	cd src/tm; \
	echo '   [Compile] ejs.testme.mod' ; \
	../../build/$(CONFIG)/bin/ejsc --debug --out ../../build/$(CONFIG)/bin/ejs.testme.mod --optimize 9 ejs.testme.es ; \
	)

#
#   ejs.o
#
DEPS_26 += build/$(CONFIG)/inc/me.h
DEPS_26 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_26)
	@echo '   [Compile] build/$(CONFIG)/obj/ejs.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/ejs.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejs.c

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_27 += build/$(CONFIG)/inc/mpr.h
DEPS_27 += build/$(CONFIG)/inc/me.h
DEPS_27 += build/$(CONFIG)/inc/osdep.h
DEPS_27 += build/$(CONFIG)/obj/mprLib.o
DEPS_27 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_27 += build/$(CONFIG)/inc/pcre.h
DEPS_27 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_27 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_27 += build/$(CONFIG)/inc/http.h
DEPS_27 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_27 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_27 += build/$(CONFIG)/inc/zlib.h
DEPS_27 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_27 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_27 += build/$(CONFIG)/inc/ejs.h
DEPS_27 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_27 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_27 += build/$(CONFIG)/obj/ejsLib.o
DEPS_27 += build/$(CONFIG)/bin/libejs.dylib
DEPS_27 += build/$(CONFIG)/obj/ejs.o

LIBS_27 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_27 += -lhttp
endif
LIBS_27 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_27 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_27 += -lzlib
endif

build/$(CONFIG)/bin/ejs: $(DEPS_27)
	@echo '      [Link] build/$(CONFIG)/bin/ejs'
	$(CC) -o build/$(CONFIG)/bin/ejs -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejs.o" $(LIBPATHS_27) $(LIBS_27) $(LIBS_27) $(LIBS) -ledit 
endif


#
#   http-ca-crt
#
DEPS_28 += src/paks/http/ca.crt

build/$(CONFIG)/bin/ca.crt: $(DEPS_28)
	@echo '      [Copy] build/$(CONFIG)/bin/ca.crt'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/http/ca.crt build/$(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_29 += build/$(CONFIG)/inc/me.h
DEPS_29 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_29)
	@echo '   [Compile] build/$(CONFIG)/obj/http.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/http.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/http.c

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_30 += build/$(CONFIG)/inc/mpr.h
DEPS_30 += build/$(CONFIG)/inc/me.h
DEPS_30 += build/$(CONFIG)/inc/osdep.h
DEPS_30 += build/$(CONFIG)/obj/mprLib.o
DEPS_30 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_30 += build/$(CONFIG)/inc/pcre.h
DEPS_30 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_30 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_30 += build/$(CONFIG)/inc/http.h
DEPS_30 += build/$(CONFIG)/obj/httpLib.o
DEPS_30 += build/$(CONFIG)/bin/libhttp.dylib
DEPS_30 += build/$(CONFIG)/obj/http.o

LIBS_30 += -lhttp
LIBS_30 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_30 += -lpcre
endif

build/$(CONFIG)/bin/http: $(DEPS_30)
	@echo '      [Link] build/$(CONFIG)/bin/http'
	$(CC) -o build/$(CONFIG)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/http.o" $(LIBPATHS_30) $(LIBS_30) $(LIBS_30) $(LIBS) 
endif

#
#   est.h
#
DEPS_31 += src/paks/est/est.h

build/$(CONFIG)/inc/est.h: $(DEPS_31)
	@echo '      [Copy] build/$(CONFIG)/inc/est.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/est/est.h build/$(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_32 += build/$(CONFIG)/inc/me.h
DEPS_32 += build/$(CONFIG)/inc/est.h
DEPS_32 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_32)
	@echo '   [Compile] build/$(CONFIG)/obj/estLib.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/estLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_33 += build/$(CONFIG)/inc/est.h
DEPS_33 += build/$(CONFIG)/inc/me.h
DEPS_33 += build/$(CONFIG)/inc/osdep.h
DEPS_33 += build/$(CONFIG)/obj/estLib.o

build/$(CONFIG)/bin/libest.dylib: $(DEPS_33)
	@echo '      [Link] build/$(CONFIG)/bin/libest.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libest.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libest.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_34 += build/$(CONFIG)/inc/me.h
DEPS_34 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_34)
	@echo '   [Compile] build/$(CONFIG)/obj/mprSsl.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/mprSsl.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_35 += build/$(CONFIG)/inc/mpr.h
DEPS_35 += build/$(CONFIG)/inc/me.h
DEPS_35 += build/$(CONFIG)/inc/osdep.h
DEPS_35 += build/$(CONFIG)/obj/mprLib.o
DEPS_35 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_35 += build/$(CONFIG)/inc/est.h
DEPS_35 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_35 += build/$(CONFIG)/bin/libest.dylib
endif
DEPS_35 += build/$(CONFIG)/obj/mprSsl.o

LIBS_35 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_35 += -lssl
    LIBPATHS_35 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_35 += -lcrypto
    LIBPATHS_35 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_35 += -lest
endif

build/$(CONFIG)/bin/libmprssl.dylib: $(DEPS_35)
	@echo '      [Link] build/$(CONFIG)/bin/libmprssl.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libmprssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmprssl.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_35) $(LIBS_35) $(LIBS_35) $(LIBS) 

#
#   testme.h
#
DEPS_36 += src/tm/testme.h

build/$(CONFIG)/inc/testme.h: $(DEPS_36)
	@echo '      [Copy] build/$(CONFIG)/inc/testme.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/tm/testme.h build/$(CONFIG)/inc/testme.h

#
#   libtestme.o
#
DEPS_37 += build/$(CONFIG)/inc/me.h
DEPS_37 += build/$(CONFIG)/inc/testme.h
DEPS_37 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/libtestme.o: \
    src/tm/libtestme.c $(DEPS_37)
	@echo '   [Compile] build/$(CONFIG)/obj/libtestme.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/libtestme.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/tm/libtestme.c

#
#   libtestme
#
DEPS_38 += build/$(CONFIG)/inc/testme.h
DEPS_38 += build/$(CONFIG)/inc/me.h
DEPS_38 += build/$(CONFIG)/inc/osdep.h
DEPS_38 += build/$(CONFIG)/obj/libtestme.o

build/$(CONFIG)/bin/libtestme.dylib: $(DEPS_38)
	@echo '      [Link] build/$(CONFIG)/bin/libtestme.dylib'
	$(CC) -dynamiclib -o build/$(CONFIG)/bin/libtestme.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libtestme.dylib -compatibility_version 0.8 -current_version 0.8 "build/$(CONFIG)/obj/libtestme.o" $(LIBS) 

#
#   me.mod
#
DEPS_39 += src/me.es
DEPS_39 += src/paks/ejs-version/Version.es
DEPS_39 += build/$(CONFIG)/inc/mpr.h
DEPS_39 += build/$(CONFIG)/inc/me.h
DEPS_39 += build/$(CONFIG)/inc/osdep.h
DEPS_39 += build/$(CONFIG)/obj/mprLib.o
DEPS_39 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_39 += build/$(CONFIG)/inc/pcre.h
DEPS_39 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_39 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_39 += build/$(CONFIG)/inc/http.h
DEPS_39 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_39 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_39 += build/$(CONFIG)/inc/zlib.h
DEPS_39 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_39 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_39 += build/$(CONFIG)/inc/ejs.h
DEPS_39 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_39 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_39 += build/$(CONFIG)/obj/ejsLib.o
ifeq ($(ME_COM_EJS),1)
    DEPS_39 += build/$(CONFIG)/bin/libejs.dylib
endif
DEPS_39 += build/$(CONFIG)/obj/ejsc.o
ifeq ($(ME_COM_EJS),1)
    DEPS_39 += build/$(CONFIG)/bin/ejsc
endif

build/$(CONFIG)/bin/me.mod: $(DEPS_39)
	( \
	cd .; \
	./build/$(CONFIG)/bin/ejsc --debug --out ./build/$(CONFIG)/bin/me.mod --optimize 9 src/me.es src/paks/ejs-version/Version.es ; \
	)

#
#   me.o
#
DEPS_40 += build/$(CONFIG)/inc/me.h
DEPS_40 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/me.o: \
    src/me.c $(DEPS_40)
	@echo '   [Compile] build/$(CONFIG)/obj/me.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/me.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/me.c

#
#   me
#
DEPS_41 += build/$(CONFIG)/inc/mpr.h
DEPS_41 += build/$(CONFIG)/inc/me.h
DEPS_41 += build/$(CONFIG)/inc/osdep.h
DEPS_41 += build/$(CONFIG)/obj/mprLib.o
DEPS_41 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_41 += build/$(CONFIG)/inc/pcre.h
DEPS_41 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_41 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_41 += build/$(CONFIG)/inc/http.h
DEPS_41 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_41 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_41 += build/$(CONFIG)/inc/zlib.h
DEPS_41 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_41 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_41 += build/$(CONFIG)/inc/ejs.h
DEPS_41 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_41 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_41 += build/$(CONFIG)/obj/ejsLib.o
ifeq ($(ME_COM_EJS),1)
    DEPS_41 += build/$(CONFIG)/bin/libejs.dylib
endif
DEPS_41 += build/$(CONFIG)/obj/ejsc.o
ifeq ($(ME_COM_EJS),1)
    DEPS_41 += build/$(CONFIG)/bin/ejsc
endif
DEPS_41 += build/$(CONFIG)/bin/me.mod
DEPS_41 += build/$(CONFIG)/obj/me.o

LIBS_41 += -lmpr
ifeq ($(ME_COM_HTTP),1)
    LIBS_41 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_41 += -lpcre
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_41 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_41 += -lzlib
endif

build/$(CONFIG)/bin/me: $(DEPS_41)
	@echo '      [Link] build/$(CONFIG)/bin/me'
	$(CC) -o build/$(CONFIG)/bin/me -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/me.o" $(LIBPATHS_41) $(LIBS_41) $(LIBS_41) $(LIBS) 

#
#   testme.mod
#
DEPS_42 += src/tm/testme.es
DEPS_42 += build/$(CONFIG)/inc/mpr.h
DEPS_42 += build/$(CONFIG)/inc/me.h
DEPS_42 += build/$(CONFIG)/inc/osdep.h
DEPS_42 += build/$(CONFIG)/obj/mprLib.o
DEPS_42 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_42 += build/$(CONFIG)/inc/pcre.h
DEPS_42 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_42 += build/$(CONFIG)/inc/http.h
DEPS_42 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_42 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_42 += build/$(CONFIG)/inc/zlib.h
DEPS_42 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_42 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_42 += build/$(CONFIG)/inc/ejs.h
DEPS_42 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_42 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_42 += build/$(CONFIG)/obj/ejsLib.o
ifeq ($(ME_COM_EJS),1)
    DEPS_42 += build/$(CONFIG)/bin/libejs.dylib
endif
DEPS_42 += build/$(CONFIG)/obj/ejsc.o
ifeq ($(ME_COM_EJS),1)
    DEPS_42 += build/$(CONFIG)/bin/ejsc
endif

build/$(CONFIG)/bin/testme.mod: $(DEPS_42)
	( \
	cd src/tm; \
	echo '   [Compile] testme.mod' ; \
	../../build/$(CONFIG)/bin/ejsc --debug --out ../../build/$(CONFIG)/bin/testme.mod --optimize 9 testme.es ; \
	)

#
#   testme.o
#
DEPS_43 += build/$(CONFIG)/inc/me.h
DEPS_43 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/testme.o: \
    src/tm/testme.c $(DEPS_43)
	@echo '   [Compile] build/$(CONFIG)/obj/testme.o'
	$(CC) -c $(DFLAGS) -o build/$(CONFIG)/obj/testme.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/tm/testme.c

#
#   testme
#
DEPS_44 += build/$(CONFIG)/inc/mpr.h
DEPS_44 += build/$(CONFIG)/inc/me.h
DEPS_44 += build/$(CONFIG)/inc/osdep.h
DEPS_44 += build/$(CONFIG)/obj/mprLib.o
DEPS_44 += build/$(CONFIG)/bin/libmpr.dylib
DEPS_44 += build/$(CONFIG)/inc/pcre.h
DEPS_44 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_44 += build/$(CONFIG)/bin/libpcre.dylib
endif
DEPS_44 += build/$(CONFIG)/inc/http.h
DEPS_44 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_44 += build/$(CONFIG)/bin/libhttp.dylib
endif
DEPS_44 += build/$(CONFIG)/inc/zlib.h
DEPS_44 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_44 += build/$(CONFIG)/bin/libzlib.dylib
endif
DEPS_44 += build/$(CONFIG)/inc/ejs.h
DEPS_44 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_44 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_44 += build/$(CONFIG)/obj/ejsLib.o
ifeq ($(ME_COM_EJS),1)
    DEPS_44 += build/$(CONFIG)/bin/libejs.dylib
endif
DEPS_44 += build/$(CONFIG)/obj/ejsc.o
ifeq ($(ME_COM_EJS),1)
    DEPS_44 += build/$(CONFIG)/bin/ejsc
endif
DEPS_44 += build/$(CONFIG)/bin/testme.mod
DEPS_44 += build/$(CONFIG)/bin/ejs.testme.mod
DEPS_44 += build/$(CONFIG)/obj/testme.o

ifeq ($(ME_COM_EJS),1)
    LIBS_44 += -lejs
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_44 += -lhttp
endif
LIBS_44 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_44 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_44 += -lzlib
endif

build/$(CONFIG)/bin/testme: $(DEPS_44)
	@echo '      [Link] build/$(CONFIG)/bin/testme'
	$(CC) -o build/$(CONFIG)/bin/testme -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/testme.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) 

#
#   testme.es
#
DEPS_45 += src/tm/testme.es

build/$(CONFIG)/bin/testme.es: $(DEPS_45)
	@echo '      [Copy] build/$(CONFIG)/bin/testme.es'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/tm/testme.es build/$(CONFIG)/bin/testme.es

#
#   stop
#
stop: $(DEPS_46)

#
#   installBinary
#
installBinary: $(DEPS_47)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "0.8.3" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp build/$(CONFIG)/bin/me $(ME_VAPP_PREFIX)/bin/me ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/me" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/me" "$(ME_BIN_PREFIX)/me" ; \
	cp build/$(CONFIG)/bin/testme $(ME_VAPP_PREFIX)/bin/testme ; \
	rm -f "$(ME_BIN_PREFIX)/testme" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/testme" "$(ME_BIN_PREFIX)/testme" ; \
	cp build/$(CONFIG)/bin/ejs $(ME_VAPP_PREFIX)/bin/ejs ; \
	cp build/$(CONFIG)/bin/ejsc $(ME_VAPP_PREFIX)/bin/ejsc ; \
	cp build/$(CONFIG)/bin/http $(ME_VAPP_PREFIX)/bin/http ; \
	cp build/$(CONFIG)/bin/libejs.dylib $(ME_VAPP_PREFIX)/bin/libejs.dylib ; \
	cp build/$(CONFIG)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp build/$(CONFIG)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp build/$(CONFIG)/bin/libmprssl.dylib $(ME_VAPP_PREFIX)/bin/libmprssl.dylib ; \
	cp build/$(CONFIG)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	cp build/$(CONFIG)/bin/libzlib.dylib $(ME_VAPP_PREFIX)/bin/libzlib.dylib ; \
	cp build/$(CONFIG)/bin/libtestme.dylib $(ME_VAPP_PREFIX)/bin/libtestme.dylib ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libssl*.dylib* $(ME_VAPP_PREFIX)/bin/libssl*.dylib* ; \
	cp build/$(CONFIG)/bin/libcrypto*.dylib* $(ME_VAPP_PREFIX)/bin/libcrypto*.dylib* ; \
	fi ; \
	cp build/$(CONFIG)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	cp build/$(CONFIG)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	cp build/$(CONFIG)/bin/me.mod $(ME_VAPP_PREFIX)/bin/me.mod ; \
	cp build/$(CONFIG)/bin/testme.mod $(ME_VAPP_PREFIX)/bin/testme.mod ; \
	cp build/$(CONFIG)/bin/ejs.testme.mod $(ME_VAPP_PREFIX)/bin/ejs.testme.mod ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp src/tm/testme.h $(ME_VAPP_PREFIX)/inc/testme.h ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/configure" ; \
	cp src/configure/appweb.me $(ME_VAPP_PREFIX)/bin/configure/appweb.me ; \
	cp src/configure/compiler.me $(ME_VAPP_PREFIX)/bin/configure/compiler.me ; \
	cp src/configure/lib.me $(ME_VAPP_PREFIX)/bin/configure/lib.me ; \
	cp src/configure/link.me $(ME_VAPP_PREFIX)/bin/configure/link.me ; \
	cp src/configure/rc.me $(ME_VAPP_PREFIX)/bin/configure/rc.me ; \
	cp src/configure/testme.me $(ME_VAPP_PREFIX)/bin/configure/testme.me ; \
	cp src/configure/vxworks.me $(ME_VAPP_PREFIX)/bin/configure/vxworks.me ; \
	cp src/configure/winsdk.me $(ME_VAPP_PREFIX)/bin/configure/winsdk.me ; \
	cp src/configure.es $(ME_VAPP_PREFIX)/bin/configure.es ; \
	cp src/generate.es $(ME_VAPP_PREFIX)/bin/generate.es ; \
	cp src/master-main.me $(ME_VAPP_PREFIX)/bin/master-main.me ; \
	cp src/master-start.me $(ME_VAPP_PREFIX)/bin/master-start.me ; \
	cp src/me.es $(ME_VAPP_PREFIX)/bin/me.es ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/os" ; \
	cp src/os/freebsd.me $(ME_VAPP_PREFIX)/bin/os/freebsd.me ; \
	cp src/os/gcc.me $(ME_VAPP_PREFIX)/bin/os/gcc.me ; \
	cp src/os/linux.me $(ME_VAPP_PREFIX)/bin/os/linux.me ; \
	cp src/os/macosx.me $(ME_VAPP_PREFIX)/bin/os/macosx.me ; \
	cp src/os/solaris.me $(ME_VAPP_PREFIX)/bin/os/solaris.me ; \
	cp src/os/unix.me $(ME_VAPP_PREFIX)/bin/os/unix.me ; \
	cp src/os/vxworks.me $(ME_VAPP_PREFIX)/bin/os/vxworks.me ; \
	cp src/os/windows.me $(ME_VAPP_PREFIX)/bin/os/windows.me ; \
	cp src/simple.me $(ME_VAPP_PREFIX)/bin/simple.me ; \
	cp src/standard.me $(ME_VAPP_PREFIX)/bin/standard.me ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/tm" ; \
	cp src/tm/ejs.testme.es $(ME_VAPP_PREFIX)/bin/tm/ejs.testme.es ; \
	cp src/tm/libtestme.c $(ME_VAPP_PREFIX)/bin/tm/libtestme.c ; \
	cp src/tm/sample.ct $(ME_VAPP_PREFIX)/bin/tm/sample.ct ; \
	cp src/tm/testme.c $(ME_VAPP_PREFIX)/bin/tm/testme.c ; \
	cp src/tm/testme.es $(ME_VAPP_PREFIX)/bin/tm/testme.es ; \
	cp src/tm/testme.h $(ME_VAPP_PREFIX)/bin/tm/testme.h ; \
	cp src/tm/testme.me $(ME_VAPP_PREFIX)/bin/tm/testme.me ; \
	cp src/vstudio.es $(ME_VAPP_PREFIX)/bin/vstudio.es ; \
	cp src/xcode.es $(ME_VAPP_PREFIX)/bin/xcode.es ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/public/man/me.1 $(ME_VAPP_PREFIX)/doc/man/man1/me.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/me.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/me.1" "$(ME_MAN_PREFIX)/man1/me.1" ; \
	cp doc/public/man/testme.1 $(ME_VAPP_PREFIX)/doc/man/man1/testme.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/testme.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/testme.1" "$(ME_MAN_PREFIX)/man1/testme.1" ; \
	)

#
#   start
#
start: $(DEPS_48)

#
#   install
#
DEPS_49 += stop
DEPS_49 += installBinary
DEPS_49 += start

install: $(DEPS_49)

#
#   uninstall
#
DEPS_50 += stop

uninstall: $(DEPS_50)
	( \
	cd .; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

#
#   version
#
version: $(DEPS_51)
	( \
	cd build/macosx-x64-release/bin; \
	echo 0.8.3 ; \
	)

