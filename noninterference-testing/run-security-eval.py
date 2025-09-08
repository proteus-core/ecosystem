#!/usr/bin/env python3
import sys
import argparse

from waveform_analysis.logger import log
from waveform_analysis.signal_extractor import CPUWaveform
from waveform_analysis.interface_parser import proteus_o_parser

# # Compare two vcd files on a list of signals and print the differences.
# # Useful for debugging with gtkwave.
# #
# # @arg file1, file2: base name of the files to compare (without extension)
# # @arg mintime, maxtime: the time range to compare
# def introspect(self, file1, file2, mintime=0, maxtime=0, maxsignals=0):
#     vcd1 = VCDVCD(f"{file1}.vcd")
#     vcd2 = VCDVCD(f"{file2}.vcd")
#     if maxtime == 0:
#         max1 = get_max_time(vcd1, self._signals)
#         max2 = get_max_time(vcd2, self._signals)
#         maxtime = max(max1, max2)


#     print (f"Comparing {file1} and {file2} from {mintime} to {maxtime}")

#     diffs = []
#     for signal in self.signals:
#         #print (f"Checking {signal}")
#         signal1 = [(time, value) for time, value in vcd1[signal].tv if mintime <= time <= maxtime]
#         signal2 = [(time, value) for time, value in vcd2[signal].tv if mintime <= time <= maxtime]

#         if len(signal1) < len(signal2):
#             padding_time, padding_value = signal1[len(signal1) - 1]
#         else:
#             padding_time, padding_value = signal1[len(signal2) - 1]

#         #print(signal1)
#         #print(signal2)
#         for (time1, value1), (time2, value2) in zip_longest(signal1, signal2, fillvalue=(padding_time, padding_value)):
#             if value1 != value2 or time1 != time2:
#                 #print(f"Diff on signal {signal}")
#                 diffs.append((signal, time1, value1, time2, value2))

#     # Sort diffs by the minimum of both times
#     diffs.sort(key=lambda x: min(x[1], x[3]))

#     print(diffs)

#     # Print the first maxsignals differences
#     if maxsignals > 0 and len(diffs) > maxsignals:
#         print(f"\033[0;31m--- Found {len(diffs)} differences in signals. Printing first {maxsignals} ---\033[0m")
#         diffs = diffs[:maxsignals]

#     for (signal, time1, value1, time2, value2) in diffs:
#         print(f"\033[0;34m====> Signal {signal} differs \033[0m")
#         str1 = f"{file1:<50} @ "
#         str2 = f"{file2:<50} @ "
#         if time1 != time2:
#             str1 += f"\033[0;31m{time1:<10}\033[0m = "
#             str2 += f"\033[0;31m{time2:<10}\033[0m = "
#         else:
#             str1 += f"{time1:<10} = "
#             str2 += f"{time2:<10} = "
#         if value1 != value2:
#             str1 += f"\033[0;31m {hex_or_none_to_str(value1)} \033[0m"
#             str2 += f"\033[0;32m {hex_or_none_to_str(value2)} \033[0m"
#         else:
#             str1 += f" {int(value1, 2):<10X}"
#             str2 += f" {int(value2, 2):<10X}"
#         print(str1)
#         print(str2)

#     if len(diffs) == 0:
#         print(f"\033[0;32m--- Programs {file1} {file2} are equivalent ---\033[0m")


def signals_based_on_policy(waveform: CPUWaveform, policy: str) -> list[str]:
    if policy == "liberal":
        return waveform.liberal_security_filter()
    elif policy == "conservative":
        return waveform.conservative_security_filter()
    else:
        raise NotImplementedError()

def check_all_inputs(policy: str, filename: str, exp_numbers: list[str]) -> int:
    base = exp_numbers[0]
    log.debug(f"+ Check all input for {filename} with base={base}")
    base_waveform = CPUWaveform(f"{filename}_{base}.vcd", proteus_o_parser)
    signals = signals_based_on_policy(base_waveform, policy)
    for input_case in exp_numbers[1:]:
        if not base_waveform.compare_signals(CPUWaveform(f"{filename}_{input_case}.vcd", proteus_o_parser), signals):
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
                    log.warning(f"!--- Programs {file} should be insecure :( ---!")
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

    log.result(f"Secure programs: {secure_programs_found_secure}/{secure_programs_total} Insecure programs: {insecure_programs_found_insecure}/{insecure_programs_total}")

def debug(policy: str, target: str) -> None:
    mintime=0
    maxtime=0
    maxsignals=0
    comparator.introspect(f"{benchmark_path}/vcd/{target}_EXP0", f"{benchmark_path}/vcd/{target}_EXP1", mintime=mintime, maxtime=maxtime, maxsignals=maxsignals)

def parse_arguments() -> argparse.Namespace:
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

def main() -> None:
    args = parse_arguments()

    global benchmark_path
    benchmark_path = args.program_path
    benchmark = args.program_name

    if args.compare_signals not in ["liberal", "conservative"]:
        print(f"Error: Invalid compare-signals option '{args.compare_signals}'. Choose either 'liberal' or 'conservative'.")
        sys.exit(1)  # TODO: there was an argparse error for this


    # # Select comparator based on arguments
    # if args.compare_signals == "liberal":
    #     CPUWaveform()
    #     comparator = Comparator(Signals.get_liberal_security_signals(Signals.get_example_vcd_file(benchmark_path)))
    # elif args.compare_signals == "conservative":
    #     comparator = Comparator(Signals.get_conservative_security_signals(Signals.get_example_vcd_file(benchmark_path)))
    # else:

    if args.debug:
        debug(args.compare_signals, args.debug)
        return

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

    check_all_combinations(args.compare_signals, benchs, secure_defenses, insecure_defenses, leakage_sinks, exp_numbers)

if __name__ == "__main__":
    main()
