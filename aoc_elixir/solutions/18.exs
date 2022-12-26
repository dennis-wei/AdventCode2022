defmodule Day18 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/18.txt"
      true -> "test_input/18.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_line(l) do
    String.split(l, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
  end

  def get_neighbors({x, y, z}) do
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1},
    ]

  end

  def make_grid_graph(input) do
    {min_x, max_x} = input
      |> Enum.map(fn {x, _y, _z} -> x end)
      |> Enum.min_max
    {min_y, max_y} = input
      |> Enum.map(fn {_x, y, _z} -> y end)
      |> Enum.min_max
    {min_z, max_z} = input
      |> Enum.map(fn {_x, _y, z} -> z end)
      |> Enum.min_max

    graph = Enum.reduce(min_x-1..max_x+1, Graph.new, fn x, xacc ->
      Enum.reduce(min_y-1..max_y+1, xacc, fn y, yacc ->
        Enum.reduce(min_z-1..max_z+1, yacc, fn z, zacc ->
          p = {x, y, z}
          with_vertex = Graph.add_vertex(zacc, p)
          edges = Enum.zip(List.duplicate(p, 6), get_neighbors(p))
          Graph.add_edges(with_vertex, edges)
        end)
      end)
    end)
    {{min_x, min_y, min_z}, graph}
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(&parse_line/1)

    input_set = MapSet.new(input)

    part1 = Enum.reduce(input, 0, fn c, acc ->
      n = Enum.count(get_neighbors(c), fn n -> not MapSet.member?(input_set, n) end)
      acc + n
    end)

    {{mx, my, mz}, initial_graph} = make_grid_graph(input)
    removed = Graph.delete_vertices(initial_graph, input)
    reachable = Graph.reachable(removed, [{mx-1, my-1, mz-1}])
      |> Enum.into(MapSet.new)

    not_reachable = Graph.vertices(removed)
      |> Enum.filter(fn n -> not MapSet.member?(reachable, n) end)
      # |> IO.inspect

    part2 = Enum.reduce(input, 0, fn c, acc ->
      n = Enum.count(get_neighbors(c), fn n ->
        not MapSet.member?(input_set, n) and MapSet.member?(reachable, n)
      end)
      acc + n
    end)

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day18.solve(false)
