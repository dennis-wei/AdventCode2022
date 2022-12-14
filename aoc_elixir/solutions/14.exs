defmodule Day14 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/14.txt"
      true -> "test_input/14.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename, " -> ", "\n")
      # .lines(filename)
      # .line_of_ints(filename)
  end

  def get_between({{x1, y1}, {x2, y2}}) do
    cond do
      x1 == x2 -> Enum.map(y1..y2, fn y -> {x1, y} end)
      y1 == y2 -> Enum.map(x1..x2, fn x -> {x, y1} end)
      true -> []
    end
  end

  def parse_line(line, acc) do
    as_ints =  line
      |> Enum.map(fn s ->
        [sx, sy] = String.split(s, ",")
        {String.to_integer(sx), String.to_integer(sy)}
    end)
    Enum.zip(as_ints, tl(as_ints))
      |> Enum.flat_map(&get_between/1)
      |> Enum.map(fn t -> {t, "#"} end)
      |> Enum.into(acc)
  end

  def parse_input(input) do
    parsed = Enum.reduce(input, Map.new(), &parse_line/2)

    max_y = Map.keys(parsed)
      |> Enum.map(&elem(&1, 1))
      |> Enum.max

    {min_x, max_x} = Map.keys(parsed)
      |> Enum.map(&elem(&1, 0))
      |> Enum.min_max

    Map.put(parsed, :max_y, max_y)
      |> Map.put(:min_x, min_x)
      |> Map.put(:max_x, max_x)
  end

  def print_grid(grid) do
    {min_x, max_x} = Map.keys(grid)
      |> Enum.filter(fn k -> is_tuple(k) end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.min_max

    {min_y, max_y} = Map.keys(grid)
      |> Enum.filter(fn k -> is_tuple(k) end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.min_max
    min_y = Enum.min([0, min_y])

    Enum.reduce(min_y..max_y, "", fn y, y_acc ->
      y_acc <> Enum.reduce(min_x..max_x, "", fn x, x_acc ->
        x_acc <> Map.get(grid, {x, y}, ".")
      end) <> "\n"
    end)
      |> IO.puts
  end

  def determine_land({{x, y}, grid, _done}) do
    cands = [
      {{x, y + 1}, Map.get(grid, {x, y + 1}, ".")},
      {{x - 1, y + 1}, Map.get(grid, {x - 1, y + 1}, ".")},
      {{x + 1, y + 1}, Map.get(grid, {x + 1, y + 1}, ".")},
    ]

    {lx, ly} = cands
      |> Enum.filter(fn {_p, r} -> r == "." end)
      |> then(fn cands ->
        case cands do
          [] -> {x, y}
          lst -> hd(lst) |> elem(0)
        end
      end)

    cond do
      {lx, ly} == {500, 0} -> {:halt, {{lx, ly}, Map.put(grid, {lx, ly}, "s"), true}}
      ly > Map.fetch!(grid, :max_y) + 5 -> {:halt, {{lx, ly}, grid, true}}
      {lx, ly} == {x, y} -> {:halt, {{lx, ly}, Map.put(grid, {x, y}, "o"), false}}
      true -> {:cont, {{lx, ly}, grid, false}}
    end
  end

  def drop_sand(grid_start) do
    {_landing, updated_grid, is_done} = Enum.reduce_while(1..500000, {{500, 0}, grid_start, false}, fn _idx, acc ->
      determine_land(acc)
    end)

    case is_done do
      false -> {:cont, updated_grid}
      true -> {:halt, updated_grid}
    end
  end

  def simulate_sand(grid) do
    Enum.reduce_while(1..50000, grid, fn _idx, grid_acc -> drop_sand(grid_acc) end)
  end

  def pt2_augment(grid) do
    floor_height = Map.fetch!(grid, :max_y) + 2
    min_x = Map.fetch!(grid, :min_x) - 150
    max_x = Map.fetch!(grid, :max_x) + 150
    Enum.reduce(min_x..max_x, grid, fn x, acc -> Map.put(acc, {x, floor_height}, "#") end)
  end

  def solve(test \\ false) do
    input = get_input(test)
    base_grid = parse_input(input)

    pt1_grid = simulate_sand(base_grid)

    part1 = pt1_grid
      |> Map.values
      |> Enum.count(fn v -> v == "o" end)

    pt2_grid = base_grid
      |> pt2_augment
      |> simulate_sand

    part2 = pt2_grid
      |> Map.values
      |> Enum.count(fn v -> v == "o" or v == "s" end)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day14.solve()
