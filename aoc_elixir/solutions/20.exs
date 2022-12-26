defmodule Day20 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/20.txt"
      true -> "test_input/20.txt"
    end
    Input
      .ints(filename)
      # .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
  end

  def mix(enumerated) do
    size = length(enumerated)
    Enum.reduce(0..size-1, enumerated, fn id, acc ->
      idx = Enum.find_index(acc, fn {i, _e} -> i == id end)
      {{id, val}, popped_list} = List.pop_at(acc, idx)
      insert_idx_raw = rem(idx + val, size - 1)
      cond do
        insert_idx_raw <= 0 -> List.insert_at(popped_list, insert_idx_raw - 1, {id, val})
        true -> List.insert_at(popped_list, insert_idx_raw, {id, val})
      end
    end)
  end

  def score(list) do
    idx0 = Enum.find_index(list, fn {_i, v} -> v == 0 end)
    size = length(list)
    [1000, 2000, 3000]
      |> Enum.map(fn cp -> Enum.at(list, rem(cp + idx0, size)) end)
      |> IO.inspect
      |> Enum.map(fn {_i, v} -> v end)
      |> Enum.sum
  end

  def solve(test \\ false) do
    input = get_input(test)
    size = length(input)
    enumerated = Enum.zip(0..size-1, input)

    part1_mixed = mix(enumerated)
    part1 = score(part1_mixed)

    dkey = 811589153
    dkey_applied = Enum.map(enumerated, fn {id, v} -> {id, v * dkey} end)
    part2_mixed = Enum.reduce(1..10, dkey_applied, fn _iter, acc ->
      mix(acc)
    end)
    part2 = score(part2_mixed)

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day20.solve(false)
