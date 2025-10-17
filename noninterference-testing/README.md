# Noninterference testing for Proteus

Noninterference testing verifies that variations in secret data do not cause observable differences in microarchitectural behavior visible to an attacker.

Specifically, it checks that observable microarchitectural components (e.g. execution time, cache state, branch predictor behavior) remain identical across two runs that differ only in secret inputs. Any deviation implies a potential side-channel leak, violating noninterference.

We use noninterference testing to test security defenses implemented in Proteus. Concretely, we (1) generate sets of insecure programs that fail noninterference testing (2) secure these programs with hardware defenses and (3) make sure that secure versions pass noninterference testing.


## Overview
### Program generation
The first step for noninterference testing is to generate a set of insecure and corresponding secure programs.

In the directory [./programs](./programs), we provide sample programs covering multiple Spectre variants (PHT, SSB, PSF) that are vulnerable on Proteus.

We also provide a [Makefile](./programs/Makefile) that compiles these programs under multiple configurations of defense and leakage, as defined in [lib.S](./programs/lib.S).
Concretely, we cover different defenses (`NOFENCE`, `FULLFENCE`) and leak secrets via different unsafe instructions (division, branch, load, and store).

Finally, each program is compiled with two secret values that should trigger distinct microarchitectural leakage on the insecure versions.

### Security evaluation
The security evaluation runs pairs of programs with different secrets and monitors a set of selected signals.
The set of selected signals (conservative or liberal) are defined in [signals.py](./vcd_scripts/signals.py).

Given two sets of signals, the [Comparator](./vcd_scripts/comparator.py) class reports any mismatch between the signal sets.
If the set of selected signals match, then the program is secure; otherwise, there is a side-channel violation.

TODO: the same principle can be applied for correctness evaluation (see [run-correctness-eval.py](./run-correctness-eval.py)) but, for now, this script is buggy.

## Run security evaluation
### Compile programs
The first step is to compile the programs. Make sure the toolchain path is correct; the default is [../llvm-project](../llvm-project).
```
make -C programs all
```
Compiled programs are in [./programs/build/](./programs/build/).

Optionally, you can create objdump files to look at the assembly code:
```
make -C programs objdump
```

### Run simulations
The second step is to run the simulator to get the vcd files of these programs. Make sure the path of Proteus is correct; the default is [../proteus](../proteus). Additionally, make sure Proteus is compiled with the DynamicCore (`make -C sim CORE=riscv.CoreDynamicExtMem32`).
```
make -C programs vcd USECLANG=0 RISCV_PREFIX=riscv64-unknown-elf SIM_EXE=/ecosystem/simulation/build/sim
```
Resulting vcd files are in [./programs/vcd/](./programs/vcd/).

### Run security evaluation
The final step is to run the security evaluation:
```
python ./run-security-evaluation.sh
```

The script can take arguments. For instance to chose the conservative security comparator, use `python ./run-security-evaluation.sh --compare-signals conservative`.
See help with `python ./run-security-evaluation.sh --help`.

If you need to debug a particular program, run `python ./run-security-eval.py --debug <program>` to get a verbose output of the comparator. For instance `python ./run-security-eval.py --debug pht-test1_FULLFENCE_LEAKLOAD`.
