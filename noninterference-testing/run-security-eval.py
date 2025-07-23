#!/usr/bin/env python3
import sys
from vcdvcd import VCDVCD
import argparse
import glob

# Import from vcd_scripts package
from vcd_scripts import signals as Signals
from vcd_scripts.comparator import Comparator
from vcd_scripts import logger

logger = logger.Logger(debug_mode=False) # Change to true for debugging

def check_all_inputs(comparator, filename, exp_numbers):
    base = exp_numbers[0]
    logger.debug(f"+ Check all input for {filename} with base={base}")
    for input_case in exp_numbers[1:]:
        if comparator.check_diff(f"{filename}_{input_case}", f"{filename}_{base}") == 1:
            logger.debug(f"!--- Programs {filename} is insecure ---!")
            return 1
    logger.debug(f"!--- Program {filename} is secure ---!")
    return 0

def check_all_combinations(comparator, benchs, secure_defenses, insecure_defenses, leakage_sinks, exp_numbers):
    secure_programs_total = 0
    secure_programs_found_secure = 0
    insecure_programs_total = 0
    insecure_programs_found_insecure = 0

    for bench in benchs:
        base_file = f"{benchmark_path}/vcd/{bench}"
        print(f"====== Running experiment for {base_file}")

        for leak_sink in leakage_sinks:
            for fence in insecure_defenses:
                file = f"{base_file}_{fence}_{leak_sink}"
                insecure_programs_total += 1
                if check_all_inputs(comparator, file, exp_numbers) == 0:
                    logger.warning(f"!--- Programs {file} should be insecure :( ---!")
                else:
                    logger.info(f"!--- Programs {file} is insecure :) ---!")
                    insecure_programs_found_insecure += 1

            for fence in secure_defenses:
                file = f"{base_file}_{fence}_{leak_sink}"
                secure_programs_total += 1
                if check_all_inputs(comparator, file, exp_numbers) == 1:
                    logger.error(f"!--- Programs {file} should be secure :( ---!")
                else:
                    logger.info(f"!--- Programs {file} is secure :) ---!")
                    secure_programs_found_secure += 1
    print("")

    logger.result(f"Secure programs: {secure_programs_found_secure}/{secure_programs_total} Insecure programs: {insecure_programs_found_insecure}/{insecure_programs_total}")


def main():
    args = parse_arguments()

    global benchmark_path
    benchmark_path = args.program_path
    benchmark = args.program_name

    # Select comparator based on arguments
    if args.compare_signals == "liberal":
        comparator = Comparator(Signals.get_liberal_security_signals(Signals.get_example_vcd_file(benchmark_path)))
    elif args.compare_signals == "conservative":
        comparator = Comparator(Signals.get_conservative_security_signals(Signals.get_example_vcd_file(benchmark_path)))
    else:
        print(f"Error: Invalid compare-signals option '{args.compare_signals}'. Choose either 'liberal' or 'conservative'.")
        sys.exit(1)

    if args.debug:
        debug(comparator, args.debug)
        sys.exit(0)

    all_bench = ['pht-test1', 'pht-test2', 'psf-test1', 'ssb-test1']
    if benchmark not in all_bench+["all"]:
        print(f"Error: Benchmark '{benchmark}' is not supported.")
        print(f"Supported benchmarks: {all_bench} or all")
        sys.exit(1)

    # Experiment configuration
    secure_defenses = ["FULLFENCE"]
    insecure_defenses = ["NOFENCE"]
    leakage_sinks = ["LEAKLOAD", "LEAKSTORE", "LEAKBR", "LEAKJMP", "LEAKDIV"]
    exp_numbers = ["EXP1", "EXP0"]

    if benchmark == "all":
        benchs = all_bench
    else:
        benchs = [benchmark]
    
    check_all_combinations(comparator, benchs, secure_defenses, insecure_defenses, leakage_sinks, exp_numbers)
    sys.exit(0)

def parse_arguments():
    parser = argparse.ArgumentParser(description="Run security evaluation on benchmarks.")
    parser.add_argument("--program_path", type=str, default="./programs", help="Path to the program directory (default: ./programs)")
    parser.add_argument(
        "--program_name",
        type=str,
        default="all",
        help="Name of the benchmark to run (default: all). Options: all, pht-test1, pht-test2, psf-test1, ssb-test1"
    )
    # Choose security comparator
    parser.add_argument(
        "--compare-signals",
        choices=["conservative", "liberal"],
        default="liberal",
        help="Choose which signals to compare: conservative (all signals except selected non-observable signals) or liberal (only selected observable signals) (default: liberal)"
    )
    parser.add_argument(
        "--debug",
        type=str,
        default=None,
        help="Run in debug mode, specify the target program to debug (e.g., pht-test1_FULLFENCE_LEAKLOAD)"
    )
    args = parser.parse_args()
    return args


def debug(comparator, target):
    mintime=0
    maxtime=0
    maxsignals=0
    comparator.introspect(f"{benchmark_path}/vcd/{target}_EXP0", f"{benchmark_path}/vcd/{target}_EXP1", mintime=mintime, maxtime=maxtime, maxsignals=maxsignals)
    sys.exit(0)



if __name__ == "__main__":
    main()
