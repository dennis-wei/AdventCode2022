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
            with open("9/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/9/input.txt", "r") as f:
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

dirs = {
    "R": (0, 1),
    "L": (0, -1),
    "U": (-1, 0),
    "D": (1, 0)
}

def add(t1, t2):
    return (t1[0] + t2[0], t1[1] + t2[1])

def move_tail(head, tail):
    hx, hy = head
    tx, ty = tail
    new_tail = tail
    if abs(hx - tx) <= 1 and abs(hy - ty) <= 1:
        return new_tail
    elif hx == tx and hy > ty:
        new_tail = (tx, ty + 1)
    elif hx == tx and hy < ty:
        new_tail = (tx, ty - 1)
    elif hy == ty and hx > tx:
        new_tail = (tx + 1, ty)
    elif hy == ty and hx < tx:
        new_tail = (tx - 1, ty)
    elif hx > tx and hy > ty:
        new_tail = (tx + 1, ty + 1)
    elif hx > tx and hy < ty:
        new_tail = (tx + 1, ty - 1)
    elif hx < tx and hy > ty:
        new_tail = (tx - 1, ty + 1)
    elif hx < tx and hy < ty:
        new_tail = (tx - 1, ty - 1)
    
    return new_tail

def solve(input, num_tails):
    grid = Grid(["#..", "...", "..."], static=False)
    head = (0, 0)
    tail =  [(0, 0) for i in range(num_tails)]
    for dir, amount_str in input:
        amount = int(amount_str)
        diff = dirs[dir]
        for i in range(amount):
            head = add(head, diff)
            grid.grid[head]
            for j in range(num_tails):
                if j == 0:
                    prev = head
                else:
                    prev = tail[j - 1]
                tail[j] = move_tail(prev, tail[j])
            
            grid.grid[tail[-1]] = '#'

    answer = len([v for v in grid.grid.values() if v == "#"])

    return answer

start = time.time()
answer1 = solve(input, 1)
answer2 = solve(input, 9)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(9, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(9, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")