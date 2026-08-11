#!/bin/bash

source ../waveform-analysis/.venv/bin/activate
cd ../eval-hd && ./eval-hd.py ../core/Core.v
