#!/usr/bin/env python3

import vcdvcd
import subprocess
import os


def evaluate(path: str):
    vcd = vcdvcd.VCDVCD(path, [])
    addresses = vcd["TOP.Core.pipeline.DynamicMemoryBackbone_unifiedInternalDBus_payload_cmd_payload_address"]
    violation = False
    for (_, val) in addresses.tv:
        try:
            addr = int(val, 2)
            if str(hex(addr)) == "0xdead0":
                violation = True
        except ValueError:
            print("Ignoring invalid address")

    return violation

proteus_bin = os.path.join(os.path.abspath(os.path.dirname(__file__)), '../../sim/build/sim')

test_cases = [
    #"secret-before-branch",
    #"secret-after-branch",
    "ssb-test",
    #"psf-test",
]

for case in test_cases:
    print(f"TEST {case}:")
    # run test case with secure variant
    subprocess.call(["make", f"{case}.bin"])
    subprocess.call(["make", f"{case}.objdump"])
    subprocess.call([f"{proteus_bin}", f"{case}.bin"])
    subprocess.call(["fst2vcd", "-f", "sim.fst", "-o", f"{case}.vcd"])
    print("SECURE VARIANT:  ", end='\t')
    print("🗲 Secret leaked!" if evaluate(f"{case}.vcd") else "✔ Secret did not leak!")

    # run test case with insecure variant:
    # 1. remove fence instructions from code
    with open(f"{case}.s") as source:
        lines = source.readlines()
        stripped = [
            line for line in lines if not line.strip().startswith("fence") and not line.strip().startswith("sfence")]
        with open(f"{case}_stripped.s", 'w') as stripped_file:
            stripped_file.writelines(stripped)

    subprocess.call(["make", f"{case}_stripped.bin"])
    subprocess.call(["make", f"{case}_stripped.objdump"])
    subprocess.call([f"{proteus_bin}", f"{case}_stripped.bin"])
    subprocess.call(["fst2vcd", "-f", "sim.fst", "-o", f"{case}_stripped.vcd"])
    print("INSECURE VARIANT:", end='\t')
    print("🗲 Secret leaked!" if evaluate(f"{case}_stripped.vcd") else "✔ Secret did not leak!")
    print()
