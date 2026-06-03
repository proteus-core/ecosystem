#!/usr/bin/env python3

import csv
import argparse
import mmap
import math
from .signal_extractor import CPUWaveform
from .interface_parser import proteus_o_parser

granularity = 0
offset = 0

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Check tag correctness of store operations.")
    parser.add_argument(
        "--test",
        type=str,
        required=True,
        help="Which tests you are running"
    )
    parser.add_argument(
        "--signals",
        type=str,
        required=True,
        help="Path of the waveform file."
    )
    parser.add_argument(
        "--actStores",
        type=str,
        required=True,
        help="Path of the csv file containing the actual store logs."
    )
    parser.add_argument(
        "--expStores",
        type=str,
        required=True,
        help="Path of the csv file containing the expected store logs."
    )
    parser.add_argument(
        "--sourceTags",
        type=str,
        required=True,
        help="Path of the source tag memory file."
    )
    parser.add_argument(
        "--actTags",
        type=str,
        required=True,
        help="Path of actual the tag memory file."
    )
    parser.add_argument(
        "--output",
        type=str,
        required=False,
        help="Path the output csv file."
    )
    parser.add_argument(
        "--granularity",
        type=int,
        required=True,
        help="Granularity of the memory tagger."
    )
    args = parser.parse_args()
    return args

def getSignalValue(signals, name):
    for signal in signals:
        if (signal[0].__contains__(name)):
            return signal[1]
    raise "Signal not found"

def getTag(tags, address, accessWidth):
    bytes = math.ceil(accessWidth / granularity)
    tagAddress = address >> offset << offset // granularity
    if (tagAddress + bytes > len(tags)): raise "Address out of bounds"
    tag = []
    for i in range(bytes):
        tag.append(tags[tagAddress + i])
    return tag

def readFiles(args):
    fstpath = args.signals
    storeLogsPath = args.actStores
    expectedStoresPath = args.expStores
    sourceTagsPath = args.sourceTags
    actualTagsPath = args.actTags

    waveform = CPUWaveform(fstpath, proteus_o_parser)
    storeSignals = waveform.get_signals_per_clk([
        "TOP.Core.pipeline.retirementStage.arbitration_isReady",
        "TOP.Core.pipeline.retirementStage.arbitration_isValid",
        "TOP.Core.pipeline.retirementStage.in_LSU_OPERATION_TYPE",
        "TOP.Core.pipeline.retirementStage.in_LSU_TARGET_ADDRESS",
        "TOP.Core.pipeline.retirementStage.in_LSU_ACCESS_WIDTH",
        "TOP.Core.pipeline_dbus_cmd_payload_wuser",
        "TOP.Core.pipeline_dbus_cmd_payload_wmask",
        ])
    
    loadSignals = waveform.get_signals_per_clk([
        "TOP.Core.pipeline.RegisterFileAccessor.writeIo_write",
        "TOP.Core.pipeline.retirementStage.out_TAINTED_VALUE",
        "TOP.Core.pipeline.retirementStage.arbitration_isReady",
        "TOP.Core.pipeline.retirementStage.arbitration_isValid",
        "TOP.Core.pipeline.retirementStage.in_LSU_OPERATION_TYPE",
        "TOP.Core.pipeline.retirementStage.in_LSU_TARGET_ADDRESS",
        "TOP.Core.pipeline.retirementStage.in_LSU_ACCESS_WIDTH",
    ])

    logStores = []
    with open(storeLogsPath) as f:
        reader = csv.DictReader(f)
        for row in reader: logStores.append((int(row["address"], 16), int(row["tag"], 2)))
    
    signalStores = []
    for cycle in storeSignals:
        ready = getSignalValue(cycle, "isReady") == 1
        valid = getSignalValue(cycle, "isValid") == 1
        isStore = getSignalValue(cycle, "LSU_OPERATION_TYPE") == 2
        address = getSignalValue(cycle, "ADDRESS") & 0x7FFFFFFF
        accessWidth = 2 ** getSignalValue(cycle, "ACCESS_WIDTH")
        if ready and valid and isStore:
            mask = getSignalValue(cycle, "wmask")
            if mask > 0:
                mask = mask >> (mask & -mask).bit_length() - 1
                tagMask = 0
                for byte in range(0, 4, granularity):
                    curr = 0
                    for i in range(granularity):
                        curr |= (mask >> (byte + i) & 0x1)
                    tagMask |= curr << math.floor(byte / granularity)
                tag = (getSignalValue(cycle, "wuser") & tagMask) >> (tagMask & -tagMask).bit_length() - 1
                signalStores.append([address, tag])
    
    expectedStores = []
    with open(expectedStoresPath) as f:
        reader = csv.DictReader(f)
        for row in reader:
            expectedStores.append((int(row["address"], 16), row["tag"], int(row["granularity"])))
    
    sourceTags = []
    with open(sourceTagsPath, mode='rb') as f:
        mem_file = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        for i in range(0, len(mem_file), granularity):
            sourceTags.append(mem_file[i] == 1)

    actualTags = []
    with open(actualTagsPath, mode='rb') as f:
        mem_file = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        for i in range(0, len(mem_file), granularity):
            actualTags.append(mem_file[i] == 1)

    actualLoads = []
    for cycle in loadSignals:
        ready = getSignalValue(cycle, "isReady") == 1
        valid = getSignalValue(cycle, "isValid") == 1
        isLoad = getSignalValue(cycle, "LSU_OPERATION_TYPE") == 1
        write = getSignalValue(cycle, "write") == 1
        tag = getSignalValue(cycle, "TAINTED") == 1
        address = getSignalValue(cycle, "ADDRESS") & 0x7FFFFFFF
        accessWidth = 2 ** getSignalValue(cycle, "ACCESS_WIDTH")
        if ready and valid and isLoad and write:
            actualLoads.append([address, accessWidth, tag])

    return (actualLoads, signalStores[:-1], logStores, expectedStores, sourceTags, actualTags)

