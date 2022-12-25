defmodule Day15 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/15.txt"
      true -> "test_input/15.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def get_nums(str) do
    Regex.scan(~r/-?\d+/, str)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
  end

  def get_bubble_edge({x, y}, dist) do
    edge_dist = dist+1
    Enum.reduce(0..edge_dist, [], fn dx, acc ->
      dy = edge_dist - dx
      app = [{x + dx, y + dy}, {x + dx, y - dy}, {x - dx, y + dy}, {x - dx, y - dy}]
        |> Enum.uniq
      acc ++ app
    end)
  end

  def get_slice_y({cx, cy}, radius, ty) do
    cond do
      abs(ty - cy) > radius -> {:disjoint, nil}
      true ->
        rem_dist = radius - abs(ty - cy)
        {:overlap, {cx - rem_dist, cx + rem_dist}}
    end
  end

  def reduce_slices(slices) do
    {ranges, {left, right}} = Enum.reduce(tl(slices), {[], hd(slices)}, fn {new_left, new_right}, {new_ranges, {cleft, cright}} ->
      cond do
        cright + 1 < new_left -> {[{cleft, cright} | new_ranges], {new_left, new_right}}
        true -> {new_ranges, {cleft, max(new_right, cright)}}
      end
    end)

    [{left, right} | ranges]
  end

  def test_point(bubbles, {px, py}) do
    Enum.any?(bubbles, fn {{bx, by}, r} ->
      (abs(px - bx) + abs(py - by)) <= r
    end)
  end

  def get_intersections(b1, b2) do
    {{x1, y1}, r1} = b1
    {{x2, y2}, r2} = b2

    b1_pos = [y1 - (x1 + r1 + 1), y1 - (x1 - r1 - 1)]
    b2_neg = [y2 + (x2 + r2 + 1), y2 + (x2 - r2 - 1)]

    b1_neg = [y1 + (x1 + r1 + 1), y1 + (x1 - r1 - 1)]
    b2_pos = [y2 - (x2 + r2 + 1), y2 - (x2 - r2 - 1)]

    pairs = Comb.cartesian_product(b1_pos, b2_neg) ++ Comb.cartesian_product(b1_neg, b2_pos)
    points = Enum.map(pairs, fn [b1, b2] -> {b2 - b1, b1 + b2} end)
      |> Enum.filter(fn {x, y} -> rem(x, 2) == 0 and rem(y, 2) == 0 end)
      |> Enum.map(fn {x, y} -> {div(x, 2), div(y, 2)} end)

    points
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(&get_nums/1)
    beacons_signals = input
      |> Enum.flat_map(fn [sx, sy, bx, by] -> [{sx, sy}, {bx, by}] end)
      |> Enum.uniq

    bubbles = input
      |> Enum.map(fn [sx, sy, bx, by] -> {{sx, sy}, abs(sx - bx) + abs(sy - by)} end)

    {scan_y, limit} = case test do
      true -> {10, 20}
      false -> {2000000, 4000000}
    end

    p1_ranges = Enum.map(bubbles, fn {p, r} -> get_slice_y(p, r, scan_y) end)
      |> Enum.filter(fn {res, _range} -> res == :overlap end)
      |> Enum.map(fn {_res, range} -> range end)
      |> Enum.sort
      |> then(&reduce_slices/1)
      |> Enum.sort

    bs_in_ranges = beacons_signals
      |> Enum.filter(fn {_x, y} -> y == scan_y end)
      |> Enum.count(fn {x, _y} ->
        Enum.any?(p1_ranges, fn {l, r} -> l <= x and x <= r end)
      end)

    part1 = p1_ranges
      |> Enum.map(fn {l, r} -> r - l + 1 end)
      |> Enum.sum
      |> then(fn s -> s - bs_in_ranges end)

    bubble_combs = Comb.combinations(bubbles, 2)
    intersections = bubble_combs
      |> Enum.flat_map(fn [b1, b2] -> get_intersections(b1, b2) end)
      |> Enum.uniq
      |> Enum.filter(fn {x, y} ->
        0 <= x and x <= limit and 0 <= y and y <= limit
      end)
      |> IO.inspect

    {px, py} = Enum.reduce_while(intersections, nil, fn point, _res ->
      case test_point(bubbles, point) do
        true -> {:cont, nil}
        false -> {:halt, point}
      end
    end)
      |> IO.inspect
    part2 = 4000000 * px + py

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day15.solve(false)
