Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/10.txt"
# filename = "test_input/10.txt"
input = Input
  # .ints(filename)
  .line_tokens(filename)
  # .lines(filename)
  # .line_of_ints(filename)

defmodule Day10 do
  def parse_line(line) do
    case line do
      ["noop"] -> {0, 1}
      ["addx", n] -> {String.to_integer(n), 2}
    end
  end

  def solve(input, raw_checkpoints) do
    parsed = Enum.map(input, &parse_line/1)
    checkpoints = Enum.map(raw_checkpoints, fn cp -> {cp, nil} end)
      |> Enum.into(%{})
    start = {1, nil, parsed, checkpoints, "\n"}
    post_run = Enum.reduce_while(raw_checkpoints, start, fn cycle, {acc, curr, queue, checkpoints, image} ->
      {updated_curr, updated_queue} = cond do
        curr == nil -> {hd(queue), tl(queue)}
        true -> {curr, queue}
      end

      updated_checkpoints = cond do
        Map.has_key?(checkpoints, cycle) -> Map.put(checkpoints, cycle, acc)
        true -> checkpoints
      end

      curr_sprites = [acc - 1, acc, acc + 1]
      added_pixel = cond do
        Enum.member?(curr_sprites, rem(cycle - 1, 40)) -> "#"
        true -> "."
      end
      added_newline = cond do
        rem(cycle, 40) == 0 -> "\n"
        true -> ""
      end
      updated_image = image <> added_pixel <> added_newline

      {processed_acc, processed_curr} = case updated_curr do
        {arg, 1} -> {acc + arg, nil}
        {arg, n} -> {acc, {arg, n - 1}}
      end

      res = {processed_acc, processed_curr, updated_queue, updated_checkpoints, updated_image}
      cond do
        length(updated_queue) == 0 and processed_curr == nil -> {:halt, res}
        true -> {:cont, res}
      end
    end)

    sorted = elem(post_run, 3)
      |> Enum.into([])
      |> Enum.sort_by(fn {k, _v} -> k end)

    p1 = sorted
      |> Enum.filter(fn {k, v} -> Enum.member?([20, 60, 100, 140, 180, 220], k) and v != nil end)
      |> Enum.map(fn {k, v} -> k * v end)
      |> Enum.sum

    {p1, elem(post_run, 4)}
  end
end

{p1, p2} = Day10.solve(input, 1..240)

part1 = p1

part2 = p2

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
