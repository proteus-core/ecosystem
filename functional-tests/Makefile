CORE ?= riscv.CoreExtMem
PIPELINE ?= Static
ISA ?= RV32I
BUILD_CORE ?= 1
64BIT ?= 0
RISCV_PREFIX ?= riscv64-unknown-elf

TESTS_DIR = $(abspath .)
BASE_DIR = $(abspath $(TESTS_DIR)/../core)
RISCV_TESTS_DIR = $(TESTS_DIR)/riscv-tests
ISA_TESTS_DIR = $(RISCV_TESTS_DIR)/isa
BUILD_DIR = $(TESTS_DIR)/build
SIM_DIR ?= $(abspath $(TESTS_DIR)/../simulation)
SIM_EXE = $(SIM_DIR)/build/sim

CC = $(RISCV_PREFIX)-gcc
LD = $(RISCV_PREFIX)-gcc
OBJCOPY = $(RISCV_PREFIX)-objcopy
ARCHFLAGS ?= -march=rv32im_zicsr_zicond -mabi=ilp32

ifeq ($(BUILD_CORE),1)
FORCE = FORCE
else
FORCE =
endif

-include $(CUSTOM_TESTS_DIR)/Makefile.include

TEST_DIRS ?= $(ISA_TESTS_DIR)/rv32ui $(ISA_TESTS_DIR)/rv32mi $(ISA_TESTS_DIR)/rv32si $(ISA_TESTS_DIR)/rv32um $(TESTS_DIR)/zicond-test $(CUSTOM_TESTS_DIR)

ifeq ($(64BIT),1)
TEST_DIRS = $(ISA_TESTS_DIR)/rv64ui $(ISA_TESTS_DIR)/rv64mi $(ISA_TESTS_DIR)/rv64si $(ISA_TESTS_DIR)/rv64um $(TESTS_DIR)/zicond-test $(CUSTOM_TESTS_DIR)
ARCHFLAGS = -march=rv64im_zicsr_zicond -mabi=lp64
endif

ALL_ISA_TESTS = $(shell find $(TEST_DIRS) -name '*.S')
UNSUPPORTED_TESTS = %fence_i.S %breakpoint.S %ma_data.S %pmpaddr.S %instret_overflow.S %ld_st.S %sd.S %st_ld.S %ld.S
ALL_TESTS = $(filter-out $(UNSUPPORTED_TESTS),$(ALL_ISA_TESTS))

# Tests from different suites can have the same file name (e.g. rv32mi/csr.S
# and rv32si/csr.S), so every suite is built in its own subdirectory of
# BUILD_DIR, named after the suite's directory.
suite_name = $(notdir $(patsubst %/,%,$(dir $(1))))
ALL_TARGETS = $(foreach test,$(ALL_TESTS),$(BUILD_DIR)/$(call suite_name,$(test))/$(notdir $(basename $(test))).pass)

# The user-level test suites are also run on top of the riscv-tests virtual memory environment
# (env/v), a small demand-paging kernel, adapted to Proteus by env-v/riscv_test.h. Each test is
# compiled together with the environment sources, mirroring the upstream riscv-tests build.
V_ENV_DIR = $(RISCV_TESTS_DIR)/env/v
V_SRCS = $(V_ENV_DIR)/entry.S $(V_ENV_DIR)/vm.c $(V_ENV_DIR)/string.c

VTEST_DIRS = $(ISA_TESTS_DIR)/rv32ui $(ISA_TESTS_DIR)/rv32um
# The F extension is only needed to assemble an fssr encoding vm.c uses as reference data on its
# (unexercised) FP recovery path; no FP instructions are executed.
V_ARCHFLAGS = -march=rv32imf_zicsr_zifencei_zicond -mabi=ilp32
ifeq ($(64BIT),1)
VTEST_DIRS = $(ISA_TESTS_DIR)/rv64ui $(ISA_TESTS_DIR)/rv64um
V_ARCHFLAGS = -march=rv64imf_zicsr_zifencei_zicond -mabi=lp64
endif

ALL_VTESTS = $(filter-out $(UNSUPPORTED_TESTS),$(shell find $(VTEST_DIRS) -name '*.S'))
ALL_VTARGETS = $(foreach test,$(ALL_VTESTS),$(BUILD_DIR)/$(call suite_name,$(test))-v/$(notdir $(basename $(test))).pass)

CFLAGS = $(ARCHFLAGS)

all: $(ALL_TARGETS) $(ALL_VTARGETS)

.SECONDARY:

define SUITE_RULES
$(BUILD_DIR)/$(notdir $(1))/%.o: $(1)/%.S
	mkdir -p $$(@D)
	$$(CC) $$(CFLAGS) -I$$(TESTS_DIR) -I$$(ISA_TESTS_DIR)/macros/scalar -c -o $$@ $$<
endef

$(foreach d,$(TEST_DIRS),$(eval $(call SUITE_RULES,$(d))))

define VSUITE_RULES
$(BUILD_DIR)/$(notdir $(1))-v/%.elf: $(1)/%.S $(V_SRCS) env-v/riscv_test.h tests-v.ld
	mkdir -p $$(@D)
	$$(CC) $$(V_ARCHFLAGS) -mcmodel=medany -std=gnu99 -O2 -ffreestanding -nostdlib -nostartfiles \
		-DENTROPY=0x$$$$(echo $$@ | md5sum | cut -c 1-7) \
		-Ienv-v -I$$(ISA_TESTS_DIR)/macros/scalar \
		-T tests-v.ld $$(V_SRCS) $$< -o $$@
endef

$(foreach d,$(VTEST_DIRS),$(eval $(call VSUITE_RULES,$(d))))

%.elf: %.o
	$(LD) $(ARCHFLAGS) -ffreestanding -nostdlib -T tests.ld -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -O binary $^ $@

$(SIM_EXE): $(FORCE)
	make -C $(SIM_DIR) CORE=$(CORE) PIPELINE=$(PIPELINE) ISA=$(ISA)

.PHONY: FORCE

%.pass: %.bin $(SIM_EXE)
	cd $(BASE_DIR); $(SIM_EXE) $<
	touch $@

clean:
	rm -rf $(BUILD_DIR)
