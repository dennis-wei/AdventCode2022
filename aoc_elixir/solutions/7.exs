Code.require_file("lib/input.ex")
Code.require_file("lib/grid.ex")
filename = "input/7.txt"
# filename = "test_input/7.txt"
input = Input
  # .ints(filename)
  .line_tokens(filename)
  # .lines(filename)
  # .line_of_ints(filename)

defmodule Day7 do
  def update_sizes(size, prefix, sizes) do
    {_folder, updated_sizes} = List.foldr(prefix, {"", sizes}, fn p, {folder, size_map} ->
      full_folder = folder <> "/" <> String.trim(p, "/")
      size_int = String.to_integer(size)
      updated = Map.update(size_map, full_folder, size_int, fn cv -> cv + size_int end )
      {full_folder, updated}
    end)

    updated_sizes
  end

  def handle_line(line, {prefix, sizes}) do
    case line do
      ["$", "cd", ".."] -> {tl(prefix), sizes}
      ["$", "cd", arg] -> {[arg | prefix], sizes}
      ["dir", _dir_name] -> {prefix, sizes}
      ["$", "ls"] -> {prefix, sizes}
      [size, _name] -> {prefix, update_sizes(size, prefix, sizes)}
    end
  end
end

{_prefix, sizes} = input
|> Enum.reduce({[], %{}}, fn ln, acc -> Day7.handle_line(ln, acc) end)

part1 = sizes
  |> Map.values
  |> Enum.filter(fn n -> n <= 100000 end)
  |> Enum.sum

used_space = Map.fetch!(sizes, "/")
unused_space = 70000000 - used_space
part2 = sizes
  |> Map.values
  |> Enum.filter(fn n -> unused_space + n > 30000000 end)
  |> Enum.min

IO.puts("Part 1: #{part1}")
IO.puts("Part 2: #{part2}")
