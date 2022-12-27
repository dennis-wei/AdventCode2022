defmodule GridData do
  defstruct [:grid, :maxx, :maxy, :target]
end

defmodule Day24 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/24.txt"
      true -> "test_input/24.2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_grid(input) do
    enumerated = Enum.zip(1..length(input), input)
    parsed = Enum.reduce(enumerated, %{}, fn {y, row}, acc ->
      row_enum = Enum.zip(1..String.length(row), String.graphemes(row))
      Enum.reduce(row_enum, acc, fn {x, c}, acc ->
        case c do
          "#" -> Map.put(acc, {x, y}, "#")
          "." -> acc
          dir -> Map.put(acc, {x, y}, [dir])
        end
      end)
    end)

    max_x = Map.keys(parsed)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.max
    max_y = Map.keys(parsed)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.max

    augmented_grid = parsed
      |> Map.put({2, 0}, "#")
      |> Map.put({max_x - 1, max_y + 1}, "#")

    target = {max_x - 1, max_y}

    %GridData{grid: augmented_grid, maxx: max_x, maxy: max_y, target: target}
  end

  @storm_deltas %{
    "^" => {0, -1},
    ">" => {1, 0},
    "v" => {0, 1},
    "<" => {-1, 0}
  }

  def move_storms(gridd, grid, {x, y}, storms) do
    new_locs = Enum.map(storms, fn s ->
      {dx, dy} = Map.get(@storm_deltas, s)
      {px, py} = {x + dx, y + dy}
      wrapped = cond do
        px == 1 -> {gridd.maxx - 1, py}
        px == gridd.maxx -> {2, py}
        py == 1 -> {px, gridd.maxy - 1}
        py == gridd.maxy -> {px, 2}
        true -> {px, py}
      end
      {wrapped, s}
    end)

    Enum.reduce(new_locs, grid, fn {loc, s}, acc ->
      prior = Map.get(acc, loc, [])
      updated = [s | prior]
      Map.put(acc, loc, updated)
    end)
  end

  def storm_iter(gridd) do
    updated_grid = Enum.reduce(gridd.grid, %{}, fn {{x, y}, v}, acc ->
      cond do
        v == "#" -> Map.put(acc, {x, y}, "#")
        true -> move_storms(gridd, acc, {x, y}, v)
      end
    end)
    %{gridd | grid: updated_grid}
  end

  def print_grid(gridd) do
    grid = gridd.grid
    str = Enum.reduce(1..gridd.maxy, "", fn y, acc ->
      acc <> Enum.reduce(1..gridd.maxx, "", fn x, row ->
        val = Map.get(grid, {x, y}, ".")
        repr = cond do
          is_list(val) and length(val) > 1 -> "#{length(val)}"
          is_list(val) -> hd(val)
          true -> val
        end
        row <> repr
      end) <> "\n"
    end)

    IO.puts(str)
  end

  @neighbors [{0, 0}, {0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def simulate_iter(gridd, pos_loc) do
    pos_dest = Enum.reduce(pos_loc, MapSet.new, fn l, acc ->
      {x, y} = l
      Enum.reduce(@neighbors, acc, fn {dx, dy}, iacc ->
        MapSet.put(iacc, {x + dx, y + dy})
      end)
    end)

    updated_storm = storm_iter(gridd)
    filtered = Enum.filter(pos_dest, fn l ->
      not Map.has_key?(updated_storm.grid, l)
    end)

    {updated_storm, filtered}
  end

  def simulate(initial, start, max_iters) do
    possible = [start]

    Enum.reduce_while(1..max_iters, {initial, possible}, fn iter, {grid_acc, loc_acc} ->
      {updated_storm, updated_loc} = simulate_iter(grid_acc, loc_acc)
      cond do
        initial.target in updated_loc -> {:halt, {iter, updated_storm, updated_loc}}
        true -> {:cont, {updated_storm, updated_loc}}
      end
    end)
  end

  def solve(test \\ false) do
    input = get_input(test)
    gridd = parse_grid(input)

    start = {2, 1}
    goal = gridd.target

    # print_grid(gridd)
    {num_iters_there, there, _poss} = simulate(gridd, start, 1000)
    {num_iters_back, back, _poss} = simulate(%GridData{there | target: start}, goal, 1000)
    {num_iters_there_again, _there_again, _poss} = simulate(%GridData{back | target: goal}, start, 1000)

    part1 = num_iters_there
    part2 = num_iters_there + num_iters_back + num_iters_there_again
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day24.solve()
