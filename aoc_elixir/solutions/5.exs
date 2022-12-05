Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/5.txt"
# filename = "test_input/5.txt"
input = Input
  .raw(filename)
  # .ints(filename)
  # .line_tokens(filename)
  # .lines(filename)
  # .line_of_ints(filename)

defmodule Day5 do
  def parse_initial(raw_initial) do
    input_rows = String.split(raw_initial, "\n")
    num_rows = input_rows
      |> List.last
      |> String.trim
      |> String.split(" ")
      |> List.last
      |> String.to_integer

    stack_rows = input_rows
      |> Enum.filter(fn r -> String.starts_with?(String.trim(r), "[") end)
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&Enum.chunk_every(&1, 4))
      |> Enum.map(fn chunks -> Enum.map(chunks, fn c -> Enum.at(c, 1) end) end)

    initial = List.duplicate([], num_rows)
    stack_rows
      |> Enum.reverse
      |> Enum.reduce(initial, fn row, acc ->
        Enum.zip([row, acc])
          |> Enum.map(fn {item, stack} -> case item do
            ' ' -> stack
            _ -> [item | stack]
          end end)
        end)
      |> Enum.map(fn cl -> to_string(cl) end)
      |> Enum.map(fn s -> String.trim(s) end)
      |> Enum.map(&String.to_charlist/1)
  end

  def parse_ops(raw_ops) do
    raw_ops
      |> String.split("\n")
      |> Enum.flat_map(fn l -> Regex.scan(~r/\d+/, l) end)
      |> Enum.flat_map(fn l -> Enum.map(l, &String.to_integer/1) end)
      |> Enum.chunk_every(3)
  end

  def parse_input(raw_input) do
    [raw_initial, raw_ops] = String.split(raw_input, "\n\n")
    initial = parse_initial(raw_initial)

    ops = parse_ops(raw_ops)
    [initial, ops]
  end

  def solve(raw_input) do
    [initial, ops] = parse_input(raw_input)

    p1 = ops
      |> Enum.reduce(initial, fn [count, s1, s2], acc ->
        Enum.reduce(1..count, acc, fn _, acc ->
          [popped | new_s1] = Enum.at(acc, s1 - 1)
          new_s2 = [popped | Enum.at(acc, s2 - 1)]
          acc
            |> List.replace_at(s1 - 1, new_s1)
            |> List.replace_at(s2 - 1, new_s2)
        end)
      end)
      |> Enum.map(fn s -> Enum.at(s, 0) end)

    p2 = ops
      |> Enum.reduce(initial, fn [count, s1, s2], acc ->
        popped = Enum.slice(Enum.at(acc, s1 - 1), 0..count-1)
        new_s1 = Enum.slice(Enum.at(acc, s1 - 1), count..-1)
        new_s2 = popped ++ Enum.at(acc, s2 - 1)
        acc
          |> List.replace_at(s1 - 1, new_s1)
          |> List.replace_at(s2 - 1, new_s2)
      end)
      |> Enum.map(fn s -> Enum.at(s, 0) end)

    [p1, p2]
  end
end

[part1, part2] = Day5.solve(input)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
