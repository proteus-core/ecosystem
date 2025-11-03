#!/usr/bin/env python3

import argparse
import sys


from waveform_analysis.logger import log
from waveform_analysis.signal_extractor import CPUWaveform
from waveform_analysis.interface_parser import proteus_o_parser


def check_divergences(p1: str, p2: str, timing: bool, diff: bool, full_diff: bool) -> bool:
    base_waveform: CPUWaveform = CPUWaveform(p1, proteus_o_parser)
    return base_waveform.compare_signals(CPUWaveform(p2, proteus_o_parser), proteus_o_parser.get_instruction_stream_list(), timing_sensitive=timing, display_diff=diff, early_out=(not full_diff))


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Run security evaluation on benchmarks.")
    parser.add_argument("--program_path", type=str, default="./programs",
                        help="Path to the program directory (default: ./programs)")
    parser.add_argument(
        "--p1",
        type=str,
        help="Name of the benchmark to run (e.g., pht-test1_FULLFENCE_LEAKLOAD_EXP0)."
    )
    parser.add_argument(
        "--p2",
        type=str,
        help="Name of the benchmark to run (e.g., pht-test1_NOFENCE_LEAKLOAD_EXP0)."
    )
    parser.add_argument(
        "--diff",
        action="store_true",
        help="Display difference in signals"
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

    if not p1 or not p2:
        print("Error: Both --p1 and --p2 arguments are required.")
        sys.exit(1)

    print(f"Running correctness evaluation for {p1} and {p2}")
    print(check_divergences(p1, p2, timing, diff, full))


if __name__ == "__main__":
    main()
