#!/usr/bin/env python
import re
import sys
import os

key_num = int(os.environ.get('key_num'))

for line in sys.stdin:
    val = line.strip()
    val = line.replace("\n","")
    val = line.split("\t")
    key = val[0]
    rank = float(val[1])
    print '%s\t%s' % (str(int(key)%key_num), repr(rank))
