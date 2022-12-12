Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/11.txt"
# filename = "test_input/11.txt"
input = Input
  # .ints(filename)
  # .line_tokens(filename)
  .lines(filename, "\n\n")
  # .line_of_ints(filename)

defmodule Operation do
  defstruct [:op, :arg1, :arg2]
end

defmodule Test do
  defstruct [:div, :true_target, :false_target]
end

defmodule Monkey do
  defstruct [:id, :operation, :test, items: [], inspected: 0]
end

defmodule Day11 do
  def get_nums(str) do
    Regex.scan(~r/\d+/, str)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
  end

  @ops %{
    "*" => &*/2,
    "+" => &+/2
  }

  def parse_op(op_str) do
    [_operation, _new, _equal, raw_arg1, op_func, raw_arg2] = String.split(op_str, " ")
    arg1 = case raw_arg1 do
      "old" -> "old"
      n -> String.to_integer(n)
    end

    arg2 = case raw_arg2 do
      "old" -> "old"
      n -> String.to_integer(n)
    end

    op = Map.fetch!(@ops, op_func)
    %Operation{op: op, arg1: arg1, arg2: arg2}
  end

  def do_op(old, op, part2_ring \\ nil) do
    a1 = case op.arg1 do
      "old" -> old
      n -> n
    end

    a2 = case op.arg2 do
      "old" -> old
      n -> n
    end

    res = apply(op.op, [a1, a2])
    case part2_ring do
      nil -> div(res, 3)
      n -> rem(res, n)
    end
  end

  def do_test(n, test) do
    cond do
      rem(n, test.div) == 0 -> test.true_target
      true -> test.false_target
    end
  end

  def parse_monkey(monkey_text) do
    [id_str, items_str, operation_str, test_str, true_str, false_str] = String.split(monkey_text, "\n")
      |> Enum.map(&String.trim/1)
    [id] = get_nums(id_str)
    starting_items = get_nums(items_str)
    [div_test] = get_nums(test_str)
    [true_target] = get_nums(true_str)
    [false_target] = get_nums(false_str)
    op = parse_op(operation_str)

    test = %Test{div: div_test, true_target: true_target, false_target: false_target}
    %Monkey{id: id, operation: op, test: test, items: starting_items}
  end

  def monkey_round(monkey, part2_ring \\ nil) do
    targets = Enum.map(monkey.items, fn i ->
      res = do_op(i, monkey.operation, part2_ring)
      target = do_test(res, monkey.test)
      {target, res}
    end)

    targets_grouped = Enum.group_by(targets, fn {t, _r} -> t end, fn {_t, r} -> r end)

    updated_monkey = %Monkey{monkey | items: [], inspected: monkey.inspected + length(targets)}
    {updated_monkey, targets_grouped}
  end

  def give_items(monkey, items) do
    %Monkey{monkey | items: monkey.items ++ items}
  end

  def update_acc(acc, idx, monkey, to_append) do
    res = Enum.reduce(to_append, List.replace_at(acc, idx, monkey), fn {target, items}, acc ->
      List.replace_at(acc, target, give_items(Enum.fetch!(acc, target), items))
    end)
    # IO.inspect res, charlists: false
    res
  end

  def do_round(round, monkeys, part2_ring \\ nil, verbose \\ false) do
    cond do
      verbose ->
        IO.puts "Round #{round}\n===\nStart:\n"
        monkeys
          |> Enum.map(fn m -> IO.puts "#{m.id}: #{m.items |> Enum.map(&Integer.to_string/1) |> Enum.join(",")}" end)
        IO.puts "\n"
      true -> nil
    end
    res = Enum.reduce(0..length(monkeys)-1, monkeys, fn idx, monkeys_acc ->
      {new_monkey, to_append} = monkey_round(Enum.fetch!(monkeys_acc, idx), part2_ring)
      update_acc(monkeys_acc, idx, new_monkey, to_append)
    end)
    cond do
      verbose ->
        IO.puts "End:\n"
        res
          |> Enum.map(fn m -> IO.puts "#{m.id}: #{m.items |> Enum.map(&Integer.to_string/1) |> Enum.join(",")}" end)
        IO.puts "\n"
      true -> nil
    end
    res
  end

  def solve(input, num_rounds, part2 \\ false) do
    monkeys = input
      |> Enum.map(&parse_monkey/1)
    part2_ring = case part2 do
      false -> nil
      true -> Enum.map(monkeys, fn m -> m.test.div end) |> Enum.product
    end
      |> IO.inspect

    after_rounds = Enum.reduce(1..num_rounds, monkeys, fn n, monkeys_acc -> do_round(n, monkeys_acc, part2_ring) end)
    IO.inspect after_rounds, charlists: false

    [t1, t2] = Enum.sort_by(after_rounds, fn m -> m.inspected end)
      |> Enum.reverse
      |> Enum.slice(0..1)

    t1.inspected * t2.inspected
  end
end

part1 = Day11.solve(input, 20)

part2 = Day11.solve(input, 10000, true)

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
