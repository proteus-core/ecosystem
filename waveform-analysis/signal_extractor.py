#!/usr/bin/env python3

import pywellen

class CPUWaveform:
    def __init__(self, vcdname, interface):
        self.interface = interface
        self.waveform = pywellen.Waveform(vcdname)
        clock_changes = list([t for (t, v) in self.waveform.get_signal_from_path(interface.get_clk()).all_changes() if v == 1])
        self.clock_period = clock_changes[1] - clock_changes[0]
        self.max_clock = clock_changes[-1]
        self.clock_count = self.max_clock // self.clock_period

    def get_signals(self, signals: list[str]):
        seq = []

        for t in range(0, self.max_clock + self.clock_period, self.clock_period):
            seq.append([(signal, self.as_int(signal, t)) for signal in signals])

        return seq

    def get_last_value(self, signal: str):
        return self.as_int(signal, self.max_clock)

    def get_high_rate(self, signal):
        count = 0
        previous_t = 0
        for (t, v) in self.waveform.get_signal_from_path(signal).all_changes():
            if v == 0 and previous_t != 0:
                count += (t - previous_t) // self.clock_period
            previous_t = t
        return count / self.clock_count

    def as_int(self, signal, time):
        return self.waveform.get_signal_from_path(signal).value_at_time(time)
