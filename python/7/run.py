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
            with open("7/input.txt", "r") as f:
                raw_input = f.read()
        except:
            with open("python/7/input.txt", "r") as f:
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

class Node:
    def __init__(self, prefix, ls_str):
        self.prefix = prefix
        self.dirs = [l.replace("dir ", "") for l in ls_str if l.startswith("dir")]
        self.dirs_filled = {}
        self.leafs = {l.split(" ")[1]: int(l.split(" ")[0]) for l in ls_str if not l.startswith("dir")}
        self.size_cached = None
    
    def fill(self, nodes):
        self.dirs_filled = {d: nodes[self.prefix + d] for d in self.dirs}

    def get_size(self):
        if self.size_cached == None:
            self.size_cached = sum(d.get_size() for d in self.dirs_filled.values()) + sum(self.leafs.values())
        return self.size_cached

class DirInput:
    def __init__(self, input):
        self.iterator = 0
        self.input = input
    
    def parse_next_command(self):
        if self.iterator >= len(self.input):
            return True, None, None
        first_line = self.input[self.iterator].strip("$ ")
        if first_line.startswith("cd"):
            self.iterator += 1
            arg = first_line.split(" ")[1]
            return False, "cd", arg
        elif first_line.startswith("ls"):
            acc = []
            self.iterator += 1
            while self.iterator < len(self.input) and (not self.input[self.iterator].startswith("$")):
                new_line = self.input[self.iterator]
                if (new_line.strip() != ""):
                    acc.append(new_line)
                self.iterator += 1
            return False, "ls", acc
        else:
            print("error")
            return True, None, None
        

def solve(input):
    dir_input = DirInput([l for l in input if l.strip() != ""])
    curr_dir = []

    done, command, args = dir_input.parse_next_command()
    nodes = {}
    while not done:
        if command == "cd":
            if args == "..":
                curr_dir.pop()
            else:
                curr_dir.append(args)
        elif command == "ls":
            dir = "".join(curr_dir)
            node = Node(dir, args)
            nodes[dir] = node
        done, command, args = dir_input.parse_next_command()
    
    for node in nodes.values():
        node.fill(nodes)
    
    sizes = [n.get_size() for n in nodes.values()]
    sizes_dict = {k: v.get_size() for k, v in nodes.items()}
    p1 = sum(s for s in sizes if s < 100000)

    used_space = sizes_dict["/"]
    unused_space = 70000000 - used_space
    p2 = min([s for s in sizes if unused_space + s > 30000000])

    return p1, p2

start = time.time()
answer1, answer2 = solve(input)

print("Part 1")
print(f"Answer: {answer1}")
# print(submit(7, 1, answer1).text)

print("Part 2")
print(f"Answer: {answer2}")
# print(submit(7, 2, answer1).text)
print(f"Took {time.time() - start} seconds for both parts")