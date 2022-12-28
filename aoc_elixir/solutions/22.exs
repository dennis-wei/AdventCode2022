defmodule GridData do
  defstruct [:grid, :initial, :wraps, :maxx, :maxy]
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

  def make_wraps_pt1(grid, max_x, max_y) do
    col_wraps = Enum.reduce(1..max_x, %{}, fn tx, acc ->
      {min_y, max_y} = grid
        |> Enum.filter(fn {{x, _y}, _val} -> x == tx end)
        |> Enum.map(fn {{_x, y}, _val} -> y end)
        |> Enum.min_max

      acc
        |> Map.put({{tx, min_y - 1}, "^"}, {{tx, max_y}, "^"})
        |> Map.put({{tx, max_y + 1}, "v"}, {{tx, min_y}, "v"})
    end)

    row_wraps = Enum.reduce(1..max_y, %{}, fn ty, acc ->
      {min_x, max_x} = grid
        |> Enum.filter(fn {{_x, y}, _val} -> y == ty end)
        |> Enum.map(fn {{x, _y}, _val} -> x end)
        |> Enum.min_max

      acc
        |> Map.put({{min_x - 1, ty}, "<"}, {{max_x, ty}, "<"})
        |> Map.put({{max_x + 1, ty}, ">"}, {{min_x, ty}, ">"})
    end)

    Map.merge(col_wraps, row_wraps)
  end

  @rect_regions %{
    {2, 0} => "A",
    {1, 0} => "B",
    {1, 1} => "C",
    {1, 2} => "D",
    {0, 2} => "E",
    {0, 3} => "F"
  }

  @inv_rect_regions @rect_regions |> Enum.map(fn {k, v} -> {v, k} end) |> Enum.into(%{})

  @rect_wraps %{
    {"A", "T"} => {"F", "B", 1},
    {"A", "B"} => {"C", "R", 1},
    {"A", "R"} => {"D", "R", -1},

    {"B", "T"} => {"F", "L", 1},
    {"B", "L"} => {"E", "L", -1},

    {"C", "L"} => {"E", "T", 1},
    {"C", "R"} => {"A", "B", 1},

    {"D", "B"} => {"F", "R", 1},
    {"D", "R"} => {"A", "R", -1},

    {"E", "T"} => {"C", "L", 1},
    {"E", "L"} => {"B", "L", -1},

    {"F", "L"} => {"B", "T", 1},
    {"F", "B"} => {"A", "T", 1},
    {"F", "R"} => {"D", "B", 1}
  }

  def get_edge(region, edge, inner_outer, region_size \\ 50) do
    {rx, ry} = Map.fetch!(@inv_rect_regions, region)
    min_x = rx * region_size + 1
    max_x = (rx + 1) * region_size
    min_y = ry * region_size + 1
    max_y = (ry + 1) * region_size

    edge_correction = case inner_outer do
      :inner -> 0
      :outer -> 1
    end

    case edge do
      "T" -> Enum.map(min_x..max_x, fn x -> {x, min_y - edge_correction} end)
      "B" -> Enum.map(min_x..max_x, fn x -> {x, max_y + edge_correction} end)
      "L" -> Enum.map(min_y..max_y, fn y -> {min_x - edge_correction, y} end)
      "R" -> Enum.map(min_y..max_y, fn y -> {max_x + edge_correction, y} end)
    end
  end

  def zip_edges({r1, r1e}, {r2, r2e}, pol, region_size \\ 50) do
    out_points = get_edge(r1, r1e, :outer, region_size)
    in_points = get_edge(r2, r2e, :inner, region_size)
    pol_corrected_in = case pol do
      1 -> in_points
      -1 -> Enum.reverse(in_points)
    end

    out_dir = case r1e do
      "T" -> "^"
      "L" -> "<"
      "R" -> ">"
      "B" -> "v"
    end

    in_dir = case r2e do
      "T" -> "v"
      "L" -> ">"
      "R" -> "<"
      "B" -> "^"
    end

    Enum.zip(out_points, pol_corrected_in)
      |> Enum.map(fn {op, ip} -> {{op, out_dir}, {ip, in_dir}} end)
      |> Enum.into(%{})
  end

  def make_wraps_pt2(region_size) do
    @rect_wraps
      |> Enum.map(fn {{r1, r1e}, {r2, r2e, p}} -> zip_edges({r1, r1e}, {r2, r2e}, p, region_size) end)
      |> Enum.reduce(fn m1, acc -> Map.merge(m1, acc) end)
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

    initial_x = Map.keys(grid)
      |> Enum.filter(fn {_x, y} -> y == 1 end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.min
    initial = {initial_x, 1}

    wraps = case part do
      1 -> make_wraps_pt1(grid, max_x, max_y)
      2 -> make_wraps_pt2(50)
    end

    %GridData{grid: grid, initial: initial, wraps: wraps, maxx: max_x, maxy: max_y}
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

  def get_projected_loc(gridd, {x, y}, o) do
    {dx, dy} = Map.get(@dir_delta, o)
    projected = {x + dx, y + dy}
    cond do
      {x, y} == {8, 8} -> IO.inspect({projected, Map.get(gridd.wraps, projected)})
      true -> nil
    end
    case Map.get(gridd.wraps, {projected, o}) do
      nil -> {projected, o}
      {dest_loc, dest_dir} -> {dest_loc, dest_dir}
    end
  end


  def move(gridd, num_steps, {{ix, iy}, o}, path) do
    {new_loc, new_dir, updated_path} = Enum.reduce(1..num_steps, {{ix, iy}, o, path}, fn _iter, {{x, y}, dir, pacc} ->
      {projected_loc, projected_dir} = get_projected_loc(gridd, {x, y}, dir)
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

  def simulate(gridd, instr) do
    initial = gridd.initial
    IO.puts("Starting at {#{elem(initial, 0)}, #{elem(initial, 1)}}")

    initial_state = {initial, ">"}
    initial_path = %{initial => ">"}
    # print_grid(gridd, initial_path)

    {final_state, path} = Enum.reduce(instr, {initial_state, initial_path}, fn op, {state, path} ->
      {{new_loc, new_or}, new_path} = case op do
        "R" -> rotate_cw(state, path)
        "L" -> rotate_ccw(state, path)
        n -> move(gridd, n, state, path)
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

    pt1_gridd = make_grid(raw_grid, 1)
    part1_simulation = simulate(pt1_gridd, instr)
    {{x1, y1}, o1} = part1_simulation
    or_code1 = Map.get(%{
      ">" => 0,
      "v" => 1,
      "<" => 2,
      "^" => 3
    }, o1)
    part1 = 1000 * y1 + 4 * x1 + or_code1

    pt2_gridd = make_grid(raw_grid, 2)
    part2_simulation = simulate(pt2_gridd, instr)
    {{x2, y2}, o2} = part2_simulation
    or_code2 = Map.get(%{
      ">" => 0,
      "v" => 1,
      "<" => 2,
      "^" => 3
    }, o2)
    part2 = 1000 * y2 + 4 * x2 + or_code2

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day22.solve()
