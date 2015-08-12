#!/usr/bin/env python
import sys

(last_key, rank, val_list, next_rank_tag) = (None, 0, [], None)

def output():
    print "%s\t%s\t%s" % (last_key, repr(rank), next_rank_tag)
    for v in val_list:
        print "%s\t%s\t%s" % (v, last_key, repr((0.0+rank)/len(val_list)))

def get_next_rank_tag(rank_tag):
    rank_tag = rank_tag.split("-")
    #print(rank_tag)
    next_round = int(rank_tag[1]) + 1
    ret = str(rank_tag[0]) + "-" + str(next_round)
    return ret

def fill(key, val, cls=False):
    global rank, val_list, next_rank_tag
    if cls:
        val_list = []
    elif val[-1].startswith("rank"):
        next_rank_tag = get_next_rank_tag(val[-1])
        rank = float(val[0])
    else:
        val_list.append(val[0])

def main():
    global last_key, val_list
    for line in sys.stdin:
        tokens = line.replace("\n", "").split("\t")
        key = tokens[0]
        val = tokens[1:]
        if last_key and key != last_key:
            output()
            fill(key, val, cls=True)
        else:
            fill(key, val)
        last_key = key
    if last_key:
        output()

if __name__ == '__main__':
    main()
