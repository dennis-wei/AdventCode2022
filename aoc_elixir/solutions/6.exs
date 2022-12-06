Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/6.txt"
# filename = "test_input/6.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  .lines(filename)
  # .line_of_ints(filename)

defmodule Day6 do
  def count_distinct(cl) do
    cl
      |> MapSet.new()
      |> MapSet.size()
  end

  def until_distinct(cl, num_distinct) do
    length = length(cl)
    0..length-1
      |> Enum.reduce_while(0, fn i, _acc ->
        slice = Enum.slice(cl, i, num_distinct)
        distinct = count_distinct(slice)
        case distinct do
          ^num_distinct -> {:halt, i + num_distinct}
          _ -> {:cont, i + num_distinct}
        end
      end)
  end
end

input_cl = input
  |> Enum.at(0)
  |> String.to_charlist

part1 = input_cl
  |> Day6.until_distinct(4)

part2 = input_cl
  |> Day6.until_distinct(14)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
