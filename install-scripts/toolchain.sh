#!/bin/bash

set -ex

################################################################################
# Install GNU RISC-V toolchain
################################################################################

mkdir -p /toolchain && cd /toolchain
git clone --depth 1 --shallow-submodules https://github.com/riscv/riscv-gnu-toolchain .
apt-get -yqq install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
./configure --prefix=/opt/riscv --with-cmodel=medany --with-multilib-generator="rv32im_zicsr_zicond-ilp32--;rv64im_zicsr_zicond-lp64--" --enable-debug-info && make -j$(nproc) && make clean
echo 'PATH="/opt/riscv/bin:$PATH"' >> /root/.bashrc
