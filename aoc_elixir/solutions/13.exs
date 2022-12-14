defmodule Day13 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/13.txt"
      true -> "test_input/13.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename, "\n", "\n\n")
      # .lines(filename, "\n\n")
      # .line_of_ints(filename)
  end

  def sign(n) do
    case n do
      0 -> 0
      o -> div(o, abs(o))
    end
  end

  def compare(left, right) do
    len = max(length(left), length(right))
    Enum.reduce_while(0..len, {left, right, 0}, fn _i, {left, right, _res} ->
      cond do
        left == [] and right == [] -> {:halt, {[], [], 0}}
        left == [] -> {:halt, {[], right, 1}}
        right == [] -> {:halt, {left, [], -1}}
        true ->
          [left_hd | left_tl] = left
          [right_hd | right_tl ] = right

          res = cond do
            is_integer(left_hd) and is_integer(right_hd) ->
              sign(right_hd - left_hd)
            is_integer(left_hd) and is_list(right_hd) ->
              compare([left_hd], right_hd)
            is_list(left_hd) and is_integer(right_hd) ->
              compare(left_hd, [right_hd])
            is_list(left_hd) and is_list(right_hd) ->
              compare(left_hd, right_hd)
            true -> nil
          end

          case res do
            -1 -> {:halt, {left_tl, right_tl, -1}}
            1 -> {:halt, {left_tl, right_tl, 1}}
            0 -> {:cont, {left_tl, right_tl, 0}}
          end
      end
    end)
      |> elem(2)
  end

  def code_eval(line) do
    JSON.decode!(line)
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(fn [p1, p2] -> [code_eval(p1), code_eval(p2)] end)

    evaled = input
      |> Enum.map(fn [p1, p2] -> compare(p1, p2) end)

    calc = Enum.zip(1..length(evaled) - 1, evaled)
      |> Enum.filter(fn {_idx, v} -> v == 1 end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.sum

    to_add = [[[2]], [[6]]]
    full_sorted = input
      |> Enum.reduce([], fn [p1, p2], acc -> [p1, p2] ++ acc end)
      |> then(fn r -> r ++ to_add end)
      |> Enum.sort(fn p1, p2 ->
        res = compare(p1, p2)
        case res do
          1 -> true
          0 -> false
          -1 -> false
        end
      end)

    indices = Enum.map(to_add, fn t -> Enum.find_index(full_sorted, fn e -> e == t end) + 1 end)

    part1 = calc
    part2 = Enum.product(indices)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day13.solve()
