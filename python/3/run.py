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
            with open("3/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/3/input.txt", "r") as f:
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
        # .line_tokens(sep = "\n", line_sep = "\n\n")
)

def solve(input):
    p1 = 0
    for line in input:
        left, right = (line[:len(line) // 2], line[len(line) // 2:])
        intersection = set(left) & set(right)
        for i in intersection:
            p1 += "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".index(i)
            p1 += 1
    
    p2 = 0
    acc = []
    for line in input:
        acc.append(line)
        if len(acc) == 3:
            a, b, c = acc
            group_intersection = set(a) & set(b) & set(c)
            p2 += "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".index(list(group_intersection)[0])
            p2 += 1
            acc = []

    return p1, p2

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(3, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(3, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")