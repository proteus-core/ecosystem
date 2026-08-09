#!/usr/bin/env python3

import vcdvcd
import subprocess
import sys


def evaluate():
    subprocess.call(["fst2vcd", "sim.fst", "-o", "sim.vcd"],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    vcd = vcdvcd.VCDVCD("sim.vcd", [])
    addresses = vcd["TOP.Core.pipeline.dbus_cmd_payload_address[31:0]"]

    violation = False

    for (_, val) in addresses.tv:
        addr = int(val, 2)
        if str(hex(addr)) == "0xdead0":
            violation = True

    return violation


base_proteus = sys.argv[1]
secure_proteus = sys.argv[2]

test_cases = [
    "secret-before-branch",
    "secret-after-branch",
    "spill",
]

for case in test_cases:
    print(f"TEST {case}:")
    # run test case with secure variant
    subprocess.call([f"{secure_proteus}", "--dump-fst", "sim.fst", "--tag-file",  f"{case}_tags.bin", f"{case}.bin"])
    print("SECURE VARIANT:  ", end='\t')
    print("🗲 Secret leaked!" if evaluate() else "✔ Secret did not leak!")

    # run test case with insecure variant:
    subprocess.call([f"{base_proteus}", "--dump-fst", "sim.fst", f"{case}.bin"])
    print("INSECURE VARIANT:", end='\t')
    print("🗲 Secret leaked!" if evaluate() else "✔ Secret did not leak!")
    print()

