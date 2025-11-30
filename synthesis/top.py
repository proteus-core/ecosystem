#!/usr/bin/env python3

import subprocess
import re

def run_with_timing(target: int) -> bool:
    timing_failed = False

    result = subprocess.run(["./eval-hd.py", "../core/Core.v", "--report-timing", "--timing-target", str(target), "--cell-library", "../eval-hd/freepdk-45nm/stdcells.lib"], capture_output=True, text=True)
    rs = re.search(r"Chip area for module \'\\Core\': (\d+.\d+)", result.stdout)
    if rs:
        area = float(rs.group(1))
        print(f"Area = {area:.2f} µm² = {(area / 1000000):.4f} mm²")

    trs = re.search(r"Cannot meet the target required times \((\d+.\d+)\). Continue anyway.", result.stdout)
    if trs:
        timing = float(trs.group(1))
        print("Timing failed")
        timing_failed = True
    else:
        print(f"Timing met: {target} ps = {target / 1000} ns = {1 / (target / 1000000):.2f} MHz")

    return timing_failed

successful_target = 10000

for step in [1000, 100, 10, 1]:
    for target in range(successful_target - 9 * step, successful_target, step):
        failed = run_with_timing(target)
        if not failed:
            successful_target = target
            break
