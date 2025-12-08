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
MKDIR   = mkdir -p

CFLAGS =
#CFLAGS += -O2
CFLAGS += -O0
CFLAGS += -march=rv32im_zicsr
CFLAGS += -mabi=ilp32

LDFLAGS =
LDFLAGS += -T$(PROTEUS_BSP_SRCDIR)/link.ld

##############################################################################

DHRYSTONE_BUILDDIR = $(BUILDDIR)/dhrystone

all: $(DHRYSTONE_BUILDDIR)
all: $(DHRYSTONE_BUILDDIR)/dry.bin

$(DHRYSTONE_BUILDDIR):
	$(MKDIR) $(DHRYSTONE_BUILDDIR)

$(DHRYSTONE_BUILDDIR)/dry.bin: $(DHRYSTONE_BUILDDIR)/dry
	$(OBJCOPY) -O binary $< $@

$(DHRYSTONE_BUILDDIR)/dry: $(DHRYSTONE_BUILDDIR)/dry1.o
$(DHRYSTONE_BUILDDIR)/dry: $(DHRYSTONE_BUILDDIR)/dry2.o
	$(CC) $(LDFLAGS) $^ -lproteus -o $@

$(DHRYSTONE_BUILDDIR)/dry1.o: dry.c
	$(CC) $(CFLAGS) -DTIME -c $< -o $@

$(DHRYSTONE_BUILDDIR)/dry2.o: dry.c
	$(CC) $(CFLAGS) -DTIME -DPASS2 -c $< -o $@

clean:
	$(RM) -r $(DHRYSTONE_BUILDDIR)
