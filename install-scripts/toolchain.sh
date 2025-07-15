#!/bin/bash

set -ex

################################################################################
# Install GNU RISC-V toolchain
################################################################################

mkdir -p /toolchain && cd /toolchain
git clone https://github.com/riscv/riscv-gnu-toolchain .
apt-get -yqq install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
./configure --prefix=/opt/riscv --with-arch=rv32im_zicsr --with-abi=ilp32 && make && make clean
export PATH="${PATH}:/opt/riscv/bin"