def simulateStores(tags, stores):
    for (address, tag, store_granularity) in stores:
        rev = reversed(tag)
        i = 0
        tagAddress = address >> offset << offset // granularity
        for bit in rev:
            boolTag = True if bit == '1' else False
            while tagAddress + i >= len(tags): tags.append(False)
            if (store_granularity >= granularity or boolTag): tags[tagAddress + i] = boolTag
            i += 1
    return tags

def checkLoads(actual, tags):
    result = True
    for i in range(len(actual)):
        (address, accessWidth, tag) = actual[i]
        expected = any(getTag(tags, address, accessWidth))
        if (expected != tag):
            result = False
            print(f"""
\033[91mIn checkLoads
Mismatch at address 0x{address:X} (accessWidth = {accessWidth}):
    Expected: {expected}
    Actual: {tag}\033[0m""")
    return result

def checkStores(log_stores, expected):
    result = True
    if (len(log_stores) != len(expected)):
        print(f"\033[91mExpected: {len(expected)}, Actual: {len(log_stores)}\033[0m")
        return False
    for i in range(len(log_stores)):
        if (log_stores[i][0] != expected[i][0] & 0xFFFFFFFC):
            result = False
            print(f"""
\033[91mIn checkStores
Mismatch in store to address 0x{log_stores[i][0]:X}:
    Expected: {expected[i][0]:X}
    Actual: {log_stores[i][0]:X}\033[0m""")
        if (log_stores[i][1] != int(expected[i][1], 2)):
            print(f"""
\033[91mIn checkStores
Mismatch in store to address 0x{log_stores[i][0]:X}:
    Expected: {expected[i][1]}
    Actual: {log_stores[i][1]:b}\033[0m""")
            result = False
    return result

def compareStoreTags(cycle_stores, log_stores):
    result = True
    for i in range(len(cycle_stores)):
        cycleTag = cycle_stores[i][1]
        logTag = log_stores[i][1]
        if (cycleTag != logTag):
            print(f"\033[91mIn compareTags\nMismatch at address 0x{cycle_stores[i][0]:X}: {cycleTag:b} != {logTag:b}\n\033[0m")
            result = False
    return result

def checkMemoryResult(tags, expected):
    result = True
    for i in range(len(tags)):
        if (i < len(expected)):
            if (tags[i] != expected[i]):
                result = False
                print(f"""
\033[91mIn checkMemory
Mismatch at address 0x{i*granularity:X}:
    Expected: {expected[i]}
    Actual: {tags[i]}\033[0m""")
        elif (tags[i] != 0):
            result = False
            print(f"""
\033[91mIn checkMemory
Mismatch at address 0x{i:X}:
    Expected: 0
    Actual: {tags[i]}\033[0m""")
    return result

def main():
    args = parse_arguments()
    test = args.test
    writepath = args.output
    global granularity
    global offset
    granularity = args.granularity // 8
    offset = math.ceil(math.log2(granularity))

    (actualLoads, signalStores, logStores, expectedStores, sourceTags, actualTags) = readFiles(args)

    print(f"\033[96m\nRunning {test} tests\033[0m")

    expectedTags = simulateStores(sourceTags.copy(), expectedStores)

    loadsCheckPassed = checkLoads(actualLoads, sourceTags)

    storeCheckPassed = checkStores(logStores, expectedStores)

    comparePassed = compareStoreTags(signalStores, logStores)

    memoryResultPassed = checkMemoryResult(actualTags, expectedTags)

    if (loadsCheckPassed and storeCheckPassed and comparePassed and memoryResultPassed):
        print(f"\033[92mAll {test} tests passed for granularity {granularity * 8}!\033[0m")
    else:
        print(f"\033[91mSome {test} tests failed for granularity {granularity * 8} :(\033[0m")
