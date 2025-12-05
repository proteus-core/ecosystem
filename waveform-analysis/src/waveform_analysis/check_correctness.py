#!/usr/bin/env python3

import argparse


from .signal_extractor import CPUWaveform
from .interface_parser import proteus_o_parser


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Run correctness evaluation on two waveforms.")
    parser.add_argument(
        "--p1",
        type=str,
        required=True,
        help="Path of the first waveform file."
    )
    parser.add_argument(
        "--p2",
        type=str,
        required=True,
        help="Path of the second waveform file."
    )
    parser.add_argument(
        "--diff",
        action="store_true",
        help="Display diverging signals (default behavior is to only report True/False)"
    )
    parser.add_argument(
        "--timing",
        action="store_true",
        help="Report differences in timing"
    )
    parser.add_argument(
        "--full_diff",
        action="store_true",
        help="Report all differences, not just the first one"
    )
    args = parser.parse_args()
    return args


def main():
    args = parse_arguments()
    p1 = args.p1
    p2 = args.p2
    diff = args.diff
    timing = args.timing
    full = args.full_diff

    base_waveform = CPUWaveform(p1, proteus_o_parser)
    identical = base_waveform.compare_signals(
        CPUWaveform(p2, proteus_o_parser),
        proteus_o_parser.get_instruction_stream_list(),
        timing_sensitive=timing,
        display_diff=diff,
        early_out=(not full))
    if identical:
        print("Signals match!")
    elif not diff:
        print("Signals do not match!")
