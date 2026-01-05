#!/bin/bash

set -ex

git clone --recurse-submodules --depth 1 --shallow-submodules https://github.com/KULeuven-COSIC/eval-hd.git
. "$(dirname "$0")/../waveform-analysis/.venv/bin/activate"
pip install pyosys
