defmodule Day21 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/21.txt"
      true -> "test_input/21.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_lines(input) do
    Enum.reduce(input, {[], %{}}, fn line, {formulas, nums} ->
      split = String.split(line, " ")
      case split do
        [res, num] -> {formulas, Map.put(nums, String.replace(res, ":", ""), String.to_integer(num))}
        [res, v1, op, v2] -> {[{String.replace(res, ":", ""), op, v1, v2} | formulas], nums}
      end
    end)
  end

  def apply_op(nums, {_res, op, v1, v2}) do
    v1_num = Map.fetch!(nums, v1)
    v2_num = Map.fetch!(nums, v2)
    case op do
      "*" -> v1_num * v2_num
      "+" -> v1_num + v2_num
      "-" -> v1_num - v2_num
      "/" -> v1_num / v2_num
    end
  end

  def pt1_fill_iter(formulas, nums) do
    Enum.reduce(formulas, nums, fn function, nacc ->
      {res, _op, v1, v2} = function
      cond do
        Map.has_key?(nacc, res) -> nacc
        Map.has_key?(nacc, v1) and Map.has_key?(nacc, v2) -> Map.put(nacc, res, apply_op(nacc, function))
        true -> nacc
      end
    end)
  end

  def pt1_fill(formulas, nums) do
    Enum.reduce_while(0..100000, nums, fn _iter, nacc ->
      cond do
        Map.has_key?(nacc, "root") -> {:halt, nacc}
        true -> {:cont, pt1_fill_iter(formulas, nacc)}
      end
    end)
  end

  def sgn(n) do
    case round(n) do
      0 -> 0
      k -> round(k / abs(k))
    end
  end

  def pt2_driver(formulas, nums) do
    replace_idx = formulas
      |> Enum.find_index(fn t -> elem(t, 0) == "root" end)
    {root, _op, v1, v2} = Enum.at(formulas, replace_idx)
    sub_replaced = List.replace_at(formulas, replace_idx, {root, "-", v1, v2})
    initial_sgn = pt1_fill(sub_replaced, nums)
      |> Map.fetch!("root")
      |> sgn

    bs_bounds = {0, 10000000000000}
    Enum.reduce_while(0..100, bs_bounds, fn _iter, {lb, ub} ->
      mid = div(ub + lb, 2)
      with_humn = Map.put(nums, "humn", mid)
      res = pt1_fill(sub_replaced, with_humn)
        |> Map.fetch!("root")
        |> sgn
      cond do
        res == 0 -> {:halt, mid}
        res == initial_sgn -> {:cont, {mid - 1, ub}}
        true -> {:cont, {lb, mid + 1}}
      end
    end)
  end

  def solve(test \\ false) do
    input = get_input(test)
    {formulas, nums} = parse_lines(input)

    filled_nums = pt1_fill(formulas, nums)
    part1 = Map.fetch!(filled_nums, "root")
      |> round

    part2 = pt2_driver(formulas, nums)

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day21.solve(false)
