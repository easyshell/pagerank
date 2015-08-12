#!/usr/bin/env python

import re
import sys

for line in sys.stdin:
    val = line.strip()
    val = line.replace("\n","")
    val = line.split("\t")
    key = val[0]
    rank_sum = float(val[1])
    rank_cnt = float(val[2])
    print '%s\t%s\t%s' % ("1", repr(rank_sum), repr(rank_cnt))

