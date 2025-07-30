#!/bin/bash

set -ex

apt-get install -yqq build-essential clang lld bison flex libreadline-dev gawk tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev
git clone --recurse-submodules https://github.com/KULeuven-COSIC/eval-hd.git
cd eval-hd/yosys
make config-gcc
make -j$(nproc)
make install
