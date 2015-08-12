#!/usr/bin/env python

import re
import sys

for line in sys.stdin:
    val = line.strip()
    val = line.replace("\n","")
    print val
