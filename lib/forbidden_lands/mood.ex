defmodule ForbiddenLands.Mood do
  @moduledoc false

  @spec playlists() :: map()
  def playlists() do
    %{
      "silence" => [],
      "noises" => ["test1.mp3", "test2.mp3", "test3.mp3"],
      "musics" => ["music1.mp3", "music2.mp3"]
    }
  end
end
