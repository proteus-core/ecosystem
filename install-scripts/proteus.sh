#!/bin/bash

set -ex

git clone --recurse-submodules https://github.com/proteus-core/proteus.git core
make -C simulation clean
make -C simulation CORE=riscv.CoreDynamicExtMem
make -C functional-tests CORE=riscv.CoreDynamicExtMem BUILD_CORE=0 RISCV_PREFIX=riscv64-unknown-elf
