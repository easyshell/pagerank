#!/usr/bin/env python
import sys
import os

(last_key, pre_rank, get_rank, next_rank_tag, pre_rank_avg) = (None, 0, 0.0, None, 0.0)

def output():
    global pre_rank, get_rank, pre_rank_avg
    print "%s\t%s\t%s" % (last_key, repr(0.15*pre_rank*pre_rank_avg + 0.85*get_rank), next_rank_tag)

def fetch(key, val, cls=False):
    global pre_rank, get_rank, next_rank_tag
    if cls == True:
        get_rank = 0
    if val[-1].startswith("rank"):
        pre_rank = float(val[0])
        next_rank_tag = val[-1]
    else:
        get_rank += float(val[1])

def main():
    global last_key, pre_rank_avg
    pre_rank_avg = float(os.environ.get('pre_rank_avg'))
    for line in sys.stdin:
        tokens = line.replace("\n", "").split("\t")
        key = tokens[0]
        val = tokens[1:]
        if last_key and key != last_key:
            output()
            fetch(key, val, cls=True)
        else:
            fetch(key, val)
        last_key = key
    if last_key:
        output()

if __name__ == '__main__':
    main()
