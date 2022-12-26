defmodule Blueprint do
  defstruct [
    :id,
    :oreo,
    :clayo,
    :obso, :obsc,
    :geoo, :geoobs,
    :maxg
  ]
end

defmodule Day19 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/19.txt"
      true -> "test_input/19.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_line(line) do
    [bid, oreo, clayo, obso, obsc, geoo, geoobs] =
      Regex.scan(~r/\d+/, line)
        |> List.flatten
        |> Enum.map(&String.to_integer/1)
    max_geo = Enum.max([oreo, clayo, obso, geoo])

    %Blueprint{
      id: bid,
      oreo: oreo,
      clayo: clayo,
      obso: obso, obsc: obsc,
      geoo: geoo, geoobs: geoobs,
      maxg: max_geo
    }
  end

  def get_opts(blueprint, state, remaining) do
    base = [[0, 0, 0, 0, 0, 0, 0, 0]]
    [ore, clay, obs, _geo, ore_r, clay_r, obs_r, _geo_r] = state
    max_needed_ore = remaining * blueprint.maxg
    build_ore = cond do
      ore >= blueprint.oreo and ore + ore_r * remaining <= max_needed_ore -> [[-blueprint.oreo, 0, 0, 0, 1, 0, 0, 0] | base]
      true -> base
    end

    max_needed_clay = remaining * blueprint.obsc
    build_clay = cond do
      ore >= blueprint.clayo and clay + clay_r * remaining <= max_needed_clay -> [[-blueprint.clayo, 0, 0, 0, 0, 1, 0, 0] | build_ore]
      true -> build_ore
    end

    max_needed_obs = remaining * blueprint.geoobs
    build_obs = cond do
      ore >= blueprint.obso and clay >= blueprint.obsc and obs + obs_r * remaining <= max_needed_obs -> [[-blueprint.obso, -blueprint.obsc, 0, 0, 0, 0, 1, 0] | build_clay]
      true -> build_clay
    end

    build_geo = cond do
      ore >= blueprint.geoo and obs >= blueprint.geoobs -> [[-blueprint.geoo, 0, -blueprint.geoobs, 0, 0, 0, 0, 1]]
      true -> build_obs
    end

    build_geo
  end

  def generate(state) do
    [ore, clay, obs, geo, ore_r, clay_r, obs_r, geo_r] = state
    [ore + ore_r, clay + clay_r, obs + obs_r, geo + geo_r, ore_r, clay_r, obs_r, geo_r]
  end

  def apply_choice(state, choice) do
    Enum.zip(state, choice)
      |> Enum.map(fn {t1, t2} -> t1 + t2 end)
  end

  def simulate(blueprint, num_minutes) do
    # ore, clay, obsideon, geodes, ore robots, clay robots, obs robots, geode robots
    state = [0, 0, 0, 0, 1, 0, 0, 0]

    final_state = Enum.reduce(num_minutes..1//-1, state, fn remaining, acc ->
      opts = get_opts(blueprint, acc, remaining)
      choice = Enum.random(opts)
      after_generate = generate(acc)
      apply_choice(after_generate, choice)
    end)
    Enum.at(final_state, 3)
  end

  def print_blueprint(blueprint) do
    str = "{\n"
      <> "\tid: #{blueprint.id},\n"
      <> "\toreo: #{blueprint.oreo},\n"
      <> "\tclayo: #{blueprint.clayo},\n"
      <> "\tobso: #{blueprint.obso},\n"
      <> "\tobsc: #{blueprint.obsc},\n"
      <> "\tgeoo: #{blueprint.geoo},\n"
      <> "\tgeoobs: #{blueprint.geoobs},\n"
      <> "\tmaxg: #{blueprint.maxg}\n"
      <> "}"
    IO.puts(str)

  end

  def monte_carlo(num_iters, num_minutes, blueprints) do
    best_guesses = Enum.map(blueprints, fn blueprint ->
      # IO.puts "Handling blueprint #{blueprint.id}"
      # print_blueprint(blueprint)
      best_guess = Enum.reduce(1..num_iters, 0, fn iter, best_thus_far ->
        cond do
          rem(iter, 500000) == 0 -> IO.write "."
          true -> nil
        end
        res = simulate(blueprint, num_minutes)
        cond do
          res > best_thus_far -> res
          true -> best_thus_far
        end
      end)
      # IO.puts("\nBest guess: #{best_guess}")
      {blueprint.id, best_guess}
    end)

    # IO.puts "Done simulating"
    best_guesses
  end

  def monte_carlo_agent(num_minutes, blueprints, num_iters \\ 3000000) do
    tasks = [
      Task.async(fn -> monte_carlo(num_iters, num_minutes, blueprints) end),
      Task.async(fn -> monte_carlo(num_iters, num_minutes, blueprints) end),
      Task.async(fn -> monte_carlo(num_iters, num_minutes, blueprints) end),
      Task.async(fn -> monte_carlo(num_iters, num_minutes, blueprints) end),
      Task.async(fn -> monte_carlo(num_iters, num_minutes, blueprints) end),
    ]

    all_results = Task.await_many(tasks, 600000) # 30 minutes

    all_results
      |> Enum.zip
      |> Enum.map(fn id_lst -> Enum.max_by(Tuple.to_list(id_lst), fn {_id, guess} -> guess end) end)
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(&parse_line/1)

    pt1_num_iters = case test do
      false -> 1000000
      true -> 100
    end

    pt1_guesses = monte_carlo_agent(24, input, pt1_num_iters)
    pt1_historical_best = case test do
      false ->
        %{
          1 => 0, 2 => 9, 3 => 3, 4 => 1, 5 => 5, 6 => 0, 7 => 1, 8 => 3, 9 => 7,
          10 => 0, 11 => 2, 12 => 5, 13 => 4, 14 => 1, 15 => 0, 16 => 0, 17 => 2, 18 => 1, 19 => 3,
          20 => 1, 21 => 1, 22 => 1, 23 => 0, 24 => 5, 25 => 7, 26 => 1, 27 => 0, 28 => 0, 29 => 6,
          30 => 5
        }
      true -> %{}
    end

    IO.inspect("Done simulating part 1")

    part1 = pt1_guesses
      |> IO.inspect
      |> Enum.map(fn {id, score} -> id * max(Map.get(pt1_historical_best, id, 0), score) end)
      |> Enum.sum

    pt2_num_iters = case test do
      false -> 10000000
      true -> 100
    end

    pt2_historical_best = case test do
      false ->
        %{
          1 => 16, 2 => 54, 3 => 29
        }
      true -> %{}
    end

    pt2_guesses = monte_carlo_agent(32, Enum.slice(input, 0, 3), pt2_num_iters)
    IO.inspect("Done simulating part 2")

    part2 = pt2_guesses
      |> IO.inspect
      |> Enum.map(fn {id, score} -> max(Map.get(pt2_historical_best, id, 0), score) end)
      |> Enum.product

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day19.solve()
