defmodule Day17 do
  @rocks %{
    0 => {[{0, 0}, {1, 0}, {2, 0}, {3, 0}], 0},
    1 => {[{0, 0}, {1, 0}, {1, 1}, {1, -1}, {2, 0}], 1},
    2 => {[{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}], 0},
    3 => {[{0, 0}, {0, 1}, {0, 2}, {0, 3}], 0},
    4 => {[{0, 0}, {1, 0}, {0, 1}, {1, 1}], 0},
  }

  @start [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 0}, {6, 0}]
    |> Enum.map(fn c -> {c, "-"} end)
    |> Enum.into(%{})

  def get_input(test \\ false) do
    filename = case test do
      false -> "input/17.txt"
      true -> "test_input/17.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def get_starting_spot(rock_i, max_y) do
    {coords, y_off} = Map.fetch!(@rocks, rem(rock_i, 5))
    {bx, by} = {2, max_y + y_off + 4}
    Enum.map(coords, fn {dx, dy} -> {bx + dx, by + dy} end)
  end

  def wind_move(map, rock_coords, wind) do
    {min_x, max_x} = rock_coords
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.min_max
    case wind do
      ">" -> cond do
        max_x == 6 -> rock_coords
        Enum.any?(rock_coords, fn {x, y} -> Map.has_key?(map, {x + 1, y}) end) -> rock_coords
        true -> Enum.map(rock_coords, fn {x, y} -> {x + 1, y} end)
      end
      "<" -> cond do
        min_x == 0 -> rock_coords
        Enum.any?(rock_coords, fn {x, y} -> Map.has_key?(map, {x - 1, y}) end)-> rock_coords
        true -> Enum.map(rock_coords, fn {x, y} -> {x - 1, y} end)
      end
    end
  end

  def will_stop(rock_coords, map) do
    Enum.any?(rock_coords, fn {x, y} -> Map.has_key?(map, {x, y}) end)
  end

  def place_rocks(map, rock_coords) do
    new_coords = Enum.map(rock_coords, fn c -> {c, "#"} end)
      |> Enum.into(%{})

    Map.merge(map, new_coords)
  end

  def grid_str(map, limit \\ false) do
    max_y = Map.keys(map)
      |> Enum.max_by(fn {_x, y} -> y end)
      |> elem(1)

    bottom = case limit do
      false -> 0
      n -> max_y - n
    end

    str = Enum.reduce(max_y..bottom//-1, "", fn y, acc ->
      acc <> Enum.reduce(0..6, "", fn x, row ->
        row <> Map.get(map, {x, y}, ".")
      end) <> "\n"
    end)

    str
  end

  def simulate_rock(rock_i, map, input, input_i) do
    max_y = Map.keys(map)
      |> Enum.max_by(fn {_x, y} -> y end)
      |> elem(1)

    starting_coords = get_starting_spot(rock_i, max_y)

    Enum.reduce_while(0..100, {map, input_i, starting_coords}, fn _n, {map, input_i, rock_coords} ->
      wind = Enum.at(input, rem(input_i, length(input)))
      wind_moved = wind_move(map, rock_coords, wind)
      dropped = Enum.map(wind_moved, fn {x, y} -> {x, y - 1} end)
      stop = will_stop(dropped, map)
      case stop do
        true -> {:halt, {place_rocks(map, wind_moved), input_i + 1, wind_moved}}
        false -> {:cont, {map, input_i + 1, dropped}}
      end
    end)
  end

  def simulate(input, num_rocks) do
    Enum.reduce_while(0..num_rocks-1, {@start, 0, %{}, %{}}, fn rock_i, {map, input_i, rock_i_cache, fp_cache} ->
      {updated_map, new_input_i, _new_rock} = simulate_rock(rock_i, map, input, input_i)
      fp = {rem(rock_i, 5), rem(input_i, length(input)), grid_str(map, 30)}
      max_y = Map.keys(updated_map)
        |> Enum.max_by(fn {_x, y} -> y end)
        |> elem(1)
      fp_data = {rock_i, max_y}
      cond do
        Map.has_key?(fp_cache, fp) -> {:halt, {fp_data, Map.fetch!(fp_cache, fp), rock_i_cache}}
        true -> {:cont, {updated_map, new_input_i, Map.put(rock_i_cache, rock_i, max_y), Map.put(fp_cache, fp, fp_data)}}
      end
    end)
  end

  def max_y(map) do
    Map.keys(map)
      |> Enum.max_by(fn {_x, y} -> y end)
      |> elem(1)
  end

  def calc_from_cycle(refresh, orig, incrs, target) do
    {ri, rh} = refresh
    {oi, oh} = orig
    cycle_length = ri - oi
    dh = rh - oh

    num_cycles = div(target - oi, cycle_length)
    i_after_cycles = oi + num_cycles * cycle_length
    h_after_cycles = oh + num_cycles * dh
    rem = target - i_after_cycles - 1
    diff = Map.fetch!(incrs, oi + rem) - oh
    h_after_cycles + diff
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> hd
      |> String.graphemes

    res = simulate(input, 2022)
    part1 = case res do
      {refresh, orig, incrs} -> calc_from_cycle(refresh, orig, incrs, 2022)
      {map, _input_i, _rock_i_cache, _fp_cache} -> max_y(map)
    end

    {refresh, orig, incrs} = simulate(input, 1000000000000)
    part2 = calc_from_cycle(refresh, orig, incrs, 1000000000000)

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day17.solve(false)
