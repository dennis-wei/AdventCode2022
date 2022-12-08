Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/8.txt"
# filename = "test_input/8.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  .lines(filename)
  # .line_of_ints(filename)

defmodule Day8 do
  def get_left(grid, {x, y}) do
    Enum.map(y-1..0//-1, fn dy -> Map.get(grid, {x, dy}) end)
  end

  def get_right(grid, {x, y}) do
    Enum.reduce_while(y+1..10000, [], fn dy, acc ->
      case Map.fetch(grid, {x, dy}) do
        {:ok, res} -> {:cont, [res | acc]}
        :error -> {:halt, acc}
      end
    end)
      |> Enum.reverse
  end

  def get_top(grid, {x, y}) do
    Enum.map(x-1..0//-1, fn dx -> Map.get(grid, {dx, y}) end)
  end

  def get_bottom(grid, {x, y}) do
    Enum.reduce_while(x+1..10000, [], fn dx, acc ->
      case Map.fetch(grid, {dx, y}) do
        {:ok, res} -> {:cont, [res | acc]}
        :error -> {:halt, acc}
      end
    end)
      |> Enum.reverse
  end

  def visible(vis_list, height) do
    Enum.all?(vis_list, fn h -> h < height end)
  end

  def score(vis_list, height) do
    Enum.reduce_while(vis_list, 0, fn t, acc ->
      case t < height do
        true -> {:cont, acc + 1}
        false -> {:halt, acc + 1}
      end
    end)
  end
end

ginput = input
  |> Enum.map(fn l -> String.graphemes(l) end)
  |> Enum.map(fn cl -> Enum.map(cl, fn c -> Integer.parse(c) |> elem(0) end) end)
grid = Grid.make_grid(ginput)

visible = Enum.reduce(grid, [], fn {t, height}, acc ->
  to_test = [Day8.get_left(grid, t), Day8.get_right(grid, t), Day8.get_top(grid, t), Day8.get_bottom(grid, t)]
  vis_dirs = Enum.map(to_test, fn vis -> Day8.visible(vis, height) end)
  case Enum.any?(vis_dirs) do
    true -> [t | acc]
    false -> acc
  end
end)

scores = Enum.map(grid, fn {t, height} ->
  to_test = [Day8.get_left(grid, t), Day8.get_right(grid, t), Day8.get_top(grid, t), Day8.get_bottom(grid, t)]
  scores = to_test
    |> Enum.map(fn vis -> Day8.score(vis, height) end)
  prod = scores
    |> Enum.product
  {t, prod}
end)
  |> Enum.into(%{})

part1 = visible
  |> Enum.count

part2 = scores
  |> Map.values
  |> Enum.max

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
