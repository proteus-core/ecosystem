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
        self.retirement = attrgetter(self.description['instruction_stream']['path'])(self.namespace)

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

        active = attrgetter(self.description['instruction_stream']['active'])(self.retirement)
        pc = attrgetter(self.description['instruction_stream']['pc'])(self.retirement)

        rd_value = attrgetter(self.description['instruction_stream']['rd_value'])(self.retirement)
        mem_address = attrgetter(self.description['instruction_stream']['mem_address'])(self.retirement)
        rs1_data = attrgetter(self.description['instruction_stream']['rs1_value'])(self.retirement)
        rs2_data = attrgetter(self.description['instruction_stream']['rs2_value'])(self.retirement)

        for t, v in [(t, v) for (t, v) in self.signal(self.clk).all_changes()]:
            if v == 1:
                is_done = self.as_int(active, t) == 1
                if is_done:
                    pc_v = self.as_int(pc, t)
                    value = self.as_int(rd_value, t)
                    addr = self.as_int(mem_address, t)
                    rs2 = self.as_int(rs2_data, t)
                    rs1 = self.as_int(rs1_data, t)
                    seq.append((pc_v, value, addr, rs1, rs2, t))

        return seq

    def signal(self, name):
        return self.waveform.get_signal(name)

    def as_int(self, signal, time):
        return self.signal(signal).value_at_time(time)

dirname = os.path.dirname(__file__)
proteus_description = os.path.join(dirname, "../cpu-interfaces/proteus-o.json")

zero = ProteusWaveform(sys.argv[1], proteus_description)
good = ProteusWaveform(sys.argv[2], proteus_description)

zero_s = zero.get_sequence()
good_s = good.get_sequence()

for (idx, (pc, val, addr, rs1, rs2, t)) in enumerate(zero_s):
    (pc64, val64, addr64, rs164, rs264, t64) = good_s[idx]
    if pc != pc64 or val != val64 or addr != addr64 or rs2 != rs264 or rs1 != rs164:
        print("PC:", pc, pc64)
        print("RD_VALUE:", val, val64)
        print("LSU_ADDR:", addr, addr64)
        print("RS1_DATA:", rs1, rs164)
        print("RS2_DATA:", rs2, rs264)
        print("timestamp:", t, t64)
        print(idx)
        break
