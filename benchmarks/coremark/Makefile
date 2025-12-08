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

COREMARK_BUILDDIR = $(BUILDDIR)/coremark

CFLAGS += -DITERATIONS=1500
CFLAGS += -DPERFORMANCE_RUN=1
#CFLAGS += -DVALIDATION_RUN=1

FLAGS_STR = "$(CFLAGS) $(LDFLAGS)"

OBJECTS =
OBJECTS += $(COREMARK_BUILDDIR)/core_list_join.o
OBJECTS += $(COREMARK_BUILDDIR)/core_main.o
OBJECTS += $(COREMARK_BUILDDIR)/core_matrix.o
OBJECTS += $(COREMARK_BUILDDIR)/core_state.o
OBJECTS += $(COREMARK_BUILDDIR)/core_util.o
OBJECTS += $(COREMARK_BUILDDIR)/core_portme.o

.PHONY: all
all: $(COREMARK_BUILDDIR)
all: $(COREMARK_BUILDDIR)/core.bin

$(COREMARK_BUILDDIR):
	$(MKDIR) $(COREMARK_BUILDDIR)

$(COREMARK_BUILDDIR)/core.bin: $(COREMARK_BUILDDIR)/core
	$(OBJCOPY) -O binary $< $@

$(COREMARK_BUILDDIR)/core: $(OBJECTS)
	$(CC) $(LDFLAGS) $^ -lproteus -o $@

$(COREMARK_BUILDDIR)/%.o: %.c $(lastword $(MAKEFILE_LIST)) coremark.h core_portme.h
	$(CC) $(CFLAGS) -DFLAGS_STR=\"$(FLAGS_STR)\" -c $< -o $@

.PHONY: clean
clean:
	$(RM) -r $(COREMARK_BUILDDIR)
