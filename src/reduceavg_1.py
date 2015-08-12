#!/usr/bin/env python
import sys

(last_key, rank_sum, rank_cnt) = (None, 0.0, 0)

def output():
    global last_key, rank_sum, rank_cnt
    print "%s\t%s" % (last_key, repr(rank_sum/rank_cnt))

def fetch(key, val, cls=False):
    global rank_sum, rank_cnt
    if cls == True:
        rank_sum = 0.0
        rank_cnt = 0
    else:
        rank_sum += float(val[0])
        rank_cnt += float(val[1])

def main():
    global last_key
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
