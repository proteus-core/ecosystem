#!/usr/bin/env python3

import argparse
import json
import sys
from datetime import datetime

import vcd_parser
from vcd_signal import Signal, CompoundSignal, SignalStore


def get_parser():
    parser = argparse.ArgumentParser(
        description='Visualize a VCD waveform as ASCII or convert to a tikz figure.',
    )

    parser.add_argument(
        '-c',
        dest='config',
        default='config.json',
        help='configuration file (default: config.json)',
    )
    parser.add_argument(
        '-f',
        dest='file',
        help='the VCD file to parse (default: taken from the config file)',
    )
    parser.add_argument(
        '-o',
        dest='output',
        help='output compressed VCD file',
    )
    return parser.parse_args()


def gather_signals(config) -> SignalStore:
    clk = Signal(cfg['clk_signal'])
    delimiter = Signal(cfg['delimiter']) if 'delimiter' in cfg else None
    signals = []
    for signal in cfg['signals']:
        if isinstance(signal['name'], str):
            # creating a simple signal
            signals.append(
                Signal(
                    name=signal['name'],
                    type_in=signal.get('type', 'wire'),
                    # todo: make sure that supplied type is in line with actual type
                    label=signal['label'],
                    color=signal['color'],
                )
            )
        else:
            # creating a compound signal
            subsignals = [Signal(name=name, color=signal['color']) for name in signal['name']]
            signals.append(
                CompoundSignal(
                    signals=subsignals,
                    label=signal['label'],
                    color=signal['color'],
                )
            )
    print("Gathered signals...", file=sys.stderr)
    return SignalStore(clk=clk, delimiter=delimiter, signals=signals)


if __name__ == '__main__':
    args = get_parser()
    start = datetime.now()

    with open(args.config) as file:
        cfg = json.load(file)
    if args.file is not None:
        cfg['file_path'] = args.file

    if isinstance(cfg['file_path'], str):
        # one source file
        signals = gather_signals(cfg)
        vcd_parser.parse_vcd(cfg['file_path'], signals, args.output)
    print(f"Parsed VCD file in {datetime.now() - start}")
