#!/usr/bin/env python3

import argparse
import json
import sys
import re
from datetime import datetime
from typing import TextIO

import interface_parser

def set_ids(file: TextIO, signals: list[str], of: TextIO) -> dict:
    upscope_str = r'\$scope\s+(?P<type>\S+)\s+(?P<name>\S+)\s+\$end'
    downscope_str = r'\$upscope\s+\$end'
    var_str = r'\$var\s*(?P<type>\w+)\s*\d+\s*(?P<id>\S+)\s*(?P<name>\w+)(\s*\[\d+:\d+\])?\s*\$end'
    timescale_inline_str = r'\$timescale\s+(?P<value>\d+)(?P<unit>\w+)'

    timescale_on_next = False

    ids = {}

    scopes = []
    for line in file:
        line = line.strip()
        # can keep all these lines for simplicity
        var_match = re.match(var_str, line)
        if var_match:
            name = ".".join(scopes + [var_match.group('name')])
            if name in signals:
                of.write(line + "\n")
                ids[var_match.group('id')] = name
        else:
            upscope_match = re.match(upscope_str, line)
            if upscope_match:
                scopes.append(upscope_match.group('name'))
                of.write(line + "\n")
            else:
                downscope_match = re.match(downscope_str, line)
                if downscope_match:
                    scopes = scopes[:-1]
                    of.write(line + "\n")
                else:
                    timescale_inline_match = re.match(timescale_inline_str, line)
                    if timescale_inline_match or timescale_on_next:
                        of.write(line + "\n")
                        # update timescale
                        if timescale_on_next:
                            timescale_on_next = False
                            timescale_inline_match = re.match(r'\s*(?P<value>\d+)(?P<unit>\w+)', line)
                    else:
                        if line.startswith("$timescale"):
                            timescale_on_next = True
                            of.write(line + "\n")
                        else:
                            if line.startswith("$dumpvars") or line.startswith("$enddefinitions"):
                                of.write(line + "\n")
                                break

    # TODO: check for signals that were not found (e.g., remove them from the list as we find them, check if empty)
    for signal in signals:
        if signal not in ids.values():
            print("Warning: signal {} not found in VCD!".format(signal))
    print("IDs collected for {}...".format(file.name))
    return ids


def load_values(file: TextIO, ids: dict, of: TextIO):
    for line in file:
        line = line.strip()
        if line.startswith('#'):
            # keep timestamp line
            of.write(line + '\n')
        else:
            match = re.match(r'(?P<value>(b[x01]+\s+|[x01]))?(?P<id>\S+)$', line)
            if match:
                iden = match.group('id')
                if iden in ids:
                    # keep line
                    of.write(line + '\n')


def strip_vcd(vcd_file: str, signals: list[str], output: str):
    with open(vcd_file) as file:
        with open(output, 'w') as of:
            ids = set_ids(file, signals, of)
            load_values(file, ids, of)


def get_parser():
    parser = argparse.ArgumentParser(
        description='Create a new VCD file that only contains the signals of interest.',
    )

    parser.add_argument(
        '-i',
        dest='interface',
        help='interface file',
        required=True,
    )
    parser.add_argument(
        '-f',
        dest='file',
        help='the VCD file to parse',
        required=True,
    )
    parser.add_argument(
        '-o',
        dest='output',
        help='output compressed VCD file',
        required=True,
    )
    return parser.parse_args()


if __name__ == '__main__':
    args = get_parser()
    start = datetime.now()
    interface = interface_parser.InterfaceParser(args.interface)
    signals = interface.get_all_signals_list()
    strip_vcd(args.file, signals, args.output)
    print(f"Stripped VCD file in {datetime.now() - start}")
