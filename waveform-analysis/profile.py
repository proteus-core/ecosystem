#!/usr/bin/env python3

import pywellen
from types import SimpleNamespace
import sys
import json
import os
from operator import attrgetter


class NestedNamespace(SimpleNamespace):
    def __init__(self, dictionary, **kwargs):
        super().__init__(**kwargs)

        for key, value in dictionary.items():
            if isinstance(value, dict):
                self.__setattr__(key, NestedNamespace(value))
            else:
                self.__setattr__(key, value)


class ProteusWaveform:
    def __init__(self, vcdname):
        self.waveform = pywellen.Waveform(vcdname)

        self.TOP = self.build_signal_namespace().TOP
        clock_changes = list([t for (t, v) in self.signal(self.TOP.Core.pipeline.clk).all_changes() if v == 1])
        self.clock_period = clock_changes[1] - clock_changes[0]
        self.max_clock = clock_changes[-1]
        self.clock_count = self.max_clock // self.clock_period

    def build_signal_namespace(self, scope=None):
        hier = self.waveform.hierarchy
        scopes = scope.scopes(hier) if scope is not None else hier.top_scopes()

        d = {}
        if scope:
            vars = scope.vars(hier)

            for var in vars:
                d[var.name(hier)] = var

        for scope in scopes:
            d[scope.name(hier)] = self.build_signal_namespace(scope)

        return NestedNamespace(d)

    def get_signals(self, signals: list[pywellen.Signal]):
        seq = []

        for t in range(0, self.max_clock + self.clock_period, self.clock_period):
            seq.append([self.as_int(signal, t) for signal in signals])

        return seq

    def get_high_rate(self, signal):
        count = 0
        previous_t = 0
        for (t, v) in self.signal(signal).all_changes():
            if v == 0 and previous_t != 0:
                count += (t - previous_t) // self.clock_period
            previous_t = t
        return count / self.clock_count

    def signal(self, name):
        return self.waveform.get_signal(name)

    def as_int(self, signal, time):
        return self.signal(signal).value_at_time(time)


waveform = ProteusWaveform(sys.argv[1])
lst = waveform.max_clock

final_count_signals = []
final_counts = []
percentage_high_signals = []
percentage_highs = []

dirname = os.path.dirname(__file__)
with open(os.path.join(dirname, "../cpu-interfaces/proteus-o.json"), 'r') as f:
    description = json.load(f)
    final_count_signals = description['performance_counters']['final_count']
    percentage_high_signals = description['performance_counters']['percentage_high']

for signal_name in final_count_signals:
    signal = attrgetter(signal_name)(waveform)
    final_counts.append(waveform.as_int(signal, lst))

for signal_name in percentage_high_signals:
    signal = attrgetter(signal_name)(waveform)
    percentage_highs.append(waveform.get_high_rate(signal))

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
