defmodule Mix.Tasks.Fl.ProcessPlaylists do
  use Mix.Task

  require Logger

  @shortdoc "Extract playlists from given directory."

  @moduledoc """
  Extract playlists from args[0] directory and write to output to the args[1] file.

  Default source directory is "musics".
  Default output file is "/lib/forbidden_lands/music/mood.txt".

  This task may fail if the musics directory is not found.
  This task will overwrite the mood.txt file.
  """

  @impl Mix.Task
  def run(args) do
    source_directory = Enum.at(args, 0, "musics")
    directories_path = "/priv/static/" <> source_directory
    output_path = Enum.at(args, 1, "/lib/forbidden_lands/music/mood.txt")

    Mix.shell().info("Extract playlists from musics directory:")
    Mix.shell().info("Source: '#{directories_path}'")
    Mix.shell().info("Output: '#{output_path}'")

    target_content =
      (File.cwd!() <> directories_path)
      |> File.ls!()
      |> Enum.map(fn directory ->
        Mix.shell().info("")
        Mix.shell().info("Process '#{directory}' directory:")

        directory_path = directories_path <> "/" <> directory

        (File.cwd!() <> directory_path)
        |> File.ls!()
        |> Enum.filter(fn file -> String.ends_with?(file, ".mp3") end)
        |> Enum.map(fn file ->
          Mix.shell().info("  Collect '#{file}'")

          directory <> "/" <> file <> "\n"
        end)
      end)
      |> List.flatten()
      |> List.to_string()
      |> String.trim_trailing()

    target_path = "/lib/forbidden_lands/music/mood.txt"
    File.write(File.cwd!() <> target_path, target_content)

    Mix.shell().info("")
    Mix.shell().info("Output written to '#{target_path}'")
  end
end
