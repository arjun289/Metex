defmodule Metex.Worker do

  @moduledoc """
  Module to interact with the openweather app Api to get weather
  of a location.
  """
  @doc """
  Takes the location and returns the temperature if successful, else 
  returns an error.
  """
  @apikey "8eaf2cf0426238dccb5cd1e235c3d251"

  def loop do
    receive do
      {sender_pid, location} -> 
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts "Don't know how to process this message."
    end
    loop()
  end

  @spec temperature_of(String.t) :: Tuple
  defp temperature_of(location) do
    result = url_for(location) |> HTTPoison.get |> parse_response
    case result do
      {:ok, temp} -> "location-> #{location}: temp-> #{temp}"
      :error -> "location-> #{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{@apikey}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end
end
