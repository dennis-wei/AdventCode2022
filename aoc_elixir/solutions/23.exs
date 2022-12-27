defmodule Day23 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/23.txt"
      true -> "test_input/23.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_grid(grid) do
    enumerated = Enum.zip(1..length(grid), grid)
    Enum.reduce(enumerated, MapSet.new, fn {y, row}, acc ->
      chars = String.graphemes(row)
      enum_chars = Enum.zip(1..length(chars), chars)
      Enum.reduce(enum_chars, acc, fn {x, c}, iacc ->
        cond do
          c == "#" -> MapSet.put(iacc, {x, y})
          true -> iacc
        end
      end)
    end)
  end

  @candidate_map %{
    "N" => [{-1, -1}, {0, -1}, {1, -1}],
    "S" => [{-1, 1}, {0, 1}, {1, 1}],
    "E" => [{1, 1}, {1, 0}, {1, -1}],
    "W" => [{-1, 1}, {-1, 0}, {-1, -1}],
  }

  @delta_map %{
    "N" => {0, -1},
    "S" => {0, 1},
    "E" => {1, 0},
    "W" => {-1, 0},
    :nothing => {0, 0}
  }

  @all_neighbors [{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}]

  def check(dir, locs, {x, y}) do
    deltas = Map.fetch!(@candidate_map, dir)
    candidates = deltas
      |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    not Enum.any?(candidates, fn c -> MapSet.member?(locs, c) end)
  end

  def print_elves(elves) do
    {min_x, max_x} = Enum.map(elves, fn {x, _y} -> x end)
      |> Enum.min_max
    {min_y, max_y} = Enum.map(elves, fn {_x, y} -> y end)
      |> Enum.min_max

    str = Enum.reduce(min_y..max_y, "", fn y, acc ->
      row = Enum.reduce(min_x..max_x, "", fn x, iacc ->
        cond do
          MapSet.member?(elves, {x, y}) -> iacc <> "#"
          true -> iacc <> "."
        end
      end)
      acc <> row <> "\n"
    end)

    IO.puts(str)
  end

  def no_surrounding(elves, {ex, ey}) do
    not Enum.any?(@all_neighbors, fn {dx, dy} -> MapSet.member?(elves, {ex + dx, ey + dy}) end)
  end


  def simulate(initial, num_iters) do
    initial_rotation = ["N", "S", "W", "E"]
    num_elves = MapSet.size(initial)
    print_elves(initial)

    {final_elves, final_rotation} = Enum.reduce_while(1..num_iters, {initial, initial_rotation}, fn iter, {elves, rotation} ->
      choices = Enum.map(elves, fn e ->
        cond do
          no_surrounding(elves, e) -> :nothing
          true -> Enum.reduce_while(rotation, :nothing, fn dir, acc ->
            case check(dir, elves, e) do
              true -> {:halt, dir}
              false -> {:cont, acc}
            end
          end)
        end
      end)

      projected = Enum.zip(elves, choices)
        |> Enum.map(fn {{ex, ey}, choice} ->
          {dx, dy} = Map.fetch!(@delta_map, choice)
          {{ex, ey}, {ex + dx, ey + dy}}
        end)

      overlaps = Enum.map(projected, fn {t1, t2} -> t2 end)
        |> Enum.reduce({MapSet.new, MapSet.new}, fn t, {seen, overlaps} ->
          cond do
            MapSet.member?(seen, t) -> {seen, MapSet.put(overlaps, t)}
            true -> {MapSet.put(seen, t), overlaps}
          end
        end)
        |> elem(1)

      updated_elves = Enum.map(projected, fn {orig, proj} ->
        cond do
          MapSet.member?(overlaps, proj) -> orig
          true -> proj
        end
      end)
        |> Enum.into(MapSet.new)

      updated_rotation = tl(rotation) ++ [hd(rotation)]
      # print_elves(updated_elves)

      cond do
        updated_elves == elves -> {:halt, {updated_elves, iter}}
        true -> {:cont, {updated_elves, updated_rotation}}
      end
    end)

  end

  def solve(test \\ false) do
    initial = get_input(test)
      |> parse_grid

    {p1_elves, _rotation} = simulate(initial, 10)
    {min_x, max_x} = Enum.map(p1_elves, fn {x, _y} -> x end)
      |> Enum.min_max
    {min_y, max_y} = Enum.map(p1_elves, fn {_x, y} -> y end)
      |> Enum.min_max

    part1 = (max_x - min_x + 1) * (max_y - min_y + 1) - MapSet.size(p1_elves)

    {p2_elves, iters} = simulate(initial, 10000)
    part2 = iters
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day23.solve(false)
