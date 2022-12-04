Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/3.txt"
# filename = "test_input/3.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  .lines(filename)
  # .line_of_ints(filename)

defmodule Day3 do
  def halve(str) do
    half = trunc(String.length(str) / 2)
    str
      |> String.split_at(half)
      |> Tuple.to_list
  end

  def get_shared(charsets) do
    charsets
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&MapSet.new/1)
      |> Enum.reduce(&MapSet.intersection/2)
  end

  @index_list String.to_charlist("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
  def get_points(char) do
    index = @index_list
      |> Enum.find_index(fn c -> c == char end)
    index + 1
  end
end

part1 = input
  |> Enum.map(&Day3.halve/1)
  |> Enum.flat_map(&Day3.get_shared/1)
  |> Enum.map(&Day3.get_points/1)
  |> Enum.sum

part2 = input
  |> Enum.chunk_every(3)
  |> Enum.flat_map(&Day3.get_shared/1)
  |> Enum.map(&Day3.get_points/1)
  |> Enum.sum

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
