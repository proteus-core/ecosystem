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


def secure_for_all_inputs(policy: str, filename: str, exp_postfixes: list[str], display_diff: bool = False) -> bool:
    global policy_signals

    base = exp_postfixes[0]
    log.debug(f"+ Check all input for {filename} with base={base}")
    base_waveform = CPUWaveform(f"{filename}_{base}.vcd", proteus_o_parser)
    if policy_signals is None:
        policy_signals = signals_based_on_policy(base_waveform, policy)
    for input_case in exp_postfixes[1:]:
        if not base_waveform.compare_signals(CPUWaveform(f"{filename}_{input_case}.vcd", proteus_o_parser), policy_signals, display_diff=display_diff):
            return False
    return True


def check_all_combinations(
    path: str,
    policy: str,
    benches: list[str],
    secure_defenses: list[str],
    insecure_defenses: list[str],
    leakage_sinks: list[str],
    exp_postfixes: list[str]
) -> None:
    secure_programs_total = 0
    secure_programs_found_secure = 0
    insecure_programs_total = 0
    insecure_programs_found_insecure = 0

    for bench in benches:
        base_file = f"{path}/vcd/{bench}"
        print(f"====== Running experiment for {base_file}")

        for leak_sink in leakage_sinks:
            for fence in insecure_defenses:
                file = f"{base_file}_{fence}_{leak_sink}"
                insecure_programs_total += 1
                if secure_for_all_inputs(policy, file, exp_postfixes):
                    log.warning(
                        f"!--- Programs {file} should be insecure :( ---!")
                else:
                    log.info(f"!--- Programs {file} is insecure :) ---!")
                    insecure_programs_found_insecure += 1

            for fence in secure_defenses:
                file = f"{base_file}_{fence}_{leak_sink}"
                secure_programs_total += 1
                if not secure_for_all_inputs(policy, file, exp_postfixes):
                    log.error(f"!--- Programs {file} should be secure :( ---!")
                else:
                    log.info(f"!--- Programs {file} is secure :) ---!")
                    secure_programs_found_secure += 1
    print("")

    log.result(
        f"Secure programs: {secure_programs_found_secure}/{secure_programs_total} Insecure programs: {insecure_programs_found_insecure}/{insecure_programs_total}")


def debug(path: str, policy: str, target: str) -> None:
    secure_for_all_inputs(
        policy, f"{path}/vcd/{target}", ["EXP0", "EXP1"], display_diff=True)


def parse_arguments() -> argparse.Namespace:
    benchmarks = ['pht-test1', 'pht-test2', 'psf-test1', 'ssb-test1']
    secure_defenses = ["FULLFENCE", "PROSPECT"]
    insecure_defenses = ["NOFENCE"]
    leakage_sinks = ["LEAKLOAD", "LEAKSTORE", "LEAKBR", "LEAKJMP", "LEAKDIV"]
    exp_postfixes = ["EXP1", "EXP0"]

    parser = argparse.ArgumentParser(
        description="Run security evaluation on benchmarks.")
    parser.add_argument("--program_path", type=str, default="./programs",
                        help="Path to the program directory (default: ./programs)")
    parser.add_argument(
        "--benchmarks",
        type=str,
        nargs='*',
        choices=benchmarks,
        default=benchmarks,
        help="Name of the benchmark to run (leave out to include all)."
    )
    parser.add_argument(
        "--compare-signals",
        choices=["conservative", "liberal"],
        default="liberal",
        help="Choose which signals to compare: conservative (all signals except selected non-observable signals) or liberal (only selected observable signals) (default: liberal)"
    )
    parser.add_argument(
        "--secure-defenses",
        type=str,
        nargs='*',
        choices=secure_defenses,
        default=secure_defenses,
        help="Secure defense configurations (leave out to include all)."
    )
    parser.add_argument(
        "--insecure-defenses",
        type=str,
        nargs='*',
        choices=insecure_defenses,
        default=insecure_defenses,
        help="Insecure defense configurations (leave out to include all)."
    )
    parser.add_argument(
        "--leakage-sinks",
        type=str,
        nargs='*',
        choices=leakage_sinks,
        default=leakage_sinks,
        help="Leakage sink configurations (leave out to include all)."
    )
    parser.add_argument(
        "--experiment-postfixes",
        type=str,
        nargs='*',
        choices=exp_postfixes,
        default=exp_postfixes,
        help="Experiment postfix identifiers (leave out to include all)."
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
    args = parse_arguments()

    if args.debug:
        debug(
            path=args.program_path,
            policy=args.compare_signals,
            target=args.debug)
        return

    check_all_combinations(
        path=args.program_path,
        policy=args.compare_signals,
        benches=args.benchmarks,
        secure_defenses=args.secure_defenses,
        insecure_defenses=args.insecure_defenses,
        leakage_sinks=args.leakage_sinks,
        exp_postfixes=args.experiment_postfixes)
