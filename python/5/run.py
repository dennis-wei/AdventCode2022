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
            with open("5/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/5/input.txt", "r") as f:
                raw_input  = f.read()

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

class Stacks:
    def __init__(self, num_stacks, initial):
        self.stacks = [[] for i in range(num_stacks)]
        for row in initial:
            for i in range(0, len(row), 4):
                char = row[i + 1]
                if char != " ":
                    self.stacks[i // 4].append(char)
        self.stacks_pt1 = [s[::-1] for s in self.stacks]
        self.stacks_pt2 = [s[::-1] for s in self.stacks]

    
    def do_op(self, op):
        count, s1, s2 = op
        acc_pt1 = []
        acc_pt2 = []
        for i in range(count):
            popped_1 = self.stacks_pt1[s1 - 1].pop()
            acc_pt1.append(popped_1)

            popped_2 = self.stacks_pt2[s1 - 1].pop()
            acc_pt2.append(popped_2)
        
        self.stacks_pt1[s2 - 1].extend(acc_pt1)
        self.stacks_pt2[s2 - 1].extend(acc_pt2[::-1])
    
def parse_op(row):
    return get_all_nums(row)

def solve(input):
    initial_acc = []
    ops_acc = []
    num_stacks = None
    for row in input:
        if row.startswith(" 1"):
            num_stacks = max(get_all_nums(row))
        elif row.startswith("[") or row.startswith(" "):
            initial_acc.append(row)
        elif row.startswith("m"):
            ops_acc.append(parse_op(row))
    
    stacks = Stacks(num_stacks, initial_acc)
    for op in ops_acc:
        stacks.do_op(op)

    r1 = "".join(s[-1] for s in stacks.stacks_pt1)
    r2 = "".join(s[-1] for s in stacks.stacks_pt2)
    
    return r1, r2

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(5, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(5, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")