defmodule GridData do
  defstruct [:grid, :row_bounds, :col_bounds, :maxx, :maxy]
end

defmodule Day22 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/22.txt"
      true -> "test_input/22.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename, "\n", "\n\n", false)
      # .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_instr(instr) do
    dir_set = String.graphemes("LURD")
      |> MapSet.new
    Enum.reduce(String.graphemes(instr), {[], ""}, fn c, {sections, acc} ->
      cond do
        MapSet.member?(dir_set, c) -> {sections ++ [String.to_integer(acc), c], ""}
        true -> {sections, acc <> c}
      end
    end)
      |> then(fn {acc, t} -> acc ++ [String.to_integer(t)] end)
  end

  def make_grid(raw_grid, part \\ 1) do
    rows_enumerated = Enum.zip(1..length(raw_grid), raw_grid)
    grid = Enum.reduce(rows_enumerated, %{}, fn {y, row}, grid ->
      graphemes = String.graphemes(row)
      columns_enumerated = Enum.zip(1..length(graphemes), graphemes)
      Enum.reduce(columns_enumerated, grid, fn {x, c}, gacc ->
        case c do
          "#" -> Map.put(gacc, {x, y}, c)
          "." -> Map.put(gacc, {x, y}, c)
          _ -> gacc
        end
      end)
    end)

    max_x = Map.keys(grid)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.max

    max_y = Map.keys(grid)
      |> Enum.map(fn {_x, y} -> y end)
      |> Enum.max

    col_bounds = Enum.reduce(1..max_x, %{}, fn tx, acc ->
      {min_y, max_y} = grid
        |> Enum.filter(fn {{x, _y}, _val} -> x == tx end)
        |> Enum.map(fn {{_x, y}, _val} -> y end)
        |> Enum.min_max

      Map.put(acc, tx, {min_y, max_y})
    end)

    row_bounds = Enum.reduce(1..max_y, %{}, fn ty, acc ->
      {min_x, max_x} = grid
        |> Enum.filter(fn {{_x, y}, _val} -> y == ty end)
        |> Enum.map(fn {{x, _y}, _val} -> x end)
        |> Enum.min_max

      Map.put(acc, ty, {min_x, max_x})
    end)

    %GridData{grid: grid, row_bounds: row_bounds, col_bounds: col_bounds, maxx: max_x, maxy: max_y}
  end

  def rotate_cw({p, o}, path) do
    new_dir = case o do
      ">" -> "v"
      "v" -> "<"
      "<" -> "^"
      "^" -> ">"
    end

    updated_path = Map.put(path, p, new_dir)
    {{p, new_dir}, updated_path}
  end

  def rotate_ccw({p, o}, path) do
    new_dir = case o do
      ">" -> "^"
      "^" -> "<"
      "<" -> "v"
      "v" -> ">"
    end

    updated_path = Map.put(path, p, new_dir)
    {{p, new_dir}, updated_path}
  end

  @dir_delta %{
    ">" => {1, 0},
    "^" => {0, -1},
    "v" => {0, 1},
    "<" => {-1, 0}
  }

  def get_wrap_loc_pt1(gridd, {x, y}, o) do
    case o do
      ">" ->
        {lb, rb} = Map.fetch!(gridd.row_bounds, y)
        {{rb + 1, y}, {lb, y}, o}
      "<" ->
        {lb, rb} = Map.fetch!(gridd.row_bounds, y)
        {{lb - 1, y}, {rb, y}, o}
      "^" ->
        {ub, bb} = Map.fetch!(gridd.col_bounds, x)
        {{x, ub - 1}, {x, bb}, o}
      "v" ->
        {ub, bb} = Map.fetch!(gridd.col_bounds, x)
        {{x, bb + 1}, {x, ub}, o}
    end
  end

  @test_rect_regions %{
    {2, 0} => "A",
    {0, 1} => "B",
    {1, 1} => "C",
    {2, 1} => "D",
    {2, 2} => "E",
    {3, 2} => "F"
  }

  @rect_regions %{
    {2, 0} => "A",
    {1, 0} => "B",
    {1, 1} => "C",
    {1, 2} => "D",
    {0, 2} => "E",
    {0, 3} => "F"
  }

  @rect_wraps %{
    "A" => %{
      "^" => {"F", "B", "^", 1},
      "v" => {"C", "R", "<", 1},
      ">" => {"D", "R", "<", -1}
    },
    "B" => %{
      "^" =>, {"F", "L", ">", 1},
      "<" => {"E", "L", ">", -1}
    },
    "C" => %{
      "<" => {"E", "T", "v", 1},
      ">" => {"A", "B", "^", 1}
    },
    "D" => %{
      "v" => {"F", "R", "<", 1},
      ">" => {"A", "R", "<", -1}
    },
    "E" => %{
      "^" =>, {"C", "L", ">", 1},
      "<" =>, {"B", "L", ">", -1}
    },
    "F" => %{
      "<" => {"B", "T", "v", 1},
      "v" => {"A", "T", "v", 1},
      ">" => {"D", "B", "^", 1}
    },
  }

  def get_wrap_loc_pt2(gridd, {x, y}, o, region_size \\ 50) do
    x_region = div(x - 1, region_size)
    y_region = div(y - 1, region_size)
    rect = Map.fetch!(@rect_regions, {x_region, y_region})

    get_wrap_loc_pt1(gridd, {x, y}, o)
  end

  def get_wrap_loc(gridd, {x, y}, o, part) do
    case part do
      1 -> get_wrap_loc_pt1(gridd, {x, y}, o)
      2 -> get_wrap_loc_pt2(gridd, {x, y}, o)
    end
  end

  def get_projected_loc(gridd, {x, y}, o, part) do
    case part do
      1 ->
        {dx, dy} = Map.get(@dir_delta, o)
        {wrap_loc, dest_loc, dest_dir} = get_wrap_loc(gridd, {x, y}, o, part)
        projected = {x + dx, y + dy}
        cond do
          projected == wrap_loc -> {dest_loc, dest_dir}
          true -> {projected, o}
        end
    end
  end


  def move(gridd, num_steps, {{ix, iy}, o}, path, part) do
    {new_loc, new_dir, updated_path} = Enum.reduce(1..num_steps, {{ix, iy}, o, path}, fn _iter, {{x, y}, dir, pacc} ->
      {projected_loc, projected_dir} = get_projected_loc(gridd, {x, y}, dir, part)
      loc_type = Map.fetch!(gridd.grid, projected_loc)
      {loc_res, dir_res} = case loc_type do
        "#" -> {{x, y}, dir}
        "." -> {projected_loc, projected_dir}
      end

      {loc_res, dir_res, Map.put(pacc, loc_res, dir_res)}
    end)
    {{new_loc, new_dir}, updated_path}
  end

  def print_grid(gridd, path) do
    str = Enum.reduce(1..gridd.maxy, "", fn y, acc ->
      final_row = Enum.reduce(1..gridd.maxx, "", fn x, row ->
        cond do
          Map.has_key?(path, {x, y}) -> row <> Map.fetch!(path, {x, y})
          true -> row <> Map.get(gridd.grid, {x, y}, " ")
        end
      end)
      acc <> final_row <> "\n"
    end)

    IO.puts(str)
  end

  def simulate(gridd, instr, part \\ 1) do
    initial = gridd.row_bounds
      |> Map.fetch!(1)
      |> then(fn {l, _u} -> {l, 1} end)
    IO.puts("Starting at {#{elem(initial, 0)}, #{elem(initial, 1)}}")

    initial_state = {initial, ">"}
    initial_path = %{initial => ">"}
    # print_grid(gridd, initial_path)

    {final_state, path} = Enum.reduce(instr, {initial_state, initial_path}, fn op, {state, path} ->
      {{new_loc, new_or}, new_path} = case op do
        "R" -> rotate_cw(state, path)
        "L" -> rotate_ccw(state, path)
        n -> move(gridd, n, state, path, part)
      end
      # print_grid(gridd, new_path)
      {{new_loc, new_or}, new_path}
    end)

    # print_grid(gridd, path)
    final_state
  end

  def solve(test \\ false) do
    [raw_grid, raw_instr] = get_input(test)
    instr = parse_instr(hd(raw_instr))
    gridd = make_grid(raw_grid)

    part1_simulation = simulate(gridd, instr, 1)
    {{x1, y1}, o1} = part1_simulation

    or_code1 = Map.get(%{
      ">" => 0,
      "v" => 1,
      "<" => 2,
      "^" => 3
    }, o1)

    part1 = 1000 * y1 + 4 * x1 + or_code1

    part2 = nil
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day22.solve(true)
