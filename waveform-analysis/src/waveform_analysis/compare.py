#!/usr/bin/env python3

import sys

from .signal_extractor import CPUWaveform
from .interface_parser import proteus_o_parser

first = CPUWaveform(sys.argv[1], proteus_o_parser)
second = CPUWaveform(sys.argv[2], proteus_o_parser)

first.compare_signals(second, proteus_o_parser.get_instruction_stream_list(), display_diff=True)
