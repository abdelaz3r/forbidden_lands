defmodule Mix.Tasks.Fl.ProcessItems do
  @shortdoc "TODO"

  @moduledoc """
  TODO
  """

  use Mix.Task

  # alias ForbiddenLands.Instances.Event
  # alias ForbiddenLands.Instances.Instances

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args,
        strict: [
          source: :string,
          apikey: :string,
          orgkey: :string
        ]
      )

    unless Keyword.has_key?(options, :source) do
      Mix.shell().error("A source file is required.")
      exit(1)
    end

    unless Keyword.has_key?(options, :apikey) do
      Mix.shell().error("An api key is required.")
      exit(1)
    end

    unless Keyword.has_key?(options, :orgkey) do
      Mix.shell().error("An organization key is required.")
      exit(1)
    end

    # Default options
    source = Keyword.fetch!(options, :source)
    api_key = Keyword.fetch!(options, :apikey)
    org_key = Keyword.fetch!(options, :orgkey)

    # Read source file
    items = read_source!(source)

    # Pipeline to process items
    [head | _rest] =
      items
      |> Enum.take_random(2)
      |> Enum.map(&normalize/1)
      |> Enum.map(fn item -> Task.async(fn -> summarize(item, api_key: api_key, org_key: org_key) end) end)
      |> Enum.map(fn task -> Task.await(task, :infinity) end)

    IO.inspect(head)
  end

  defp read_source!(source) do
    with {:ok, body} <- File.read(source),
         {:ok, json} <- Poison.decode(body) do
      json
    else
      {:error, error} ->
        Mix.shell().error("Error:")
        Mix.shell().error(error)

      error ->
        Mix.shell().error("Error:")
        Mix.shell().error(error)
    end
  end

  defp normalize(item) do
    name =
      item["name"]
      |> String.downcase()
      |> String.capitalize()

    %{item | "name" => name}
  end

  defp summarize(item, options) do
    config = %OpenAI.Config{
      api_key: Keyword.fetch!(options, :api_key),
      organization_key: Keyword.fetch!(options, :org_key),
      http_options: [recv_timeout: 30_000]
    }

    prompt = "
      You will take the next content and output a shortened version of it.
      You will only output the shortened version. Nothing else.
      If the content is short enought just output it as is.
      If the content is too long, you must shorten it. You must keep the meaning of the content.
      You must keep the technical information and term.
      You must keet the tone of the content.
      Assume there is a context, do NOT use 'this shield', use 'it' instead.
      The shortened version must be between 50 and 200 words.
    "

    messages = [%{role: "system", content: prompt}, %{role: "user", content: item["description"]}]
    response = OpenAI.chat_completion([model: "gpt-3.5-turbo", messages: messages], config)

    summary =
      case response do
        {:ok, %{choices: choices}} ->
          resp = List.first(choices)
          resp["message"]["content"]

        {:error, error} ->
          Mix.shell().error("Error while summarizing items #{item["name"]}:")
          Mix.shell().error(error)
      end

    IO.puts("SPELL: #{item["name"]}")
    IO.puts("")
    IO.puts("Original (length: #{String.length(item["description"])}):")
    IO.puts(item["description"])
    IO.puts("")
    IO.puts("Summarized (length: #{String.length(summary)}):")
    IO.puts(summary)
    IO.puts("")
    IO.puts("-----------")
    IO.puts("")

    item
  end
end
