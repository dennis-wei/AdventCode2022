import os
import re
import requests

from collections import defaultdict

def split_newline(i):
    return [l for l in i.split("\n")]

def space_split(input):
    return [l.split(" ") for l in input]

def int_parsed_list(input):
    return [int(l) for l in input]

def list_of_ints(l):
    return [int(e) for e in l]

def get_all_nums(s):
    return list_of_ints(re.findall(r'-?\d+', s))

def grid_to_map(i, index_by_one=False, split_input=False):
    if split_input:
        i = i.split("\n")
    result = {}
    for row_number, row in enumerate(i):
        for col_number, char in enumerate(row.strip()):
            if index_by_one:
                k = (row_number + 1, col_number + 1)
            else:
                k = (row_number, col_number)
            result[k] = char
    return result
            

def submit(day, part, answer):
    print(os.environ['ADVENT_SESSION'])
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': f"session={os.environ['ADVENT_SESSION']}",
        'DNT': "1"
    }
    return requests.post(f"https://adventofcode.com/2022/day/{day}/answer", data = f"level={part}&answer={answer}", headers=headers)
    
class Input:
    def __init__(self, raw_input):
        self.raw_input = raw_input
    
    def all(self):
        return self.raw_input

    def tokens(self, sep = r"[\s\n]+"):
        return re.compile(sep).split(self.raw_input)

    def line_tokens(self, sep = r"[\s]+", line_sep = r"\n"):
	    return [re.compile(sep).split(line) for line in re.compile(line_sep).split(self.raw_input)]

    def lines(self):
        return self.raw_input.splitlines()

    def ints(self):
        return [int(l.strip()) for l in self.lines()]

    def int_tokens(self):
        return [get_all_nums(l) for l in self.lines()]

class Grid:
    def __init__(self, input, replacements = {}, default = "."):
        self.grid = {}
        self.height = len(input)
        self.length = len(input[0])
        self.default = default
        for row_num, row in enumerate(input):
            for col_num, c in enumerate(row):
                self.grid[(row_num, col_num)] = replacements.get(c, c)

    def items(self):
        return self.grid.items()
    
    def get_adjacent(self, x, y, diagonal=True):
        ret = {}
        if diagonal:
            checks = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, 1), (1, -1), (-1, -1)]
        else:
            checks = [(1, 0), (0, 1), (-1, 0), (0, -1)]
        for xd, yd in checks:
            if (x + xd, y + yd) in self.grid:
                ret[(x + xd, y + yd)] = self.grid[(x + xd, y + yd)]
        return ret

    def print_grid(self, replacements = {}):
        for i in range(self.height):
            for j in range(self.length):
                v = self.grid.get((i, j), self.default)
                print(replacements.get(v, v), end="")
            print()
        print()