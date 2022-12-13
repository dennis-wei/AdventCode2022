defmodule Day12 do
  def get_ord(c) do
    case c do
      "S" -> 0
      "E" -> 27
      oc -> String.to_charlist(oc) |> hd |> then(fn n -> n - 96 end)
    end
  end

  def normalize(n) do
    case n do
      0 -> 1
      27 -> 26
      o -> o
    end
  end

  def parse_grid(input) do
    input
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn l -> Enum.map(l, &get_ord/1) end)
      |> Grid.make_grid
  end

  def make_graph(grid) do
    edges = Enum.flat_map(grid, fn {k1, v1} ->
      valid_moves = Grid.get_neighbors(grid, k1)
        |> Enum.filter(fn {_k2, v2} -> normalize(v2) - normalize(v1) <= 1 end)
        |> Enum.map(fn {k, _v} -> k end)

      List.duplicate(k1, length(valid_moves))
        |> Enum.zip(valid_moves)
    end)

    Graph.new |> Graph.add_edges(edges)
  end

  def get_point(grid, search) do
    Enum.filter(grid, fn {_k, v} -> v == search end)
      |> hd
      |> elem(0)
  end

  def solve() do
    filename = "input/12.txt"
    # filename = "test_input/12.txt"
    input = Input
      .lines(filename)

    grid = parse_grid(input)

    graph = make_graph(grid)

    start_point = get_point(grid, 0)
    end_point = get_point(grid, 27)

    p1 = Graph.dijkstra(graph, start_point, end_point)
      # |> IO.inspect
      |> length
      |> then(fn n -> n - 1 end)

    a_edges = Enum.filter(grid, fn {_k, v} -> v <= 1 end)
      |> Enum.map(fn {k, _v} -> {start_point, k, weight: 0} end)

    updated_graph = Graph.add_edges(graph, a_edges)
    p2 = Graph.dijkstra(updated_graph, start_point, end_point)
      |> length
      |> then(fn n -> n - 2 end)

    IO.puts("Part 1: #{p1}")
    IO.puts("Part 2: #{p2}")
  end
end

Day12.solve()
