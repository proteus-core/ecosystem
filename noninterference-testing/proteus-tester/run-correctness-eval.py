#!/usr/bin/env python3
import os
import sys
import subprocess
from vcdvcd import VCDVCD
import signals as Signals
from comparator import Comparator
import logger
logger = logger.Logger(debug_mode=True) # Change to true for debugging

def check_all_inputs(comparator, filenames):
    base = filenames[0]
    logger.debug(f"+ Check all input with base={base}")
    for filename in filenames[1:]:
        if comparator.check_diff(f"{base}", f"{filename}") == 1:
            logger.error(f"!--- Programs {filename} diverge ---!")
            return 1
    logger.debug(f"!--- Program {filename} is equivalent to {base} ---!")
    return 0

def check_all_combinations(comparator, base_file, defenses, leakage_sinks, exp_numbers):
    filenames = []
    for leak_sink in leakage_sinks:
        for fence in defenses:
            filenames.append(f"{base_file}_{fence}_{leak_sink}_{exp_numbers[0]}")
    check_all_inputs(comparator, filenames)

    filenames = []
    for leak_sink in leakage_sinks:
        for fence in defenses:
            filenames.append(f"{base_file}_{fence}_{leak_sink}_{exp_numbers[1]}")
    check_all_inputs(comparator, filenames)


def get_correctness_comparator():
    return Comparator(Signals.get_retired_signals("./build/ssb-test1_FULLFENCE_LEAKLOAD_EXP0.vcd"))


def main():
    if len(sys.argv) != 3:
        print("Error: Exactly 2 arguments are required.")
        print(f"Usage: {sys.argv[0]} program_path program_name")
        sys.exit(1)

    all_bench = ['pht-test1', 'pht-test2', 'psf-test1', 'ssb-test1']

    benchmark_path, benchmark = sys.argv[1:3]
    os.chdir(benchmark_path)

    if benchmark not in all_bench+["all"]:
        print(f"Error: Benchmark '{benchmark}' is not supported.")
        print(f"Supported benchmarks: {all_bench} or all")
        sys.exit(1)

    # Experiment configuration
    defenses = ["FULLFENCE", "NOFENCE"]
    # leakage_sinks = ["LEAKLOAD", "LEAKSTORE", "LEAKBR", "LEAKDIV"]
    leakage_sinks = ["LEAKLOAD"]
    exp_numbers = ["EXP1", "EXP0"]

    comparator = get_correctness_comparator()

    if benchmark == "all":
        benchs = all_bench
    else:
        benchs = [benchmark]
    
    for bench in benchs:
        base_file = f"./build/{bench}"
        print(f"====== Running experiment for {base_file}")
        check_all_combinations(comparator, base_file, defenses, leakage_sinks, exp_numbers)
        print("")
    sys.exit(0)

def debug():
    if len(sys.argv) < 2:
        print("Error: At least 1 argument is required.")
        print(f"Usage: {sys.argv[0]} program_path")
        sys.exit(1)

    benchmark_path = sys.argv[1]
    os.chdir(benchmark_path)
    comparator = get_correctness_comparator()

    # TODO: We need a way to filter out the fence
    comparator.introspect("./build/pht-test1_FULLFENCE_LEAKLOAD_EXP0", "./build/pht-test1_NOFENCE_LEAKLOAD_EXP0", mintime=0, maxtime=0)

    sys.exit(0)


if __name__ == "__main__":
    #main()
    debug()
