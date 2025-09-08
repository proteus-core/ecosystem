#!/usr/bin/env python3
import argparse
import sys


from waveform-analysis.logger import log
from waveform-analysis.signal_extractor import CPUWaveform
from waveform-analysis.interface_parser import proteus_o_parser


def check_divergences(program_path, filenames):
    base = filenames[0]
    log.debug(f"+ Check all input with base={base}")
    base_waveform = CPUWaveform(f"{program_path}/vcd/{base}", proteus_o_parser)
    for filename in filenames[1:]:
        if not base_waveform.compare_signals(CPUWaveform(f"{program_path}/vcd/{filename}"), proteus_o_parser), proteus_o_parser.get_instruction_stream_list()):
            log.error(f"!--- Programs {filename} diverge ---!")
            return 1
    log.debug(f"!--- Program {filename} is equivalent to {base} ---!")
    return 0


def parse_arguments():
    parser = argparse.ArgumentParser(description="Run security evaluation on benchmarks.")
    parser.add_argument("--program_path", type=str, default="./programs", help="Path to the program directory (default: ./programs)")
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
        "--debug",
        action="store_true",
        help="Run in debug mode"
    )
    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    program_path = args.program_path
    p1 = args.p1
    p2 = args.p2

    if not p1 or not p2:
        print("Error: Both --p1 and --p2 arguments are required.")
        sys.exit(1)

    if args.debug:
        debug(comparator, program_path, p1, p2)
    else:
        print(f"Running correctness evaluation for {p1} and {p2}")
        check_divergences(program_path, [p1, p2])
    sys.exit(0)

def debug(comparator, program_path, p1, p2):
    # comparator.introspect(f"{program_path}/vcd/{p1}", f"{program_path}/vcd/{p2}", mintime=0, maxtime=0)
    pass


if __name__ == "__main__":
    main()
