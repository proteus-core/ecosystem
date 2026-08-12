#!/bin/bash

set -ex

cd "$(dirname "$0")/../waveform-analysis"
python3 -m venv .venv
# build module from waveform-analysis
.venv/bin/pip install -e .
