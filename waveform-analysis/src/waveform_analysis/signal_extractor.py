#!/usr/bin/env python3

import pywellen
import re
from typing import Self

from .interface_parser import InterfaceParser

class CPUWaveform:
    def __init__(self, vcdname: str, interface: InterfaceParser):
        self.interface = interface
        self.waveform = pywellen.Waveform(vcdname)
        clock_changes = list([t for (t, v) in self.waveform.get_signal_from_path(interface.get_clk()).all_changes() if v == 1])
        self.clock_period = clock_changes[1] - clock_changes[0]
        self.max_clock = clock_changes[-1]
        self.clock_count = self.max_clock // self.clock_period

    def get_signals(self, signals: list[str]) -> list[list[tuple[str, int]]]:
        """
        Get the values of a list of signals at each clock cycle.
        Returns a list of lists of tuples (signal_name, value), where each inner list corresponds to a clock cycle.
        """
        seq: list[list[tuple[str, int]]] = []

        for t in range(0, self.max_clock + self.clock_period, self.clock_period):
            seq.append([(signal, self.as_int(signal, t)) for signal in signals])

        return seq

    def get_last_value(self, signal: str) -> int:
        return self.as_int(signal, self.max_clock)

    def get_high_rate(self, signal: str) -> float:
        count = 0
        previous_t = 0
        for (t, v) in self.waveform.get_signal_from_path(signal).all_changes():
            if v == 0 and previous_t != 0:
                count += (t - previous_t) // self.clock_period
            previous_t = t
        return count / self.clock_count

    def as_int(self, signal: str, time: int) -> int:
        return self.waveform.get_signal_from_path(signal).value_at_time(time)

    def compare_signals(self, other: Self, signals: list[str]) -> bool:
        self_signals = self.get_signals(signals)
        other_signals = other.get_signals(signals)

        if len(self_signals) != len(other_signals):
            pass

        for (idx, values) in enumerate(self_signals):
            values2 = other_signals[idx]
            if values != values2:
                # TODO: compare on individual signals
                print(f"Mismatch at instruction #{idx}")
                print("First values:", values)
                print("Second values:", values2)
                return False

        return True


    def liberal_security_filter(self) -> list[str]:
        all_signals = [var.full_name(self.waveform.hierarchy) for var in self.waveform.hierarchy.all_vars()]

        # Only keep signals related to the pipeline
        all_signals = [s for s in all_signals if "TOP.Core.pipeline" in s]

        signals_patterns: list[str] = [
            # PC and state of the branch predictor
            r'.*BranchTargetPredictor.entries_\d+_pc',
            r'.*BranchTargetPredictor.entries_\d+_target',
            r'.*registerMap_PC',
            r'.*registerMap_PREDICTED_PC',
            # Data bus
            r'.*dbus_cmd_payload_address',
            r'.*dbus_cmd_valid',
            # ICache metadata
            r'.*cache_ibus_cache_\d+_\d+_tag',
            r'.*cache_ibus_cache_\d+_\d+_valid',
            # DCache metadata
            r'.*cache_dbus_cache_\d+_\+d_tag',
            r'.*cache_dbus_cache_\d+_\d+_valid',
            # Control signals
            r'.*ready',
            r'.*arbitration_isDone',
            r'.*isAvailable',
            r'.*[v|V]alid',
            # Pipeline flush
            r'.*JUMP_REQUESTED',
        ]

        return [s for s in all_signals if any(re.match(pattern, s) for pattern in signals_patterns)]

    def conservative_security_filter(self) -> list[str]:
        all_signals = [var.full_name(self.waveform.hierarchy) for var in self.waveform.hierarchy.all_vars()]

        # Only keep signals related to the pipeline
        all_signals = [s for s in all_signals if "TOP.Core.pipeline" in s]

        # Filter out signals related to data
        # #TODO: perhaps too coarse grained (I did not check carefully that all signals are fine to filter out)
        data_patterns = re.compile(r'.*data.*|.*DATA.*|.*Data.*|.*writeValue.*')

        # Filter out cache signals for data
        cache_patterns = [
            r'.*cache_dbus_cache_\d+_\d+_value',
        ]
        combined_cache_pattern = re.compile('|'.join(cache_patterns))

        # Filter out ALU data signals
        alu_patterns = [
            r'.*intAlus_\d+.IntAlu_result',
            r'.*intAlus_\d+.IntAlu_src\d+',
            r'.*intAlus_\d+.out_LSU_TARGET_ADDRESS',
            r'.*intAlus_\d+.BranchUnit_..',
            r'.*intAlus_\d+.value_ALU_RESULT',
            r'.*intAlus_\d+.out_ALU_RESULT',
            r'.*intAlus_\d+.out_IntAlu_src\d+',
            r'.*intAlus_\d+.Shifter_src',
            r'.*intAlus_\d+.BranchUnit_target',
            r'.*intAlus_\d+.BranchUnit_src\d+',
        ]
        combined_alu_pattern = re.compile('|'.join(alu_patterns))

        # Filter out register file signals for data
        regfile_patterns = [
            r'.*RegisterFileAccessor.regs_spinal_port\d+',
            r'.*Core.pipeline.RegisterFileAccessor.regs\(\d+\)',
            r'.*Core.pipeline.RegisterFileAccessor.x\d+_t\d',
            r'.*Core.pipeline.RegisterFileAccessor.x\d+_s\d_fp',
        ]
        combined_regfile_pattern = re.compile('|'.join(regfile_patterns))

        # TODO: Problem with "when" signals
        # When signals usually indicate a change in the pipeline state
        # However, taken in isolation, they are not always meaningful
        #
        # Example:
        # Signal TOP.Core.pipeline.intAlus_1.when_PcManager_l31
        # This signal guards exception handling for misaligned instruction addresses
        # It only makes sense to look at it when the instruction is a branch as the trap handler is also guarded by BU_IsBranch signal
        # However, the signal is also changed when instruction is not a branch
        # This will trigger false positives
        #
        # Perhaps looking at combinations of signals could solve this issue?
        # Or maybe the conclusion is that these when signals are not adapted for security analysis?
        when_patterns = [
            r'.*intAlus_1.when_PcManager_l\d+', # misaligned instruction address
        ]
        combined_when_pattern = re.compile('|'.join(when_patterns))

        # Data forwarding signals
        data_forwarding_patterns = [
            r'.*Scheduler_rob_previousStoreBuffer', # StoreToLoadForwarding, forwards last store to load (can potentially be secret)
        ]
        combined_data_forwarding_patterns = re.compile('|'.join(data_forwarding_patterns))

        all_signals = [s for s in all_signals if not (data_patterns.match(s) or
                                                    combined_alu_pattern.match(s) or
                                                    combined_regfile_pattern.match(s) or
                                                    combined_cache_pattern.match(s) or
                                                    combined_when_pattern.match(s) or
                                                    combined_data_forwarding_patterns.match(s))]

        return all_signals
