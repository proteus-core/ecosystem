#!/usr/bin/env python3

import sys

from signal_extractor import CPUWaveform
from interface_parser import proteus_o_parser

first = CPUWaveform(sys.argv[1], proteus_o_parser)
second = CPUWaveform(sys.argv[2], proteus_o_parser)

zero_s = first.get_signals(proteus_o_parser.get_instruction_stream_list())
good_s = second.get_signals(proteus_o_parser.get_instruction_stream_list())

for (idx, values) in enumerate(zero_s):
    values2 = good_s[idx]
    if values != values2:
        print(f"Mismatch at instruction #{idx}")
        print("First values:", values)
        print("Second values:", values2)
        break
