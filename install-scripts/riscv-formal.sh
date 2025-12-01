#!/bin/bash

set -ex

git clone https://github.com/YosysHQ/riscv-formal.git
git clone https://github.com/YosysHQ/sby
cd sby
make install

python3 -m pip install click --break-system-packages

cd ..

apt update && apt install -y cmake

git clone https://github.com/boolector/boolector
cd boolector
./contrib/setup-btor2tools.sh
./contrib/setup-lingeling.sh
./configure.sh
make -C build -j$(nproc)
cp build/bin/{boolector,btor*} /usr/local/bin/
cp deps/btor2tools/build/bin/btorsim /usr/local/bin/
