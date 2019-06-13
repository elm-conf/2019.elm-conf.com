#!/usr/bin/env python
from __future__ import print_function, unicode_literals
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('split', default='<!--more-->')

args = parser.parse_args()

for line in sys.stdin.read().split('\n'):
    print(line)

    if args.split in line:
        break
