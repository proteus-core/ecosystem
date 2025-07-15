#!/usr/bin/env python3

import pywellen
from types import SimpleNamespace
import sys
import datetime


class NestedNamespace(SimpleNamespace):
    def __init__(self, dictionary, **kwargs):
        super().__init__(**kwargs)

        for key, value in dictionary.items():
            if isinstance(value, dict):
                self.__setattr__(key, NestedNamespace(value))
            else:
                self.__setattr__(key, value)


class ProteusWaveform:
    def __init__(self, vcdname, signals=[]):
        self.waveform = pywellen.Waveform(vcdname)

        self.TOP = self.build_signal_namespace().TOP
        self.PL = self.TOP.Core.pipeline
        self.ID = self.TOP.Core.pipeline.decode
        try:
            self.WB = self.TOP.Core.pipeline.writeback
            self.is_static = True
        except:
            self.WB = self.TOP.Core.pipeline.retirementStage
            self.is_static = False
        self.RF = self.TOP.Core.pipeline.RegisterFileAccessor
        self.CSR = self.TOP.Core.pipeline.CsrFile
        clock_changes = list([t for (t, v) in self.signal(self.PL.clk).all_changes() if v == 1])
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

    def get_sequence(self):
        seq = []

        for t in range(0, self.max_clock + self.clock_period, self.clock_period):
            is_done = self.as_int(self.WB.arbitration_isDone, t) == 1
            if is_done:
                pc = self.as_int(self.WB.in_PC, t)
                value = self.as_int(self.WB.in_RD_DATA, t)
                reg = self.as_int(self.WB.in_RD_TYPE, t)
                if not self.is_static:
                    addr = self.as_int(self.WB.in_LSU_TARGET_ADDRESS, t)
                    rs2 = self.as_int(self.WB.in_RS2_DATA, t)
                else:
                    addr = 0
                    rs2 = 0
                rs1 = self.as_int(self.WB.in_RS1_DATA, t)
                seq.append((pc, value, reg, addr, rs1, rs2, t))

        return seq

    def get_high_rate(self, signal):
        print(f"Parsing {str(signal)}...")
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

is_full = waveform.get_high_rate(waveform.TOP.Core.pipeline.Scheduler_rob_isFull)
decode_stall = waveform.get_high_rate(waveform.TOP.Core.pipeline.decode.arbitration_isStalled)
active_flush = waveform.get_high_rate(waveform.TOP.Core.pipeline.Scheduler_dispatcher_activeFlush)

rs_available = []
i = 0
while True:
    try:
        rs_available.append(waveform.get_high_rate(getattr(waveform.TOP.Core.pipeline, f'Scheduler_RS_EX_ALU{i}_isAvailable')))
        i += 1
    except AttributeError:
        break

mul_available = []
i = 0
while True:
    try:
        mul_available.append(waveform.get_high_rate(getattr(waveform.TOP.Core.pipeline, f'Scheduler_RS_EX_MUL{i}_isAvailable')))
        i += 1
    except AttributeError:
        break

load_available = []
i = 0
while True:
    try:
        load_available.append(waveform.get_high_rate(getattr(waveform.TOP.Core.pipeline, f'Scheduler_LM_LOAD{i}_isAvailable')))
        i += 1
    except AttributeError:
        break

btb_mispredictions = waveform.as_int(waveform.TOP.Core.pipeline.BranchTargetPredictor_mispredictionCount, lst)
btb_predictions = waveform.as_int(waveform.TOP.Core.pipeline.BranchTargetPredictor_predictionCount, lst)

ssb_mispredictions = waveform.as_int(waveform.TOP.Core.pipeline.Scheduler_rob_ssbMispredictions, lst)
ssb_predictions = waveform.as_int(waveform.TOP.Core.pipeline.Scheduler_rob_ssbPredictions, lst)

psf_mispredictions = waveform.as_int(waveform.TOP.Core.pipeline.Scheduler_rob_psfMispredictions, lst)
psf_predictions = waveform.as_int(waveform.TOP.Core.pipeline.Scheduler_rob_psfPredictions, lst)

dbus_cache_hits = waveform.as_int(waveform.TOP.Core.pipeline.cache_dbus_cacheHits, lst)
dbus_cache_misses = waveform.as_int(waveform.TOP.Core.pipeline.cache_dbus_cacheMisses, lst)

ibus_cache_hits = waveform.as_int(waveform.TOP.Core.pipeline.cache_ibus_cacheHits, lst)
ibus_cache_misses = waveform.as_int(waveform.TOP.Core.pipeline.cache_ibus_cacheMisses, lst)

instructions = waveform.as_int(waveform.TOP.Core.pipeline.CsrFile.CsrFile_instret, lst)

print(f"ROB full rate: {is_full:.2%}")
print(f"Decode stall rate: {decode_stall:.2%}")
print(f"Active flush rate: {active_flush:.2%}")

for i, rate in enumerate(rs_available):
    print(f"RS{i} available rate: {rate:.2%}")

for i, rate in enumerate(mul_available):
    print(f"MUL{i} available rate: {rate:.2%}")

for i, rate in enumerate(load_available):
    print(f"LM{i} available rate: {rate:.2%}")

print(f"BTB misprediction rate: {btb_mispredictions / btb_predictions:.2%} ({btb_mispredictions}/{btb_predictions})")
print(f"SSB misprediction rate: {((ssb_mispredictions / ssb_predictions) if ssb_predictions > 0 else 0):.2%} ({ssb_mispredictions}/{ssb_predictions})")
print(f"PSF misprediction rate: {((psf_mispredictions / (psf_mispredictions + psf_predictions)) if (psf_mispredictions + psf_predictions) > 0 else 0):.2%} ({psf_mispredictions}/{psf_mispredictions + psf_predictions})")
print(f"DBUS cache hit rate: {dbus_cache_hits / (dbus_cache_hits + dbus_cache_misses):.2%} ({dbus_cache_hits}/{dbus_cache_hits + dbus_cache_misses})")
print(f"IBUS cache hit rate: {ibus_cache_hits / (ibus_cache_hits + ibus_cache_misses):.2%} ({ibus_cache_hits}/{ibus_cache_hits + ibus_cache_misses})")
print(f"IPC: {instructions/waveform.clock_count:.2f} ({instructions}/{waveform.clock_count})")
