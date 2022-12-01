Code.require_file("lib/input.ex")
filename = "input/1.txt"
# filename = "test_input/1.txt"
input = Input
  # .ints(filename)
  .line_tokens(filename, "\n", "\n\n")
  # .lines(filename)
  # .line_of_ints(filename)

defmodule Day1 do
end

sums = input
  |> Enum.map(fn e -> Enum.map(e, &String.to_integer/1) end)
  |> Enum.map(&Enum.sum/1)
  |> Enum.sort
  |> Enum.reverse

part1 = hd(sums)

part2 = sums
  |> Enum.slice(0, 3)
  |> Enum.sum

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
