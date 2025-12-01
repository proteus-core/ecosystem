BASE_DIR = $(shell pwd)/../..
TARGET_DIR = $(BASE_DIR)/riscv-formal/cores/proteus/
CORE ?= riscv.CoreFormal

all: formal

Core.v: proteus.v
	cd $(BASE_DIR)/core && sbt "runMain $(CORE)" && cp Core.v $(BASE_DIR)/formal-verification/riscv-formal/proteus.v

setup: Core.v
	mkdir -p $(TARGET_DIR)
	cp checks.cfg wrapper.sv proteus.v $(TARGET_DIR)
	cd $(TARGET_DIR) && python3 ../../checks/genchecks.py

formal: setup
	make -C $(TARGET_DIR)/checks -j$(nproc)

formal-%: setup
	$(MAKE) -C $(TARGET_DIR)/checks $(subst formal-,,$@)_ch0
