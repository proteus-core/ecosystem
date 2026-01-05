#!/bin/bash

set -ex

cd "$(dirname "$0")/../waveform-analysis"
python3 -m venv .venv
source .venv/bin/activate
# build module from waveform-analysis
pip install -e .
