#!/bin/bash

set -ex

cd "$(dirname "$0")/.."
python3 -m venv .python-venv
cd waveform-analysis
# build module from waveform-analysis
../.python-venv/bin/pip install -e .
