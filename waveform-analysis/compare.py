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
    def __init__(self, vcdname, description):
        self.waveform = pywellen.Waveform(vcdname)

        with open(description, 'r') as f:
            self.description = json.load(f)

        #  get_signal_from_path instead of the hierarchy?

        self.namespace = self.build_signal_namespace()
        self.clk = attrgetter(self.description['clk'])(self.namespace)

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

    def get_sequence(self):
        seq = []

        active = attrgetter(
            self.description['instruction_stream']['active'])(self.namespace)

        signals = {}

        for signal in self.description['instruction_stream']:
            signals[signal] = attrgetter(
                self.description['instruction_stream'][signal])(self.namespace)

        for t, v in [(t, v) for (t, v) in self.signal(self.clk).all_changes()]:
            if v == 1:
                is_done = self.as_int(active, t) == 1
                if is_done:
                    seq.append(
                        [(name, self.as_int(signal, t)) for name, signal in signals.items()]
                    )

        return seq

    def signal(self, name):
        return self.waveform.get_signal(name)

    def as_int(self, signal, time):
        return self.signal(signal).value_at_time(time)


dirname = os.path.dirname(__file__)
proteus_description = os.path.join(dirname, "../cpu-interfaces/proteus-o.json")

first = ProteusWaveform(sys.argv[1], proteus_description)
second = ProteusWaveform(sys.argv[2], proteus_description)

zero_s = first.get_sequence()
good_s = second.get_sequence()

for (idx, values) in enumerate(zero_s):
    values2 = good_s[idx]
    if values != values2:
        print(f"Mismatch at instruction #{idx}")
        print("First values:", values)
        print("Second values:", values2)
        break
