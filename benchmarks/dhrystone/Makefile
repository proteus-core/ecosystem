MAKEFILE_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR           ?= $(MAKEFILE_DIR)/build
PROTEUS_BSP_SRCDIR ?= $(MAKEFILE_DIR)../../newlib-bsp

RISCV_PREFIX ?= riscv64-unknown-elf
64BIT ?= 0
CC = $(RISCV_PREFIX)-gcc
AS = $(RISCV_PREFIX)-as
OBJDUMP = $(RISCV_PREFIX)-objdump
OBJCOPY = $(RISCV_PREFIX)-objcopy
AR = $(RISCV_PREFIX)-ar
MKDIR   = mkdir -p

ARCHFLAGS ?= -march=rv32im_zicsr_zifencei_zicond -mabi=ilp32
ifeq ($(64BIT),1)
ARCHFLAGS = -march=rv64im_zicsr_zifencei_zicond -mabi=lp64 -mcmodel=medany
endif

CFLAGS = -Wall -O2 -I$(PROTEUS_BSP_SRCDIR) $(ARCHFLAGS)

LDFLAGS =
LDFLAGS += -T$(PROTEUS_BSP_SRCDIR)/link.ld $(ARCHFLAGS)

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
	$(CC) $(LDFLAGS) $^ -o $@ $(PROTEUS_BSP_SRCDIR)/libproteus.a

$(DHRYSTONE_BUILDDIR)/dry1.o: dry.c
	$(CC) $(CFLAGS) -DTIME -c $< -o $@

$(DHRYSTONE_BUILDDIR)/dry2.o: dry.c
	$(CC) $(CFLAGS) -DTIME -DPASS2 -c $< -o $@

clean:
	make clean -C $(PROTEUS_BSP_SRCDIR)
	$(RM) -r $(DHRYSTONE_BUILDDIR)
