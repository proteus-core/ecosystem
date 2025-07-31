#!/usr/bin/env python3

import json
import os

class InterfaceParser():
    def __init__(self, path):
        dirname = os.path.dirname(__file__)
        with open(os.path.join(dirname, "../cpu-interfaces/" + path), 'r') as f:
            self.description = json.load(f)

    def get_performance_counters(self):
        return self.description['performance_counters']

    def get_clk(self):
        return self.description['clk']

    def get_instruction_stream(self):
        return self.description['instruction_stream']

    def get_instruction_stream_list(self):
        lst = []
        for signal in self.get_instruction_stream().values():
            lst.append(signal)
        return lst

    def get_performance_counters_list(self):
        lst = []
        for counter_lst in self.get_performance_counters().values():
            lst = lst + counter_lst
        return lst

    def get_all_signals_list(self):
        lst = []
        return [self.get_clk()] + self.get_instruction_stream_list() + self.get_performance_counters_list()

proteus_o_parser = InterfaceParser('proteus-o.json')
