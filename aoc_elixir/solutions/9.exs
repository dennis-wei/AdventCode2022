Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/9.txt"
# filename = "test_input/9.txt"
input = Input
  # .ints(filename)
  .line_tokens(filename)
  # .lines(filename)
  # .line_of_ints(filename)

defmodule Day9 do
  def parse_input(input) do
    Enum.map(input, fn [dir, amt] -> {dir, String.to_integer(amt)} end)
  end

  @dirs %{
    "L" => {0, -1},
    "R" => {0, 1},
    "U" => {-1, 0},
    "D" => {1, 0},
  }

  def update({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def is_neighbor({px, py}, {sx, sy}) do
    abs(px - sx) <= 1 and abs(py - sy) <= 1
  end

  def sign(n) do
    cond do
      n == 0 -> 0
      true -> div(n, abs(n))
    end
  end

  def move_segment({px, py}, {sx, sy}) do
    dx = sign(px - sx)
    dy = sign(py - sy)

    {sx + dx, sy + dy}
  end

  def iter_single(dir, {segments, visited}) do
    [hd | tail] = segments
    new_head = update(hd, Map.fetch!(@dirs, dir))
    updated_segments_rev = Enum.reduce(tail, [new_head], fn segment, acc ->
      prev = hd(acc)
      cond do
        is_neighbor(prev, segment) -> [segment | acc]
        true -> [move_segment(prev, segment) | acc]
      end
    end)

    last_tail = hd(updated_segments_rev)
    updated_visited = MapSet.put(visited, last_tail)
    {Enum.reverse(updated_segments_rev), updated_visited}
  end

  def iter({dir, amt}, {segments, visited}) do
    Enum.reduce(1..amt, {segments, visited}, fn _i, acc -> iter_single(dir, acc) end)
  end

  def solve(input, num_segments) do
    segments = List.duplicate({0, 0}, num_segments)
    input_rows = parse_input(input)
    {_updated_segments, visited} = Enum.reduce(input_rows, {segments, MapSet.new([{0, 0}])} , &iter/2)
    MapSet.size(visited)
  end
end

part1 = Day9.solve(input, 2)

part2 = Day9.solve(input, 10)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
