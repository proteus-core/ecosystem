#!/bin/bash

source ../waveform-analysis/.venv/bin/activate
../eval-hd/eval-hd.py ../core/Core.v --cell-library ../eval-hd/freepdk-45nm/stdcells.lib
