defmodule Day25 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/25.txt"
      true -> "test_input/25.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  @mapping %{
    "2" => 2,
    "1" => 1,
    "0" => 0,
    "-" => -1,
    "=" => -2
  }

  @inv_mapping Enum.map(@mapping, fn {k, v} -> {v, k} end) |> Enum.into(%{})

  def from_base_5(str) do
    ordered = String.graphemes(str) |> Enum.reverse
    enumerated = Enum.zip(0..length(ordered)-1, ordered)
    Enum.reduce(enumerated, 0, fn {p, c}, acc ->
      acc + Map.fetch!(@mapping, c) * 5**p
    end)
  end

  def to_base_5(n) do
    max_pow = round(:math.log(n) / :math.log(5))
    Enum.reduce(max_pow..0, {"", 0}, fn p, {str, sum} ->
      bound = case p do
        0 -> 0
        p -> from_base_5(String.duplicate("2", p))
      end
      n = Enum.reduce_while(-2..2, sum, fn n_att, _s_acc ->
        cond do
          abs(n - (sum + n_att * 5**p)) <= bound -> {:halt, n_att}
          true -> {:cont, n_att}
        end
      end)

      {str <> Map.fetch!(@inv_mapping, n), sum + n * 5**p}
    end)
      |> then(fn {s, n} -> {String.replace_leading(s, "0", ""), n} end)
  end

  def solve(test \\ false) do
    input = get_input(test)

    {part1_b5, part1_target} = input
      |> Enum.map(&from_base_5/1)
      |> Enum.sum
      |> to_base_5

    part1 = part1_b5
    part2 = nil
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day25.solve(false)
