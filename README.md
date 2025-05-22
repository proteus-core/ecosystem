# The Proteus ecosystem

This repository aims to contain software tools, benchmarks, and other scripts useful for installing, using, extending, and evaluating Proteus.

## Docker setup

There should be a central Dockerfile that installs the bare minimum setup for running simulations.
It should also include (optional) scripts that install the additional components used for evaluating designs.
We could even include a Visual Studio Code setup for an out-of-the-box development environment with the necessary tools (Scala support, waveform viewer).

You can build the image with the following command:

```shell
$ docker build -t ecosystem .
```

## Simulation

We use a Verilator-based simulation flow.
The possible options for this simulation should be extended and documented better.
It currently supports the following options:
- `CORE=...`: specify which configuration to build.
- `EXTRA_CFLAGS="-DLOG_STORES_ENABLED"`: enable logging stores on stderr.
- `EXTRA_CFLAGS="-DTRACE_DUMP_ENABLED"`: enable waveform dumping in FST format.

## Newlib

Our board support package with standard library functions.

## Toolchain

For now, we include a script to install the GNU toolchain for RISC-V with Newlib support.
Later, we should switch this out for our version of the compiler with support for the existing extensions.

We should probably create/move a top-level Makefile and linker script that can be used by all components to reduce code duplication.

## Benchmarks

These are primarily used for performance evaluation, but could also be adopted for correctness and security testing.
We currently support the following benchmarks (which still need to be moved):

- SpecBench
- Winderix suite
- RISC-V unit tests

We also have in-house benchmarks to test basic Spectre leakage examples.

In the future, I would like to add support for the following benchmarks:

- Embench

## Formal verification

In the past, we had riscv-formal running on the in-order pipeline, this should be updated to work again.

## Fuzzing

In a master's thesis project, Revizor's RISC-V port was ported to Proteus.
We should integrate this into the repository.

## Waveform analysis

Analyzing waveforms output from simulations is useful for security and correctness testing and other purposes, such as profiling.
We have a collection of scripts that make it easier to work with and parse these files.

## Noninterference-based testing

This is the main security testing that was performed for security extensions, and it relies on the waveform parsing library.
