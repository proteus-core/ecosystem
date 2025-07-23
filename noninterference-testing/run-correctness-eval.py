#!/usr/bin/env python3
import argparse
import os
import sys
from vcdvcd import VCDVCD

# Import from vcd_scripts package
from vcd_scripts import signals as Signals
from vcd_scripts.comparator import Comparator
from vcd_scripts import logger
logger = logger.Logger(debug_mode=True) # Change to true for debugging

def check_divergences(comparator, program_path, filenames):
    base = filenames[0]
    logger.debug(f"+ Check all input with base={base}")
    for filename in filenames[1:]:
        if comparator.check_diff(f"{program_path}/vcd/{base}", f"{program_path}/vcd/{filename}") == 1:
            logger.error(f"!--- Programs {filename} diverge ---!")
            return 1
    logger.debug(f"!--- Program {filename} is equivalent to {base} ---!")
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
    comparator = Comparator(Signals.get_retired_signals(Signals.get_example_vcd_file(program_path)))

    if not p1 or not p2:
        print("Error: Both --p1 and --p2 arguments are required.")
        sys.exit(1)

    if args.debug:
        debug(comparator, program_path, p1, p2)
    else:
        print(f"Running correctness evaluation for {p1} and {p2}")
        check_divergences(comparator, program_path, [p1, p2])
    sys.exit(0)

def debug(comparator, program_path, p1, p2):
    comparator.introspect(f"{program_path}/vcd/{p1}", f"{program_path}/vcd/{p2}", mintime=0, maxtime=0)


if __name__ == "__main__":
    main()
