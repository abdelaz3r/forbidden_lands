defmodule ForbiddenLands.Music.Mood do
  @moduledoc false

  require Logger

  @spec playlists() :: map()
  def playlists() do
    file_path = File.cwd!() <> "/lib/forbidden_lands/music/mood.txt"

    playlists =
      with {:ok, file} <- File.read(file_path) do
        file
        |> String.split("\n")
        |> Enum.map(&String.split(&1, "/"))
        |> Enum.group_by(fn [mood, _music] -> mood end, fn [_mood, music] -> music end)
      else
        {:error, reason} ->
          Logger.error("Unable to read mood.txt: #{inspect(reason)}")
          %{}
      end

    Map.merge(%{"silence" => []}, playlists)
  end
end
