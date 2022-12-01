import sys
import os

day = sys.argv[1]
python_template = f"""
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
            with open("{day}/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/{day}/input.txt", "r") as f:
                raw_input  = f.read()
raw_input = raw_input.strip()

input = (
    Input(raw_input)
        # .all()
        .ints()
        # .int_tokens()
        # .tokens()
        # .lines()
        # .line_tokens()
        # .line_tokens(sep = "\\n", line_sep = "\\n\\n")
)

def solve(input):
    return None, None

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {{answer1}}")
# print(submit({day}, 1, answer1).text)

print("Part 2")
print(f"Answer: {{answer2}}")
# print(submit({day}, 2, answer1).text)
print(f"Took {{time.time() - start}} seconds for both parts")
""".strip()

if not os.path.exists(f"python/{day}"):
    os.makedirs(f"python/{day}")
with open(f"python/{day}/run.py", 'w') as f:
    f.write(python_template)

elixir_template = f"""
Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/{day}.txt"
# filename = "test_input/{day}.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  # .lines(filename)
  # .line_of_ints(filename)

defmodule Day{day} do
end

part1 = nil

part2 = nil

IO.puts("Part 1: #{{part1}}")
IO.puts("Part 2: #{{part2}}")
""".strip()

with open(f"aoc_elixir/solutions/{day}.exs", 'w') as f:
    f.write(elixir_template)