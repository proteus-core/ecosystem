#!/usr/bin/env python3

import sys

from .signal_extractor import CPUWaveform
from .interface_parser import proteus_o_parser

waveform = CPUWaveform(sys.argv[1], proteus_o_parser)

final_count_signals = proteus_o_parser.get_performance_counters()['final_count']
percentage_high_signals = proteus_o_parser.get_performance_counters()['percentage_high']
final_counts = [waveform.get_last_value(signal) for signal in final_count_signals]
percentage_highs = [waveform.get_high_rate(signal) for signal in percentage_high_signals]

for i, count in enumerate(final_counts):
    print(f"{final_count_signals[i]}: {count}")

for i, rate in enumerate(percentage_highs):
    print(f"{percentage_high_signals[i]}: {rate:.2%}")

# rs_available = []
# i = 0
# while True:
#     try:
#         rs_available.append(waveform.get_high_rate(getattr(waveform.TOP.Core.pipeline, f'Scheduler_RS_EX_ALU{i}_isAvailable')))
#         i += 1
#     except AttributeError:
#         break

# print(f"BTB misprediction rate: {btb_mispredictions / btb_predictions:.2%} ({btb_mispredictions}/{btb_predictions})")
# print(f"SSB misprediction rate: {((ssb_mispredictions / ssb_predictions) if ssb_predictions > 0 else 0):.2%} ({ssb_mispredictions}/{ssb_predictions})")
# print(f"PSF misprediction rate: {((psf_mispredictions / (psf_mispredictions + psf_predictions)) if (psf_mispredictions + psf_predictions) > 0 else 0):.2%} ({psf_mispredictions}/{psf_mispredictions + psf_predictions})")
# print(f"DBUS cache hit rate: {dbus_cache_hits / (dbus_cache_hits + dbus_cache_misses):.2%} ({dbus_cache_hits}/{dbus_cache_hits + dbus_cache_misses})")
# print(f"IBUS cache hit rate: {ibus_cache_hits / (ibus_cache_hits + ibus_cache_misses):.2%} ({ibus_cache_hits}/{ibus_cache_hits + ibus_cache_misses})")
# print(f"IPC: {instructions/waveform.clock_count:.2f} ({instructions}/{waveform.clock_count})")
