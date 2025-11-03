#!/usr/bin/env python3

import argparse

from waveform_analysis.logger import log
from waveform_analysis.signal_extractor import CPUWaveform
from waveform_analysis.interface_parser import proteus_o_parser

policy_signals = None


def signals_based_on_policy(waveform: CPUWaveform, policy: str) -> list[str]:
    if policy == "liberal":
        log.debug(f"+ Collect liberal security signals")
        return waveform.liberal_security_filter()
    elif policy == "conservative":
        log.debug(f"+ Collect conservative security signals")
        return waveform.conservative_security_filter()
    else:
        raise NotImplementedError()


def check_all_inputs(policy: str, filename: str, exp_numbers: list[str], display_diff: bool = False) -> int:
    global policy_signals

    base = exp_numbers[0]
    log.debug(f"+ Check all input for {filename} with base={base}")
    base_waveform = CPUWaveform(f"{filename}_{base}.vcd", proteus_o_parser)
    if policy_signals is None:
        policy_signals = signals_based_on_policy(base_waveform, policy)
    for input_case in exp_numbers[1:]:
        if not base_waveform.compare_signals(CPUWaveform(f"{filename}_{input_case}.vcd", proteus_o_parser), policy_signals, display_diff=display_diff):
            log.debug(f"!--- Programs {filename} is insecure ---!")
            return 1
    log.debug(f"!--- Program {filename} is secure ---!")
    return 0


def check_all_combinations(
    # comparator: Comparator,
    policy: str,
    benches: list[str],
    secure_defenses: list[str],
    insecure_defenses: list[str],
    leakage_sinks: list[str],
    exp_numbers: list[str]
) -> None:
    secure_programs_total = 0
    secure_programs_found_secure = 0
    insecure_programs_total = 0
    insecure_programs_found_insecure = 0

    for bench in benches:
        base_file = f"{benchmark_path}/vcd/{bench}"
        print(f"====== Running experiment for {base_file}")

        for leak_sink in leakage_sinks:
            for fence in insecure_defenses:
                file = f"{base_file}_{fence}_{leak_sink}"
                insecure_programs_total += 1
                if check_all_inputs(policy, file, exp_numbers) == 0:
                    log.warning(
                        f"!--- Programs {file} should be insecure :( ---!")
                else:
                    log.info(f"!--- Programs {file} is insecure :) ---!")
                    insecure_programs_found_insecure += 1

            for fence in secure_defenses:
                file = f"{base_file}_{fence}_{leak_sink}"
                secure_programs_total += 1
                if check_all_inputs(policy, file, exp_numbers) == 1:
                    log.error(f"!--- Programs {file} should be secure :( ---!")
                else:
                    log.info(f"!--- Programs {file} is secure :) ---!")
                    secure_programs_found_secure += 1
    print("")

    log.result(
        f"Secure programs: {secure_programs_found_secure}/{secure_programs_total} Insecure programs: {insecure_programs_found_insecure}/{insecure_programs_total}")


def debug(policy: str, target: str) -> None:
    check_all_inputs(
        policy, f"{benchmark_path}/vcd/{target}", ["EXP0", "EXP1"], display_diff=True)


def parse_arguments(benchmarks: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run security evaluation on benchmarks.")
    parser.add_argument("--program_path", type=str, default="./programs",
                        help="Path to the program directory (default: ./programs)")
    parser.add_argument(
        "--program_name",
        type=str,
        choices=benchmarks + ["all"],
        default="all",
        help="Name of the benchmark to run (default: all). Options: " +
        ", ".join(benchmarks + ["all"])
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


def main() -> None:
    all_bench = ['pht-test1', 'pht-test2', 'psf-test1', 'ssb-test1']
    args = parse_arguments(all_bench)

    global benchmark_path
    benchmark_path = args.program_path
    benchmark = args.program_name

    if args.debug:
        debug(args.compare_signals, args.debug)
        return

    # Experiment configuration
    secure_defenses = ["FULLFENCE"]
    insecure_defenses = ["NOFENCE"]
    leakage_sinks = ["LEAKLOAD", "LEAKSTORE", "LEAKBR", "LEAKJMP", "LEAKDIV"]
    exp_numbers = ["EXP1", "EXP0"]

    if benchmark == "all":
        benchs = all_bench
    else:
        benchs = [benchmark]

    check_all_combinations(args.compare_signals, benchs, secure_defenses,
                           insecure_defenses, leakage_sinks, exp_numbers)


if __name__ == "__main__":
    main()
