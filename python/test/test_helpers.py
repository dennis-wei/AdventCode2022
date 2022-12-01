import os, sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))

from util.helpers import list_of_ints, get_all_nums, grid_to_map

assert list_of_ints(["1", "2", "34", "5"]) == [1, 2, 34, 5]

assert get_all_nums("12fdsa23-%-45") == [12, 23, 45]

test_grid = [
    "1234",
    "5678",
    "9012",
    "3456"
]
zero_indexed_map = grid_to_map(test_grid)
assert len(zero_indexed_map) == 16
assert (0, 0) in zero_indexed_map
assert (4, 4) not in zero_indexed_map
one_indexed_map = grid_to_map(test_grid, index_by_one=True)
assert len(one_indexed_map) == 16
assert (0, 0) not in one_indexed_map
assert (4, 4) in one_indexed_map
test_grid_unsplit = """
1234
5678
9012
3456
""".strip()
non_split_map = grid_to_map(test_grid_unsplit, split_input=True)
assert len(non_split_map) == 16
assert (3, 3) in non_split_map