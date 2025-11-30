#!/usr/bin/env python3

from pyosys import libyosys as ys
import argparse

def run_analysis(report_timing: bool, design_file: str, top_module: str, timing_target: int, cell_library: str) -> None:
    design = ys.Design()

    # read design
    ys.run_pass(f"read_verilog {design_file}", design)

    # elaborate design hierarchy
    ys.run_pass(f"hierarchy -check -top {top_module}", design)

    if report_timing:
        # flatten the design
        ys.run_pass("flatten", design)

    # the high-level stuff
    ys.run_pass("proc; opt; fsm; opt; memory; opt", design)

    # mapping to internal cell library
    ys.run_pass("techmap; opt", design)

    # mapping flip-flops to cell library
    ys.run_pass(f"dfflibmap -liberty {cell_library}", design)

    if report_timing:
        # mapping logic to cell library with timing constraint
        ys.run_pass(f"abc -liberty {cell_library} -fast -D {timing_target}", design)
    else:
        # mapping logic to cell library
        ys.run_pass(f"abc -liberty {cell_library}", design)

    # cleanup
    ys.run_pass("clean", design)

    # write synthesized design
    ys.run_pass("write_verilog result.v", design)

    # get ASIC gate count and area numbers
    ys.run_pass(f"stat -liberty {cell_library}", design)

def main() -> None:
    parser = argparse.ArgumentParser(description="Synthesize a design for ASIC using Yosys.")
    parser.add_argument("design_file", type=str, help="Path to the Verilog design file.")
    parser.add_argument("--top_module", type=str, default="Core", help="Name of the top module (default: Core).")
    parser.add_argument("--cell-library", default="freepdk-45nm/stdcells.lib", help="Path to the cell library (default: FreePDK).")
    parser.add_argument("--report-timing", action="store_true", help="Enable timing analysis during synthesis.")
    parser.add_argument("--timing-target", type=int, default=2500, help="Target timing constraint (in picoseconds, default: 2500).")
    args = parser.parse_args()

    run_analysis(args.report_timing, args.design_file, args.top_module, args.timing_target, args.cell_library)

if __name__ == "__main__":
    main()
