defmodule Input do
  @moduledoc """
  Documentation for AocElixir.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AocElixir.hello
      :world

  """
  def read_file(filename) do
    {:ok, input} = File.read(filename)
    input
  end

  def lines(filename, sep \\ "\n") do
    read_file(filename)
      |> String.trim
      |> String.split(sep)
  end

  def line_tokens(filename, sep1 \\ " ", sep2 \\ "\n") do
    lines(filename, sep2)
      |> Enum.map(fn r -> String.split(r, sep1) end)
  end

  def ints(filename) do
    lines(filename)
      |> Enum.map(&String.to_integer/1)
  end

  def line_of_ints(filename) do
    lines(filename, ",")
    |> Enum.map(&String.to_integer/1)
  end
end
