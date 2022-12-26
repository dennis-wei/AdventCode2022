defmodule Day16 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/16.txt"
      true -> "test_input/16.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_line(line) do
    [node, flow, edges] = Regex.run(~r/Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)/, line)
      |> tl
    {node, String.to_integer(flow), String.split(edges, ", ")}
  end

  def calculate(on_times, flows) do
    Enum.map(on_times, fn {node, time_on} -> Map.fetch!(flows, node) * time_on end)
      |> Enum.sum
  end

  def dfs(graph, curr_node, remaining, path_thus_far, on_time, acc) do
    cond do
      remaining == 0 -> [{path_thus_far, on_time} | acc]
      true ->
        candidates = Graph.out_edges(graph, curr_node)
          |> Enum.map(fn e -> {e.v2, e.weight} end)
          |> Enum.filter(fn {dest, _cost} -> not Map.has_key?(on_time, dest) end)
          |> Enum.filter(fn {_dest, cost} -> cost < remaining end)

        cond do
          candidates == [] -> [{path_thus_far, Map.put(on_time, curr_node, remaining)} | acc]
          true ->
            res = Enum.flat_map(candidates, fn {dest, cost} ->
              dfs(graph, dest, remaining - cost - 1, [dest | path_thus_far], Map.put(on_time, curr_node, remaining), acc)
            end)
            acc ++ res
        end
    end
  end

  def solve(test \\ false) do
    rows = get_input(test)
      |> Enum.map(&parse_line/1)

    edges = Enum.flat_map(rows, fn {node, _flow, edges} ->
      Enum.zip(List.duplicate(node, length(edges)), edges)
    end)
    graph = Graph.new
      |> Graph.add_edges(edges)

    flows = rows
      |> Enum.map(fn {node, flow, _edges} -> {node, flow} end)
      |> Enum.into(%{})

    non_zero_flows = flows
      |> Enum.filter(fn {_k, v} -> v > 0 end)
      |> Enum.into(%{})
      |> Map.put("AA", 0)

    dist_edges = Comb.cartesian_product(Map.keys(non_zero_flows), Map.keys(non_zero_flows))
      |> Enum.filter(fn [n1, n2] -> n1 != n2 end)
      |> Enum.map(fn [n1, n2] ->
        {n1, n2, weight: length(Graph.dijkstra(graph, n1, n2)) - 1}
      end)
    dense_graph = Graph.add_edges(graph, dist_edges)

    zero_flow_vertices = flows
      |> Enum.filter(fn {k, v} -> v == 0 and k != "AA" end)
      |> Enum.map(fn {k, _v} -> k end)
    final_graph = Graph.delete_vertices(dense_graph, zero_flow_vertices)

    Graph.out_edges(final_graph, "JJ")

    {_best_path, _best_open, part1} = dfs(final_graph, "AA", 30, ["AA"], %{}, [])
      |> Enum.map(fn {k, v} -> {k, v, calculate(v, non_zero_flows)} end)
      # |> IO.inspect
      |> Enum.max_by(fn {_k, _v, s} -> s end)

    pt2_paths = dfs(final_graph, "AA", 26, ["AA"], %{}, [])
      |> Enum.map(fn {k, v} -> {k, v, calculate(v, non_zero_flows)} end)
      |> Enum.sort_by(fn {_k, _v, s} -> s end)
      |> Enum.reverse

    best_using_p1 = Enum.zip(List.duplicate(hd(pt2_paths), length(pt2_paths)), tl(pt2_paths))
      |> Enum.reduce_while(0, fn {{_p1, v1, s1}, {_p2, v2, s2}}, acc ->
        set1 = MapSet.new(Map.keys(v1))
        set2 = MapSet.new(Map.keys(v2))

        cond do
          MapSet.intersection(set1, set2) == MapSet.new(["AA"]) -> {:halt, {acc, v1, v2, s1, s2, s1 + s2}}
          true -> {:cont, acc + 1}
        end
      end)

    filtered = Comb.combinations(pt2_paths |> Enum.slice(0, 1000), 2)
      |> Enum.filter(fn [{_p1, _v1, s1}, {_p2, _v2, s2}] ->
        s1 + s2 > elem(best_using_p1, 4)
      end)

    part2 = filtered
      |> Enum.filter(fn [{_p1, v1, _s1}, {_p2, v2, _s2}] ->
        s1 = MapSet.new(Map.keys(v1))
        s2 = MapSet.new(Map.keys(v2))

        MapSet.intersection(s1, s2) == MapSet.new(["AA"])
      end)
      |> Enum.map(fn [{_p1, _v1, s1}, {_p2, _v2, s2}] -> s1 + s2 end)
      |> Enum.max

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day16.solve(false)
