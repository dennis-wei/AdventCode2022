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
            with open("2/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/2/input.txt", "r") as f:
                raw_input  = f.read()
raw_input = raw_input.strip()

input = (
    Input(raw_input)
        # .all()
        # .ints()
        # .int_tokens()
        # .tokens()
        # .lines()
        .line_tokens()
        # .line_tokens(sep = "\n", line_sep = "\n\n")
)

def solve(input):
    pts1 = 0
    pts2 = 0
    for p1, p2 in input:
        if p1 == "A":
            if p2 == "X":
                pts1 += 3
                pts2 += 3
            elif p2 == "Y":
                pts1 += 6
                pts2 += 1
            elif p2 == "Z":
                pts1 += 0
                pts2 += 2
        elif p1 == "B":
            if p2 == "X":
                pts1 += 0
                pts2 += 1
            elif p2 == "Y":
                pts1 += 3
                pts2 += 2
            elif p2 == "Z":
                pts1 += 6
                pts2 += 3
        elif p1 == "C":
            if p2 == "X":
                pts1 += 6
                pts2 += 2
            elif p2 == "Y":
                pts1 += 0
                pts2 += 3
            elif p2 == "Z":
                pts1 += 3
                pts2 += 1
        
        if p2 == "X":
            pts1 += 1
            pts2 += 0
        elif p2 == "Y":
            pts1 += 2
            pts2 += 3
        elif p2 == "Z":
            pts1 += 3
            pts2 += 6
    
    return pts1, pts2

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(2, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(2, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")