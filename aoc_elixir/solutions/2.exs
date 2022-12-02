Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/2.txt"
# filename = "test_input/2.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  .lines(filename)
  # .line_of_ints(filename)

defmodule Day2 do
  def rps(str) do
    case str do
      "A X" -> {4, 3}
      "A Y" -> {8, 4}
      "A Z" -> {3, 8}
      "B X" -> {1, 1}
      "B Y" -> {5, 5}
      "B Z" -> {9, 9}
      "C X" -> {7, 2}
      "C Y" -> {2, 6}
      "C Z" -> {6, 7}
      _ -> {0, 0}
    end
  end

  def add_tup(t1, t2) do
    {elem(t1, 0) + elem(t2, 0), elem(t1, 1) + elem(t2, 1)}
  end
end

results = input
  |> Enum.map(&Day2.rps/1)
  |> Enum.reduce({0, 0}, &Day2.add_tup/2)

part1 = elem(results, 0)

part2 = elem(results, 1)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
