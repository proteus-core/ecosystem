# The Proteus ecosystem

This repository contains software tools, benchmarks, and other scripts useful for installing, using, extending, and evaluating Proteus.
Starting from Proteus version v25.09, using this repository is strongly recommended for running or extending the core.

For detailed commands that run different evaluations, we recommend checking the [scripts](.github/workflows/ci.yml) that run in GitHub CI.

> [!NOTE]
> The documentation of the ecosystem is still very much incomplete and might be outdated at times.
> We are working on updating and refining it, but contributions for fixes or extensions of the documentation are very much welcome!

## Setup

It is recommended to use the Docker-based setup for working with Proteus.

### Prebuilt image

A prebuilt Docker image can be pulled [from GitHub](https://github.com/proteus-core/ecosystem/pkgs/container/ecosystem) (rebuilt on every update to this repository):

```shell-session
docker pull ghcr.io/proteus-core/ecosystem:latest
```

### Local container setup

Alternatively, you can build this image locally with the included [Dockerfile](./Dockerfile). This installs the bare minimum setup for running simulations, with additional flags for installing other components.
The container can be built with the following command:

```shell-session
$ docker compose up
```

Additional build arguments can be added in `docker-compose.yml`, for example `INSTALL_TOOLCHAIN` to install the RISC-V GNU toolchain, `INSTALL_EVAL_HD` to install the hardware cost evaluation tool and `INSTALL_PROTEUS` to clone and install the Proteus core inside the container (instead of mounting it as a volume).
Note that installing these extra tools will add a substantial amount of time to the build process.

### Working with the container

You can launch a container after building:

```shell-session
$ docker compose run --remove-orphans ecosystem
```

### Non-container setup

If you want to install the components natively without using Docker, you can follow the steps in the [Dockerfile](./Dockerfile) and the [installation scripts](./install-scripts/)

## Developing with Proteus

### Compiler toolchain

For now, we include a [script](./install-scripts/toolchain.sh) to install the GNU toolchain for RISC-V with Newlib support.
Later, we should switch this out for our version of the compiler with support for the existing extensions.

We should probably create/move a top-level Makefile and linker script that can be used by all components to reduce code duplication.

### Newlib board support package

Our [board support package](./newlib-bsp/) with standard library functions and an [example project](./newlib-bsp/main.c).

### Simulation

We use a Verilator-based [simulation flow](./simulation/) that can be build with `make -C simulation` from the root directory of the container.

- `CORE=...`: specify which configuration to build.

Once the simulation binary is built, the options can be consulted by calling `--help` on it.

```
--dump-fst <filename>    Dump trace to <filename>
--dump-mem <filename>    Dump memory to <filename>
--log-stores <filename>  Log stores to <filename>
--help                   Show command line help
```

The last argument passed to the simulator needs to be the binary file.
NOTE: Currently, the `--help` command only works if a binary is provided, and no warning is given if an argument is misspelled.

### Examining simulation output

Running a simulation with trace with the `--dump-fst sim.fst` option creates a trace file called `sim.fst` in the directory the simulation is run from.

We provide bare-bones GTKWave savefiles in `gtkwave` to examine these simulation files depending on the simulated CPU.
Most importantly, these savefiles use the `disas.py` script to decode binary instructions into their textual representation for easier debugging.
This script can also be loaded by right-clicking on an instruction signal (IR registers) and selecting it from `Data Format > Translate Filter Process > Enable and Select`.

## Waveform analysis

Many components of the ecosystem depend on the analysis of waveforms.
To this end, we developed a Python package with related functionalities in `waveform-analysis`.
This package is also used, e.g., by the non-interference testing framework.

### The CPU interface

Some functionality in the waveform analysis depends on being able to identify certain signals in the CPU design.
We created a file format for these descriptions in `cpu-interfaces`.

## Evaluation

### Correctness evaluation

We include `riscv-tests`, extended with a `zicond` test. Run these from `functional-tests`.

#### Formal verification

To run [riscv-formal](https://github.com/SymbioticEDA/riscv-formal), first install its [prerequisites](https://symbiyosys.readthedocs.io/en/latest/quickstart.html#installing) and make sure all the tools are in your `PATH`.
Then, run the following (which will take several hours to complete):

```
make -C formal -j<n>
```

### Performance evaluation

These are primarily used for performance evaluation, but could also be adopted for correctness and security testing.
We currently support the following benchmarks (which still need to be moved):

- SpecBench
- TODO: Winderix suite
- Embench

### Security evaluation

TODO: porting the RISC-V Revizor project.

This is the main security testing that was performed for security extensions, and it relies on the waveform parsing library.
More details are available in its own [README file](./noninterference-testing/README.md)

### Hardware cost evaluation

#### EVAL-HD

We integrated the recently published `EVAL-HD` [workflow](./synthesis/run-yosys.sh) for a Yosys-based synthesis flow targeting ASICs.

#### Xilinx Vivado

To synthesize the design for an FPGA, we use Xilinx Vivado.
The standard edition can be downloaded for free [here](https://www.xilinx.com/products/design-tools/vivado/vivado-ml.html).
These instructions were tested with version 2022.2.

Follow these steps to create a project with Proteus and run the synthesis:

0. Make sure that you have a `Core.v` file in the root directory of this project (this can be generated by running `make sim`, [copied from the Docker container](https://stackoverflow.com/a/22050116) if needed).
1. Launch Vivado, and start the Create Project wizard.
2. Choose the project name and location as desired.
3. Project type: RTL Project.
4. Add sources: select `Core.v` and `synthesis/Top.v`. Do **not** check "Copy sources into project" or "Scan and add RTL include files into project".
5. Add constraints: select `synthesis/Constraints.xdc`.
6. Default part: select your target FPGA, e.g., `xc7a50ticsg324-1L`. Proteus requires at least 186 I/O ports.
7. Finish the wizard.
8. When the project is open, if `Top.v` is not selected as the top module (shown in bold), right-click on it and "Set as Top".
9. If needed, change the timing constraint in Constraints.xdc or regenerate `Core.v` by running `make sim`.
10. Run Implementation

After the first run, the project can be opened from Vivado and the last two steps can be repeated to obtain up-to-date measurements.
