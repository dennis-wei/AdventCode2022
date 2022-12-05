Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/4.txt"
# filename = "test_input/4.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  .lines(filename)
  # .line_of_ints(filename)

defmodule Day4 do
  def parse(line) do
    line
      |> String.split(",")
      |> Enum.flat_map(&String.split(&1, "-"))
      |> Enum.map(&String.to_integer/1)
  end

  def contains([l1, r1, l2, r2]) do
    (l1 <= l2 and r1 >= r2) or (l2 <= l1 and r2 >= r1)
  end

  def overlaps([l1, r1, l2, r2]) do
    (l1 <= l2 and r1 >= l2) or (l2 <= l1 and r2 >= l1)
  end
end

part1 = input
  |> Enum.map(&Day4.parse/1)
  |> Enum.count(&Day4.contains/1)

part2 = input
  |> Enum.map(&Day4.parse/1)
  |> Enum.count(&Day4.overlaps/1)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
