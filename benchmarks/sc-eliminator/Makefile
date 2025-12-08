MAKEFILE_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

##############################################################################
# TODO: Avoid duplication of the following macros by always running 
#       a benchmark suite from the Makefile in the top-level repository
INSTALLDIR         ?= $(MAKEFILE_DIR)../../install
BUILDDIR           ?= $(MAKEFILE_DIR)../../build
TARGET_TRIPLE      ?= riscv32-unknown-elf
PROTEUS_BSP_SRCDIR ?= $(MAKEFILE_DIR)../../proteus-bsp

CC      = $(INSTALLDIR)/bin/$(TARGET_TRIPLE)-clang
OBJCOPY = $(INSTALLDIR)/bin/$(TARGET_TRIPLE)-objcopy
PROTEUS = $(INSTALLDIR)/bin/proteus-static
MKDIR   = mkdir -p

CFLAGS =
CFLAGS += -O2
CFLAGS += -march=rv32im_zicsr
CFLAGS += -mabi=ilp32

LDFLAGS =
LDFLAGS += -T$(PROTEUS_BSP_SRCDIR)/link.ld

##############################################################################

SC_ELIMINATOR_BUILDDIR = $(BUILDDIR)/sc-eliminator

.PHONY: all
all: $(SC_ELIMINATOR_BUILDDIR)

$(SC_ELIMINATOR_BUILDDIR):
	$(MKDIR) $(SC_ELIMINATOR_BUILDDIR)

.PHONY: clean
clean:
	$(RM) -r $(COREMARK_BUILDDIR)
