import time
import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
import argparse
import clipboard

from itertools import combinations
from collections import defaultdict, Counter, deque
from util.helpers import split_newline, space_split, int_parsed_list, list_of_ints, get_all_nums, submit, Input, Grid
from math import floor, ceil, prod
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
            with open("8/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/8/input.txt", "r") as f:
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

def is_edge(grid, t):
    x, y = t
    if x == 0:
        return True
    elif x == grid.length - 1:
        return True
    elif y == 0:
        return True
    elif y == grid.height - 1:
        return True
    return False

def is_visible(grid, t):
    x, y = t
    tree_height = grid.grid[t]
    if is_edge(grid, t):
        return True
    left_vis = all(grid.grid[(dx, y)] < tree_height for dx in range(0, x))
    right_vis = all(grid.grid[(dx, y)] < tree_height for dx in range(x + 1, grid.length))
    top_vis = all(grid.grid[(x, dy)] < tree_height for dy in range(0, y))
    bottom_vis = all(grid.grid[(x, dy)] < tree_height for dy in range(y + 1, grid.height))

    return left_vis or right_vis or top_vis or bottom_vis

def score_vis(vis):
    vis = vis[::]
    score = 0
    while True:
        if len(vis) == 0:
            break
        next = vis.pop(0)
        if next:
            score += 1
        else:
            score += 1
            break
    return score

def score(grid, t):
    x, y = t
    tree_height = grid.grid[t]
    if is_edge(grid, t):
        return 0
    left_vis = [grid.grid[(dx, y)] < tree_height for dx in range(0, x)][::-1]
    right_vis = [grid.grid[(dx, y)] < tree_height for dx in range(x + 1, grid.length)]
    top_vis = [grid.grid[(x, dy)] < tree_height for dy in range(0, y)][::-1]
    bottom_vis = [grid.grid[(x, dy)] < tree_height for dy in range(y + 1, grid.height)]

    return prod(score_vis(vis) for vis in [left_vis, right_vis, top_vis, bottom_vis])

def solve(input):
    grid = Grid(input)
    n_vis = [t for t in grid.grid.keys() if is_visible(grid, t)]

    scenic_scores = {t: score(grid, t) for t in grid.grid.keys()}
    return len(n_vis), max(scenic_scores.values())

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(8, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(8, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")