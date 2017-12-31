defmodule Metex do
  @moduledoc """
  Documentation for Metex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Metex.hello
      :world

  """

  def tempereatures_of(cities) do
    coordinatore_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    cities |> Enum.each(fn city -> 
      worker_pid = spawn(Metex.Worker, :loop, [])
      send worker_pid, {coordinatore_pid, city}
    end)
  end
end
