# Noninterference testing for Proteus

Noninterference testing verifies that variations in secret data do not cause observable differences in microarchitectural behavior visible to an attacker.

Specifically, it checks that observable microarchitectural components (e.g. execution time, cache state, branch predictor behavior) remain identical across two runs that differ only in secret inputs. Any deviation implies a potential side-channel leak, violating noninterference.

We use noninterference testing to test security defenses implemented in Proteus. Concretely, we (1) generate sets of insecure programs that fail noninterference testing (2) secure these programs with hardware defenses and (3) make sure that secure versions pass noninterference testing.

For noninterference testing, we use the `waveform-security` binary, while for correctness testing we use `waveform-correctness`:

```shell
$ make -C programs all
$ make -C programs vcd SIM_EXE="$(pwd)/../simulation/build/sim"

$ waveform-correctness --p1 programs/vcd/pht-test1_FULLFENCE_LEAKBR_EXP1.vcd --p2 programs/vcd/pht-test1_NOFENCE_LEAKBR_EXP0.vcd --diff # correctness checking script
----------------------------------------
Mismatch at change #13
Common value: ('TOP.Core.pipeline.retirementStage.arbitration_isDone', 1)
Common value: ('TOP.Core.pipeline.retirementStage.in_PC', 2147483700)
Common value: ('TOP.Core.pipeline.retirementStage.in_RD_DATA', 0)
First value: ('TOP.Core.pipeline.retirementStage.in_RD', 16)
Second value: ('TOP.Core.pipeline.retirementStage.in_RD', 12)
Common value: ('TOP.Core.pipeline.retirementStage.in_RS1_DATA', 0)
Common value: ('TOP.Core.pipeline.retirementStage.in_RS2_DATA', 0)
First value: ('TOP.Core.pipeline.retirementStage.in_LSU_TARGET_ADDRESS', 2147483716)
Second value: ('TOP.Core.pipeline.retirementStage.in_LSU_TARGET_ADDRESS', 2147483712)

$ waveform-security --leakage-sinks LEAKLOAD LEAKBR LEAKJMP  # noninterference security evaluation
DEBUG: + Check all input for ./programs/vcd/ssb-test1_NOFENCE_LEAKBR with base=EXP1
 INFO:  !--- Programs ./programs/vcd/ssb-test1_NOFENCE_LEAKBR is insecure :) ---!
DEBUG: + Check all input for ./programs/vcd/ssb-test1_FULLFENCE_LEAKBR with base=EXP1
 INFO:  !--- Programs ./programs/vcd/ssb-test1_FULLFENCE_LEAKBR is secure :) ---!
DEBUG: + Check all input for ./programs/vcd/ssb-test1_NOFENCE_LEAKJMP with base=EXP1
 INFO:  !--- Programs ./programs/vcd/ssb-test1_NOFENCE_LEAKJMP is insecure :) ---!
DEBUG: + Check all input for ./programs/vcd/ssb-test1_FULLFENCE_LEAKJMP with base=EXP1
 INFO:  !--- Programs ./programs/vcd/ssb-test1_FULLFENCE_LEAKJMP is secure :) ---!

 RESULT:  Secure programs: 12/12 Insecure programs: 6/12
```

## Overview

### Program generation

The first step for noninterference testing is to generate a set of insecure and corresponding secure programs.

In the directory [./programs](./programs), we provide sample programs covering multiple Spectre variants (PHT, SSB, PSF) that are vulnerable on Proteus.

We also provide a [Makefile](./programs/Makefile) that compiles these programs under multiple configurations of defense and leakage, as defined in [lib.S](./programs/lib.S).
Concretely, we cover different defenses (`NOFENCE`, `FULLFENCE`) and leak secrets via different unsafe instructions (division, branch, load, and store).

Finally, each program is compiled with two secret values that should trigger distinct microarchitectural leakage on the insecure versions.

### Security evaluation

Compiled programs are in [./programs/build/](./programs/build/).
The security evaluation runs pairs of programs with different secrets and monitors a set of selected signals.
If the set of selected signals match, then the program is secure; otherwise, there is a side-channel violation.
