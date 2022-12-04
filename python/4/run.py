import time
import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
import argparse
import clipboard

from itertools import combinations
from collections import defaultdict, Counter, deque
from util.helpers import split_newline, space_split, int_parsed_list, list_of_ints, get_all_nums, submit, Input, Grid
from math import floor, ceil
from functools import reduce
from copy import deepcopy

parser = argparse.ArgumentParser()
parser.add_argument("--from-std-in", action='store_true', default=False)
args = parser.parse_args()
if args.from_std_in:
    raw_input = clipboard.paste()
else:
    try:
        with open("input.txt", "r") as f:
            raw_input = f.read()
    except:
        try:
            with open("4/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/4/input.txt", "r") as f:
                raw_input  = f.read()
raw_input = raw_input.strip()

input = (
    Input(raw_input)
        # .all()
        # .ints()
        # .int_tokens()
        # .tokens()
        .lines()
        # .line_tokens()
        # .line_tokens(sep = "-", line_sep = "\n\n")
)

def contains(t1, t2):
    l1, r1 = t1
    l2, r2 = t2
    return l1 <= l2 and r1 >= r2

def overlaps(t1, t2):
    l1, r1 = t1
    l2, r2 = t2
    return l1 <= l2 and r1 >= l2


def solve(input):
    dupes = 0
    overs = 0
    for line in input:
        left, right = line.split(",")
        left = [int(n) for n in left.split("-")]
        right = [int(n) for n in right.split("-")]
        if contains(left, right) or contains(right, left):
            dupes += 1
        if overlaps(left, right) or overlaps(right, left):
            overs += 1


    return dupes, overs

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(4, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(4, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")