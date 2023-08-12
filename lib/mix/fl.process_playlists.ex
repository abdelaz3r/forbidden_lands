defmodule Mix.Tasks.Fl.ProcessPlaylists do
  @shortdoc "Extract playlists from given directory."

  @moduledoc """
  Extract playlists from a source directory and write to output to the target
  file.
  This task may fail if the musics directory is not found.
  This task will overwrite the mood.txt file.

  Available options are:
  * `--source`: the source directory (default: /priv/static/musics)
  * `--target`: the target file (default: /priv/static/mood.txt)

  Every subdirectory of the musics directory is considered as a playlist (a
  musics mood). The name of that subdirectory is the name of the playlist and
  will be used as the mood name. Musics must be in mp3 format.

  Usage example:
  ```
  mix fl.process_playlists --source "priv/static/musics" \\
    --target "priv/static/mood.txt"
  ```
  """

  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: [source: :string, targer: :string])

    # Default options
    source = Keyword.get(options, :source, "/priv/static/musics")
    target = Keyword.get(options, :target, "/priv/static/mood.txt")

    Mix.shell().info("Extract playlists from musics directory:")
    Mix.shell().info("Source: '#{source}'")
    Mix.shell().info("Target: '#{target}'")

    target_content =
      (File.cwd!() <> source)
      |> File.ls!()
      |> Enum.map(fn directory ->
        Mix.shell().info("")
        Mix.shell().info("Process '#{directory}' directory:")

        directory_path = source <> "/" <> directory

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

    File.write(File.cwd!() <> target, target_content)

    Mix.shell().info("")
    Mix.shell().info("Output written to '#{target}'")
  end
end
