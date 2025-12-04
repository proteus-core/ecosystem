#!/bin/bash

set -ex

git clone --recurse-submodules --depth 1 --shallow-submodules https://github.com/KULeuven-COSIC/eval-hd.git
. /ecosystem/waveform-analysis/.venv/bin/activate
pip install pyosys
