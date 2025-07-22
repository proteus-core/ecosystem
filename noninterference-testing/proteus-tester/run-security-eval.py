#!/usr/bin/env python3
import os
import sys
import subprocess
from vcdvcd import VCDVCD
import signals as Signals
from comparator import Comparator
import logger
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
        base_file = f"./build/{bench}"
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


def get_security_comparator():
    return Comparator(Signals.get_std_security_signals("./build/ssb-test1_FULLFENCE_LEAKLOAD_EXP0.vcd"))

def get_hardcore_comparator():
    return Comparator(Signals.get_hardcore_security_signals("./build/ssb-test1_FULLFENCE_LEAKLOAD_EXP0.vcd"))


def main():
    if len(sys.argv) != 3:
        print("Error: Exactly 2 arguments are required.")
        print(f"Usage: {sys.argv[0]} program_path program_name")
        sys.exit(1)

    all_bench = ['pht-test1', 'pht-test2', 'psf-test1', 'ssb-test1']

    benchmark_path, benchmark = sys.argv[1:3]

    if benchmark == "debug":
        debug()
        sys.exit(0)

    os.chdir(benchmark_path)

    if benchmark not in all_bench+["all"]:
        print(f"Error: Benchmark '{benchmark}' is not supported.")
        print(f"Supported benchmarks: {all_bench} or all")
        sys.exit(1)

    # Experiment configuration
    secure_defenses = ["FULLFENCE"]
    insecure_defenses = ["NOFENCE"]
    leakage_sinks = ["LEAKLOAD", "LEAKSTORE", "LEAKBR", "LEAKJMP", "LEAKDIV"]
    exp_numbers = ["EXP1", "EXP0"]

    comparator = get_security_comparator()
    #comparator = get_hardcore_comparator()

    if benchmark == "all":
        benchs = all_bench
    else:
        benchs = [benchmark]
    
    check_all_combinations(comparator, benchs, secure_defenses, insecure_defenses, leakage_sinks, exp_numbers)
    sys.exit(0)


def debug():
    if len(sys.argv) < 2:
        print("Error: At least 1 argument is required.")
        print(f"Usage: {sys.argv[0]} program_path")
        sys.exit(1)

    benchmark_path = sys.argv[1]
    os.chdir(benchmark_path)

    # Chose security comparator
    comparator = get_hardcore_comparator()
    #comparator = get_security_comparator()

    def debug_program(target, mintime=0, maxtime=0, maxsignals=0):
        comparator.introspect(f"./build/{target}_EXP0", f"./build/{target}_EXP1", mintime=mintime, maxtime=maxtime, maxsignals=maxsignals)

    debug_program("pht-test1_FULLFENCE_LEAKLOAD")
    sys.exit(0)



if __name__ == "__main__":
    main()
