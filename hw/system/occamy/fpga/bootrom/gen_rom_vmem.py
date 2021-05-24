#!/usr/bin/env python3
# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
"""Script used to generate additional output files for Meson embedded targets.

This script takes the bootrom input BIN file and generates a VMEM file.
The VMEM file is generated using srec_cat.
"""
import argparse
import os
import subprocess


def run_srec_cat(srec_cat, input, basename, outdir, word_size_bytes):
    # TODO: Replace command for objcopy if endianess issues can be solved
    # https://github.com/lowRISC/opentitan/issues/1107
    filename = basename + '.' + str(word_size_bytes * 8) + '.vmem'
    output = os.path.join(outdir, filename)
    cmd = [
        srec_cat,
        # Input is to be interpreted as a pure binary
        input, '--binary',
        # Reverse the endianness of every word
        '--offset', '0x0', '--byte-swap', str(word_size_bytes),
        # Fill the entire range with garbage, to pad it up to a
        # word alignment
        '--fill', '0xff', '-within', input, '-binary', '-range-pad', str(word_size_bytes),
        # Output as VMem file with specified word size
        '--output', output, '--vmem', str(word_size_bytes * 8),
    ]
    subprocess.run(cmd, check=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--basename',
        '-b',
        required=True,
        help='File basename used as preffix in output filenames.')
    parser.add_argument(
        '--input',
        '-i',
        required=True,
        help="Bootrom input BIN file.")
    parser.add_argument(
        '--outdir',
        '-d',
        required=True,
        help="Output directory.")
    parser.add_argument(
        '--srec_cat',
        '-s',
        required=True,
        help='Absolute path to srec_cat tool.')
    args = parser.parse_args()

    if not os.path.exists(args.outdir):
        os.makedirs(args.outdir)

    run_srec_cat(args.srec_cat, args.input, args.basename, args.outdir,
                 word_size_bytes=4)

    run_srec_cat(args.srec_cat, args.input, args.basename, args.outdir,
                 word_size_bytes=8)


if __name__ == "__main__":
    main()
